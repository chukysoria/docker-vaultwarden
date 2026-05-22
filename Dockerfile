# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v1.0.9-3.23@sha256:f193f72cb0df49be2280ed60b050cc257a64a7bad2319c488ddaef94b56a493e
ARG BUILD_EXT_RELEASE="1.36.0-alpine@sha256:d3531610b486905943706b235e97159331801c6856e1367a93a5905e2b40f204"
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
        openssl=3.5.6-r0

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
