FROM centos:6

# Use vault.centos.org for CentOS 6 EOL
RUN sed -i 's|mirrorlist=http://mirrorlist.centos.org|#mirrorlist=http://mirrorlist.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org/centos/\$releasever|baseurl=http://vault.centos.org/6.10|g' /etc/yum.repos.d/CentOS-Base.repo && \
    yum clean all && yum -y update

# Install build tools
RUN yum -y groupinstall "Development Tools" && \
    yum -y install git wget bison flex texinfo python

CMD ["/bin/bash"]
