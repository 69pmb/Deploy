## What is Ng-Nginx ?
The goal of this image is to serve a static site developed with Angular, NodeJS or plain JS on a Raspberry Pi.  
It is based on the [arm32v7/nginx](https://hub.docker.com/r/arm32v7/nginx/) image.

## How to use it ?

### Run it
Once your application is built, you can run a docker container using:  
```bash
docker run --name my-app -d -p my-port:8080 -v absolute-path-built-app:/usr/share/nginx/html -t pmb69/ng-nginx:0.1.1
```
If not running on a Raspberry, you can add for instance `--platform linux/arm/v7` to run it.  

### Build it
The nginx version is `1.21.3`.  
You can overwrite it by building your own docker image:  
```bash
docker build --build-arg ARM32V7_NGINX_VERSION=1.19.6-alpine -t ng-nginx https://raw.githubusercontent.com/69pmb/Deploy/main/docker/ng-nginx/Dockerfile
```
