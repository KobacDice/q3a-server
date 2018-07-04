FROM alpine:latest
MAINTAINER kobacdice v1.1

# add the user that runs the process
RUN adduser ioq3srv -D

# to reduce image size all build and cleanup steps are performed in one docker layer
COPY server_compile.sh /

RUN \
  apk --no-cache add curl g++ gcc git make && \
  echo "y" | su ioq3srv -c "sh /server_compile.sh" && \
  apk del curl g++ gcc git make

RUN wget https://s3-ap-northeast-1.amazonaws.com/ioq3-data/ioq3-pak3.tar.bz2 -P / && \
    tar xvjf /ioq3-pak3.tar.bz2 -C /home/ioq3srv/ioquake3/baseq3/

COPY *.cfg /
RUN mkdir -p /home/ioq3srv/.q3a/baseq3/ && \
    ln -nfs /*.cfg  /home/ioq3srv/.q3a/baseq3/

# Entrypoint
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

USER ioq3srv

EXPOSE 27960/udp

ENTRYPOINT ["/entrypoint.sh"]
