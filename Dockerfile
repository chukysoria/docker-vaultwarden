# syntax=docker/dockerfile:1@sha256:38387523653efa0039f8e1c89bb74a30504e76ee9f565e25c9a09841f9427b05

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.8.9-3.22@sha256:b85ba89565a671992916d7bf020d688aba9623dfc53959c1a412f8ef930032fc
ARG BUILD_EXT_RELEASE="1.34.3-alpine@sha256:d70118b9dafb8588ee2651ceb5df68db27dcbd8e18467722010644ba48d5d6d6"
FROM ghcr.io/dani-garcia/vaultwarden:${BUILD_EXT_RELEASE} AS source
FROM ${BUILD_FROM} AS release

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL build_version="Chukyserver.io version:- ${BUILD_VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chukysoria"

ENV ROCKET_PROFILE="release" \
    ROCKET_ADDRESS=0.0.0.0 \
    ROCKET_PORT=7979 \
    ROCKET_WORKERS=2 \
    SSL_CERT_DIR=/etc/ssl/certs \
    DATA_FOLDER=/app/vw/data 

# Create data folder and Install needed libraries
RUN mkdir /app/vw && \
    mkdir /app/vw/data && \
    apk --no-cache add \
        openssl=3.5.2-r0

# Copies the files from the context (Rocket.toml file and web-vault)
# and the binary from the "build" stage to the current stage
COPY --from=source /web-vault /app/vw/web-vault
COPY --from=source /vaultwarden /app/vw/vaultwarden

# copy local files
COPY root/ /

VOLUME /app/vw/data
EXPOSE 7979
EXPOSE 3012

HEALTHCHECK --interval=30s --timeout=30s --start-period=2m --start-interval=5s --retries=5 CMD ["/etc/s6-overlay/s6-rc.d/svc-vaultwarden/data/check"]
