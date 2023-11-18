# syntax=docker/dockerfile:1

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.3.1
ARG BUILD_EXT_RELEASE="1.30.0-alpine"

FROM ghcr.io/dani-garcia/vaultwarden:${BUILD_EXT_RELEASE} as source
FROM ${BUILD_FROM} as release

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL build_version="Chukyserver.io version:- ${BUILD_VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chukysoria"

ENV ROCKET_PROFILE="release" \
    ROCKET_ADDRESS=0.0.0.0 \
    ROCKET_PORT=80 \
    SSL_CERT_DIR=/etc/ssl/certs

# Create data folder and Install needed libraries
RUN mkdir /app/vw && \
    mkdir /app/vw/data && \
    apk --no-cache add \
        openssl=3.1.4-r1

# Copies the files from the context (Rocket.toml file and web-vault)
# and the binary from the "build" stage to the current stage
COPY --from=source /web-vault /app/vw/web-vault
COPY --from=source /vaultwarden /app/vw/vaultwarden

# copy local files
COPY root/ /

VOLUME /app/vw/data
EXPOSE 80
EXPOSE 3012
