package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"time"
)

const addr = ":8080"

func main() {
	// A scratch image has no wget or curl, so the binary doubles as its own HEALTHCHECK probe.
	healthcheck := flag.Bool("healthcheck", false, "probe /health and exit 0 (healthy) or 1")
	flag.Parse()
	if *healthcheck {
		os.Exit(probe())
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, "Hello from Go")
	})
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprintln(w, `{"status":"ok"}`)
	})

	srv := &http.Server{Addr: addr, Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	if err := srv.ListenAndServe(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func probe() int {
	client := http.Client{Timeout: 2 * time.Second}
	resp, err := client.Get("http://127.0.0.1" + addr + "/health")
	if err != nil {
		return 1
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return 1
	}
	return 0
}
