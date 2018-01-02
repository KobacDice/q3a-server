# q3a-server
quake 3 server setup repo

## Docker Build

```
docker build -t q3a-server .
```

## Docker Run

```
docker run -it -p 27960:27960/udp q3a-server server

or

docker run -it -d --name q3a-server-runner -p 27960:27960/udp q3a-server:latest server
```

## docker push to aws ecs
```
ln -nfs circle-aws.yml circle.yml
```
In order to deploy AWS ECS
you should create q3a-server-cluster and q3a-server-service

## docker push to gcp gcr
```
ln -nfs circle-gcp.yml circle.yml
```
