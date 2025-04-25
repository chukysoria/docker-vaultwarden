# syntax=docker/dockerfile:1@sha256:4c68376a702446fc3c79af22de146a148bc3367e73c25a5803d453b6b3f722fb

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.7.13-3.21@sha256:f2ceeaeaea94ab0a208250ab1da38b756c4e636f8f7d229b472c298980e2ba79
ARG BUILD_EXT_RELEASE="1.33.2-alpine@sha256:63cce7624f655f83ad5bab66ef62bc3e3327116b068704bfbbda5d0c1b3003be"
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
        openssl=3.3.3-r0

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
