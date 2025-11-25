# Base vintage environment
FROM centos:6

# Set environment variables
ENV PS2BUILDROOT=/opt/ps2-buildroot
ENV PATH=$PS2BUILDROOT:$PATH

# Install basic build tools
RUN yum -y groupinstall "Development Tools" && \
    yum -y install git wget bison flex texinfo python

# Clone the PS2 buildroot repo
RUN git clone https://github.com/jur/ps2-buildroot.git $PS2BUILDROOT

WORKDIR $PS2BUILDROOT

# Build everything
# Buildroot may include scripts to fetch vintage PS2 toolchains automatically


CMD ["/bin/bash"]
