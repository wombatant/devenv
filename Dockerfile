FROM fedora:25

ENV DEVKITPRO /opt/devkitPro
ENV DEVKITARM ${DEVKITPRO}/devkitARM

RUN dnf update -y

###############################################################################
# Install gosu

RUN dnf install -y curl gnupg
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

###############################################################################
# Install dev tools

RUN dnf install -y clang \
                   llvm \
                   libasan \
                   mingw64-gcc-c++ \
                   cmake make \
                   git \
                   vim \
                   sudo
ADD devkitPro /opt/devkitPro

# Install Qt Libraries

RUN dnf install -y qt5-devel

###############################################################################
# Install GBA emulator

RUN dnf install -y vbam-gtk

###############################################################################
# Setup sudoers

ADD etc/sudoers /etc/sudoers

###############################################################################
# Setup working directory

RUN mkdir /usr/src/project
WORKDIR /usr/src/project

###############################################################################
# Setup entrypoint

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
