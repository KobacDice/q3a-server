FROM alpine:latest
MAINTAINER kobacdice v1.1

# add the user that runs the process
RUN adduser ioq3srv -D

# to reduce image size all build and cleanup steps are performed in one docker layer
RUN \
  echo "# INSTALL DEPENDENCIES ##########################################" && \
  apk --no-cache add curl g++ gcc git make && \
  mkdir -p /tmp/build && \
  echo "# FETCH INSTALLATION FILES ######################################" && \
  curl https://raw.githubusercontent.com/ioquake/ioq3/master/misc/linux/server_compile.sh -o /tmp/build/compile.sh && \
  curl https://ioquake3.org/data/quake3-latest-pk3s.zip --referer https://ioquake3.org/extras/patch-data/ -o /tmp/build/quake3-latest-pk3s.zip && \
  curl https://www.excessiveplus.net/files/release/xp-2.3.zip -o /tmp/build/xp.zip && \
  curl https://www.excessiveplus.net/files/forum/2013/01/qlinsta_v1.8_3.zip -o /tmp/build/qlinsta.zip && \
  echo "# NOW THE INSTALLATION ##########################################" && \
  echo "y" | su ioq3srv -c "sh /tmp/build/compile.sh" && \
  unzip /tmp/build/quake3-latest-pk3s.zip -d /tmp/build/ && \
  unzip /tmp/build/xp.zip -d /tmp/build/ && \
  mkdir -p /tmp/build/qlinsta && \
  unzip /tmp/build/qlinsta.zip -d /tmp/build/qlinsta && \
  su ioq3srv -c "cp -r /tmp/build/quake3-latest-pk3s/* ~/ioquake3" && \
  su ioq3srv -c "cp -r /tmp/build/excessiveplus ~/ioquake3/" && \
  su ioq3srv -c "cp -r /tmp/build/qlinsta ~/ioquake3/excessiveplus/conf/" && \
  echo "# CLEAN UP ######################################################" && \
  apk del curl g++ gcc git make && \
  rm -rf /tmp/build/

RUN wget https://storage.googleapis.com/ioq3-data/ioq3-pak3.tar.bz2 -P / && \
    tar xvjf /ioq3-pak3.tar.bz2 -C /home/ioq3srv/ioquake3/baseq3/ 

#COPY pak*.pk3 /
#RUN ln -nfs /pak*.pk3 /home/ioq3srv/ioquake3/baseq3/

COPY *.cfg /
RUN mkdir -p /home/ioq3srv/.q3a/baseq3/ && \
    ln -nfs /*.cfg  /home/ioq3srv/.q3a/baseq3/

# Entrypoint
COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

USER ioq3srv

EXPOSE 27960/udp

ENTRYPOINT ["/entrypoint.sh"]
