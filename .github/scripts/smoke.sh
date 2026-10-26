#!/usr/bin/env bash
# Smoke test for a built image.
#
#   smoke.sh IMAGE http PORT PATH [docker run args...]   start it, wait for HTTP 200, check non-root + healthcheck
#   smoke.sh IMAGE run  EXPECTED  [docker run args...]   run to completion, check stdout contains EXPECTED
set -euo pipefail

image=$1
mode=$2
shift 2

case "$mode" in
  run)
    expected=$1
    shift
    output=$(docker run --rm "$@" "$image")
    echo "$output"
    grep -qF -- "$expected" <<<"$output"
    ;;

  http)
    port=$1
    path=$2
    shift 2

    cid=$(docker run -d -p "127.0.0.1:${port}:${port}" "$@" "$image")
    cleanup() {
      echo "--- container logs ---"
      docker logs "$cid" 2>&1 | tail -n 40 || true
      docker rm -f "$cid" >/dev/null 2>&1 || true
    }
    trap cleanup EXIT

    url="http://127.0.0.1:${port}${path}"
    for _ in $(seq 1 90); do
      if curl -fsS "$url" >/dev/null 2>&1; then
        reachable=1
        break
      fi
      if [ "$(docker inspect -f '{{.State.Running}}' "$cid")" != "true" ]; then
        echo "container exited before answering on $url" >&2
        exit 1
      fi
      sleep 1
    done
    [ "${reachable:-0}" = 1 ] || { echo "no HTTP 200 from $url within 90s" >&2; exit 1; }
    echo "GET $url -> 200: $(curl -fsS "$url" | head -c 120)"

    # The main process must not run as root (checked from the host, so it works for scratch images).
    pid=$(docker inspect -f '{{.State.Pid}}' "$cid")
    uid=$(awk '/^Uid:/ {print $2}' "/proc/${pid}/status")
    echo "container main process uid: $uid"
    [ "$uid" != "0" ] || { echo "container runs as root" >&2; exit 1; }

    # If the image defines a HEALTHCHECK, it must report healthy.
    if [ "$(docker inspect -f '{{if .Config.Healthcheck}}yes{{end}}' "$cid")" = "yes" ]; then
      for _ in $(seq 1 60); do
        status=$(docker inspect -f '{{.State.Health.Status}}' "$cid")
        [ "$status" = "healthy" ] && break
        sleep 2
      done
      echo "healthcheck status: $status"
      [ "$status" = "healthy" ] || { echo "healthcheck never became healthy" >&2; exit 1; }
    else
      echo "image defines no HEALTHCHECK (skipped)"
    fi
    ;;

  *)
    echo "unknown mode: $mode" >&2
    exit 2
    ;;
esac
