# syntax=docker/dockerfile:1.7
FROM debian:bookworm-slim

ARG DUCKDB_VERSION=v1.1.3
ARG TARGETARCH

# --- base tools ---
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl unzip \
      python3 python3-venv python3-distutils


RUN apt-get install -y --no-install-recommends \
  vim

 RUN rm -rf /var/lib/apt/lists/*

# --- install duckdb CLI ---
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) RELEASE_ARCH="linux-amd64" ;; \
      arm64) RELEASE_ARCH="linux-aarch64" ;; \
      *)     echo "Arch non supportée: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/duckdb_cli.zip \
      "https://github.com/duckdb/duckdb/releases/download/${DUCKDB_VERSION}/duckdb_cli-${RELEASE_ARCH}.zip"; \
    unzip /tmp/duckdb_cli.zip -d /usr/local/bin; \
    chmod +x /usr/local/bin/duckdb; \
    rm -f /tmp/duckdb_cli.zip

# --- create venv & install dbt-duckdb (PEP 668-friendly) ---
RUN python3 -m venv /opt/dbt \
 && /opt/dbt/bin/pip install --no-cache-dir --upgrade pip \
 && /opt/dbt/bin/pip install --no-cache-dir "dbt-duckdb>=1.7.0" \
 && ln -s /opt/dbt/bin/dbt /usr/local/bin/dbt

# --- runtime user & workspace ---
RUN useradd -m -u 1000 duck && mkdir -p /data && chown duck:duck /data
USER duck
WORKDIR /data

# --- keep container alive by default (so you can exec duckdb / dbt) ---
ENTRYPOINT ["tail", "-f", "/dev/null"]
# Si tu préfères lancer directement la CLI DuckDB :
# ENTRYPOINT ["duckdb"]
