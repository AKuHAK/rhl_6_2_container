# Stage 0: Download RPMs
FROM centos:6

RUN yum install -y rpm yum && yum clean all

ARG WORK_DIR="/root"
ARG BUILD_DIR="/build"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN mkdir -p "${WORK_DIR}" "${BUILD_DIR}"

WORKDIR "${WORK_DIR}"

# Base URL for Red Hat 6.2 i386 RPMS
ENV RH6_BASE_URL="https://legacy.redhat.com/pub/redhat/linux/6.2/en/os/i386/RedHat/RPMS"

# List of RPMs to download
ENV RH6_RPMS="MAKEDEV-2.5.2-1.noarch.rpm \
    SysVinit-2.78-5.i386.rpm \
    anacron-2.1-6.i386.rpm \
    apmd-3.0final-2.i386.rpm \
    ash-0.2-20.i386.rpm \
    at-3.1.7-14.i386.rpm \
    bash-1.14.7-22.i386.rpm \
    binutils-2.9.5.0.22-6.i386.rpm"

# Download RPMs
RUN apt-get update && apt-get install -y curl && \
    for rpm in $RH6_RPMS; do \
        curl -LO "${RH6_BASE_URL}/$rpm"; \
    done

# Stage 1: Install RPMs into a filesystem
FROM ghcr.io/uyjulian/rhl_6_2_container:latest AS builder

ARG WORK_DIR="/root"
ARG BUILD_DIR="/build"

RUN mkdir -p "${BUILD_DIR}/var/lib/rpm" && \
    rpm --root "${BUILD_DIR}/" --initdb

COPY --from=downloader "${WORK_DIR}" "${WORK_DIR}"

WORKDIR "${WORK_DIR}"

# Install all downloaded RPMs ignoring architecture
RUN rpm --verbose --root "${BUILD_DIR}/" --install --ignorearch *.i386.rpm *.noarch.rpm

# Stage 2: Final minimal container
FROM scratch

COPY --from=builder "/build" "/"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

LABEL org.opencontainers.image.source="https://github.com/uyjulian/rhl_6_2_container" \
      maintainer="Julian Uy <https://uyjulian.github.io/>" \
      vendor="uyjulian" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="ghcr.io/uyjulian/rhl_6_2_container" \
      org.label-schema.description="Red Hat Linux 6.2 Container" \
      org.label-schema.url="https://uyjulian.github.io/" \
      org.label-schema.vcs-url="https://github.com/uyjulian/rhl_6_2_container" \
      org.label-schema.vendor="uyjulian" \
      org.label-schema.version="6.2"

CMD ["/bin/bash"]
