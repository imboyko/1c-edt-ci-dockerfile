FROM busybox AS distr

ARG JDK_DEB_URL=https://cdn.azul.com/zulu/bin/zulu17.56.15-ca-fx-jdk17.0.14-linux_amd64.deb

RUN --mount=type=bind,source=1cedt.tar.gz,target=/distr/1cedt.tar.gz \
    mkdir -p /distr/edt; \
    tar -xvf /distr/1cedt.tar.gz -C /distr/edt/

ADD ${JDK_DEB_URL} /distr/java/jdk.deb

FROM ubuntu:24.04

ARG EDT_VERSION=undefined

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache,sharing=locked \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    --mount=type=bind,from=distr,source=/distr,target=/distr \
    apt update; \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install --no-install-recommends -y /distr/java/jdk.deb libswt-gtk-4-java language-pack-ru; \
    update-locale LANG=ru_RU.UTF-8;

ENV JAVA_HOME=/usr/lib/jvm/zulu-fx-17-amd64

RUN --mount=type=bind,from=distr,source=/distr,target=/distr \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    /distr/edt/1ce-installer-cli install --ignore-hardware-checks --ignore-signature-warnings

ENV LANG=ru_RU.UTF-8
ENV PATH=${PATH}:/opt/1C/1CE/components/1c-edt-${EDT_VERSION}-x86_64
