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

RUN apt-get install -y g++
RUN apt-get install -y g++-mingw-w64-x86-64
RUN apt-get install -y cmake make
RUN apt-get install -y git
RUN apt-get install -y vim

RUN apt-get install -y libsdl2-dev

ADD devkitPro /opt/devkitPro

###############################################################################
# Install Ox

RUN git clone https://github.com/wombatant/ox.git /usr/local/src/ox && \
    cd /usr/local/src/ox && \
    git checkout -b install 895e79d345bb14fa645096d95e749479f3fa7757

RUN mkdir -p \
             /usr/local/src/ox/build/release \
             /usr/local/src/ox/build/windows \
             /usr/local/src/ox/build/gba

# install Ox for native environment
RUN cd /usr/local/src/ox/build/release && \
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ../../ && \
    make -j install

# install Ox for GBA
RUN cd /usr/local/src/ox/build/gba && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON\
          -DCMAKE_TOOLCHAIN_FILE=cmake/Modules/GBA.cmake\
          -DCMAKE_INSTALL_PREFIX=/opt/devkitPro/devkitARM \
          -DOX_BUILD_EXEC=OFF ../../ && \
    make -j install

# install Ox for Windows
RUN cd /usr/local/src/ox/build/windows && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON\
          -DCMAKE_TOOLCHAIN_FILE=cmake/Modules/GBA.cmake\
          -DCMAKE_INSTALL_PREFIX=/usr/x86_64-w64-mingw32 \
          -DOX_BUILD_EXEC=OFF ../../ && \
    make -j install

###############################################################################
# Setup working directory

RUN mkdir /usr/src/project
WORKDIR /usr/src/project

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["make", "-j"]
