# q3a-server
quake 3 server setup repo

ln -nfs /root/q3a-server/*.cfg ~/.q3a/baseq3/

## Build

```
docker build -t q3a-server .
```

## Run

```
docker run -it -p 27960:27960/udp q3a-server server
