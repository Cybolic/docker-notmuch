FROM --platform=$TARGETPLATFORM alpine:3.13

ARG TARGETARCH
ARG TARGETPLATFORM
ARG TARGETVARIANT

ENV NOTMUCH_VERSION="0.29.3-r1" \
    CURL_VERSION="7.74.0-r1" \
    CA_CERTIFICATES_VERSION="20191127-r5" \
    PROCPS_VERSION="3.3.16-r0" \
    BASH_VERSION="5.1.0-r0"

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
      notmuch="${NOTMUCH_VERSION}" \
      ca-certificates="${CA_CERTIFICATES_VERSION}" \
      curl="${CURL_VERSION}" \
      procps="${PROCPS_VERSION}" \
      bash="${BASH_VERSION}" \
 && addgroup notmuch \
 && adduser notmuch -G notmuch -D -h /workdir

ENV SUPERCRONIC_VERSION=v0.1.12
ENV SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
    SUPERCRONIC="supercronic-linux-${TARGETARCH}" \
    SUPERCRONIC_SHA1SUM="SUPERCRONIC_SHA1SUM_${TARGETARCH}" \
    SUPERCRONIC_SHA1SUM_amd64="048b95b48b708983effb2e5c935a1ef8483d9e3e" \
    SUPERCRONIC_SHA1SUM_arm64="8baba3dd0b0b13552aca179f6ef10d55e5dee28b" \
    SUPERCRONIC_SHA1SUM_arm="d72d3d40065c0188b3f1a0e38fe6fecaa098aad5"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -fsSLO "${SUPERCRONIC_URL}" \
 && echo "${!SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
 && chmod +x "${SUPERCRONIC}" \
 && mv "${SUPERCRONIC}" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

COPY crontab /etc/crontab

USER notmuch

CMD /usr/local/bin/supercronic /etc/crontab

ARG CREATED
ARG REVISION=HEAD

LABEL org.opencontainers.image.source=https://github.com/cybolic/docker-notmuch
