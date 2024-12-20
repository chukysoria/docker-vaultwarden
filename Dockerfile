# syntax=docker/dockerfile:1@sha256:93bfd3b68c109427185cd78b4779fc82b484b0b7618e36d0f104d4d801e66d25

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.7.2-3.21@sha256:16eeefb2667d01c1de9697a92f82fbce2b44b033d946533c1afc076f37b6f06b
ARG BUILD_EXT_RELEASE="1.32.7-alpine@sha256:f2da5d437e0c25f0a6f3a5283db74ed06dfcf4136f8db7cb17277506b1d30a5c"
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
        openssl=3.3.2-r4

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
