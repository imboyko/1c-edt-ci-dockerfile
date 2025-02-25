FROM busybox AS distr

RUN --mount=type=bind,source=1cedt.tar.gz,target=/distr/1cedt.tar.gz \
    mkdir -p /distr/edt/; \
    tar -xvf /distr/1cedt.tar.gz -C /distr/edt/

FROM ubuntu:24.04

ARG EDT_VERSION=undefined
ARG EDT_BUILD=undefined

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache,sharing=locked \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    apt update; \
    apt install --no-install-recommends -y openjdk-17-jdk-headless language-pack-ru; \
    update-locale LANG=ru_RU.UTF-8;

ENV LANG=ru_RU.UTF-8

RUN --mount=type=bind,from=distr,source=/distr,target=/distr \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    /distr/edt/1ce-installer-cli install --ignore-hardware-checks --ignore-signature-warnings

ENV PATH=${PATH}:/opt/1C/1CE/components/1c-edt-${EDT_VERSION}+${EDT_BUILD}-x86_64
