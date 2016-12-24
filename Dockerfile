FROM debian:8

ENV DEVKITPRO /opt/devkitPro
ENV DEVKITARM ${DEVKITPRO}/devkitARM

RUN apt-get update

###############################################################################
# Install gosu

RUN apt-get install -y curl
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

###############################################################################
# Install dev tools

RUN apt-get install -y g++ \
                       g++-mingw-w64-x86-64 \
                       cmake make \
                       git \
                       vim \
                       sudo
ADD devkitPro /opt/devkitPro


ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["make", "-j"]
