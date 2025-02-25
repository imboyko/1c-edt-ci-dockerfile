# Распаковка дистрибутива платформы
FROM busybox AS distr

RUN --mount=type=bind,source=1cplatform.zip,target=/distr/1cplatform.zip \
    unzip /distr/1cplatform.zip -d /distr/platform/

FROM ubuntu:22.04

ARG PLATFORM_VERSION=undefined

RUN --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/var/cache,sharing=locked \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    apt update; \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install --no-install-recommends -y xvfb libwebkit2gtk-4.0-37 language-pack-ru; \
    update-locale LANG=ru_RU.UTF-8;

ENV LANG=ru_RU.UTF-8

RUN --mount=type=bind,from=distr,source=/distr,target=/distr \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    /distr/platform/setup-full-${PLATFORM_VERSION}-x86_64.run --mode unattended --enable-components client_full,ru; \
    find /opt/1cv8 '(' -name libstdc++.so.* -o -name 'libgcc_s.so.*' ')' -delete

ENV PATH=${PATH}:/opt/1cv8/x86_64/${PLATFORM_VERSION}
