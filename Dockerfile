FROM ubuntu:latest

ENV DEVKITPRO /opt/devkitPro
ENV DEVKITARM ${DEVKITPRO}/devkitARM

RUN apt-get update
RUN apt-get install -y make cmake

ADD devkitPro /opt/devkitPro

RUN mkdir /usr/src/project
WORKDIR /usr/src/project

CMD ["make", "-j"]
