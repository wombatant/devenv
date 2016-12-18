FROM ubuntu:16.04

ENV DEVKITPRO /opt/devkitPro
ENV DEVKITARM ${DEVKITPRO}/devkitARM

RUN apt-get update --fix-missing
RUN apt-get install -y clang cmake make git curl
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture)" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.4/gosu-$(dpkg --print-architecture).asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

ADD devkitPro /opt/devkitPro
RUN git clone https://github.com/wombatant/ox.git /usr/local/src/ox && \
    cd /usr/local/src/ox && \
    git checkout -b install 02bbd75606b985069d514a617dbd07b3ecfacc0c
RUN mkdir -p /usr/local/src/ox/build/release /usr/local/src/ox/build/gba

# install Ox
RUN cd /usr/local/src/ox/build/release && \
    cmake ../../ && \
    make -j install

# install Ox for GBA
RUN cd /usr/local/src/ox/build/gba && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON\
          -DCMAKE_TOOLCHAIN_FILE=cmake/Modules/GBA.cmake\
          -DOX_BUILD_EXEC=OFF ../../ && \
    make -j install DESTDIR=/opt/devkitPro/devkitARM

RUN mkdir /usr/src/project
WORKDIR /usr/src/project

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["make", "-j"]
