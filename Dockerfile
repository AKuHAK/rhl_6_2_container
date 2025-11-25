FROM centos:6

# 1) Fix repos to use vault.centos.org
RUN sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=http://vault.centos.org/6.10|g' /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && yum -y update

# 2) Base build tools (modern gcc only used as bootstrap)
RUN yum -y groupinstall "Development Tools" && \
    yum -y install wget bison flex texinfo git ncurses-devel

WORKDIR /root

# 3) Build *vintage* binutils
# Choose something around the era your toolchain expects, e.g. 2.11.2
RUN mkdir /tmp/build-binutils && \
    cd /tmp/build-binutils && \
    wget http://ftp.gnu.org/gnu/binutils/binutils-2.11.2.tar.gz && \
    tar xf binutils-2.11.2.tar.gz && \
    mkdir binutils-build && \
    cd binutils-build && \
    ../binutils-2.11.2/configure \
        --target=mipsel-linux \
        --prefix=/opt/vintage && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf /tmp/build-binutils

# 4) Build GCC 2.95.x (C only is usually enough for toolchains)
RUN mkdir /tmp/build-gcc && \
    cd /tmp/build-gcc && \
    wget http://ftp.gnu.org/gnu/gcc/gcc-2.95.3.tar.gz && \
    tar xf gcc-2.95.3.tar.gz && \
    mkdir gcc-build && \
    cd gcc-build && \
    PATH=/opt/vintage/bin:$PATH \
    ../gcc-2.95.3/configure \
        --target=mipsel-linux \
        --prefix=/opt/vintage \
        --without-headers \
        --enable-languages=c && \
    PATH=/opt/vintage/bin:$PATH make -j$(nproc) all-gcc && \
    PATH=/opt/vintage/bin:$PATH make install-gcc && \
    cd / && rm -rf /tmp/build-gcc

# Example: use /opt/vintage as the toolchain
ENV PATH=/opt/vintage/bin:$PATH

# You might need additional environment variables here, depending on the
# ps2-buildroot Makefile (e.g. CROSS_COMPILE=mipsel-linux-).
ENV CROSS_COMPILE=mipsEEel-linux-

# Default command: drop into shell with vintage toolchain in PATH
CMD ["/bin/bash"]
