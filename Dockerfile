FROM centos:6

# Replace repos with vault.centos.org
RUN sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://vault.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo && \
    yum clean all && yum -y update

# Install build tools
RUN yum -y groupinstall "Development Tools" && \
    yum -y install git wget bison flex texinfo python

# Clone PS2 Buildroot
RUN git clone https://github.com/jur/ps2-buildroot.git /opt/ps2-buildroot
WORKDIR /opt/ps2-buildroot

CMD ["/bin/bash"]
