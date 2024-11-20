FROM quay.io/centos/centos:stream9 AS distr

ARG E1C_VERSION_MAJOR=8 \
    E1C_VERSION_MINOR=3 \
    E1C_VERSION_BUILD=23 \
    E1C_VERSION_PATCH=2157 \
    EDT_RELEASE=2023.3.5 \
    EDT_BUILD=10

RUN --mount=type=bind,source=server64_${E1C_VERSION_MAJOR}_${E1C_VERSION_MINOR}_${E1C_VERSION_BUILD}_${E1C_VERSION_PATCH}.tar.gz,target=/distr/platform.tar.gz \
    --mount=type=bind,source=1c_edt_distr_offline_${EDT_RELEASE}_${EDT_BUILD}_linux_x86_64.tar.gz,target=/distr/edt.tar.gz \
    mkdir -p /distr/platform/ /distr/edt/ && \
    tar -xf /distr/platform.tar.gz -C /distr/platform/ && \
    tar -xf /distr/edt.tar.gz -C /distr/edt/

FROM quay.io/centos/centos:stream9

ARG E1C_VERSION_MAJOR=8 \
    E1C_VERSION_MINOR=3 \
    E1C_VERSION_BUILD=23 \
    E1C_VERSION_PATCH=2157 \
    EDT_RELEASE=2023.3.5 \
    EDT_BUILD=10

LABEL description="Образ для сборки конфигураций и внешних обработок 1С"

ENV E1C_VERSION=${E1C_VERSION_MAJOR}.${E1C_VERSION_MINOR}.${E1C_VERSION_BUILD}.${E1C_VERSION_PATCH} \
    EDT_VERSION=${EDT_RELEASE}+${EDT_BUILD}

RUN --mount=type=cache,target=/var/cache,sharing=locked \
    --mount=type=tmpfs,target=/var/log \
    --mount=type=tmpfs,target=/var/tmp \
    yum install -y glibc-langpack-ru java-17-openjdk-headless xorg-x11-server-Xvfb 

ENV LANG=ru_RU.UTF-8

RUN --mount=type=bind,from=distr,source=/distr,target=/distr \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=tmpfs,target=/var/tmp \
    /distr/platform/setup-full-${E1C_VERSION}-x86_64.run --mode unattended --enable-components client_full,ru && \
    find /opt/1cv8 '(' -name libstdc++.so.6 -o -name 'libgcc_s.so.*' ')' -type f -delete && \
    /distr/edt/1ce-installer-cli install --ignore-hardware-checks

COPY xvfb.sh /etc/profile.d/

ENV PATH=${PATH}:/opt/1cv8/x86_64/${E1C_VERSION}
