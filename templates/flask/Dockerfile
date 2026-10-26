# syntax=docker/dockerfile:1

## Build stage: install dependencies into a virtualenv ##
FROM python:3.14.9-slim-trixie AS build
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /app
COPY requirements.txt ./
RUN --mount=type=cache,target=/root/.cache/pip pip install -r requirements.txt

## Run stage ##
FROM python:3.14.9-slim-trixie
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"
WORKDIR /app

RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app

COPY --from=build /opt/venv /opt/venv
COPY --chown=app:app app.py ./

USER app

# gunicorn instead of `flask run`: the dev server is single-process and not meant for production.
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"]
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-"]
