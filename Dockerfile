FROM centos:6

# 1) Fix repos to use vault.centos.org
RUN sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=http://vault.centos.org/6.10|g' /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && yum -y update && yum -y groupinstall "Development Tools" && \
    yum -y install wget bison flex texinfo git ncurses-devel && \
    yum -y install glibc.i686 libstdc++.i686

WORKDIR /root

# Example: use /opt/vintage as the toolchain
ENV PATH=/opt/vintage/bin:$PATH

# You might need additional environment variables here, depending on the
# ps2-buildroot Makefile (e.g. CROSS_COMPILE=mipsel-linux-).
ENV CROSS_COMPILE=mipsEEel-linux-

# Default command: drop into shell with vintage toolchain in PATH
CMD ["/bin/bash"]
