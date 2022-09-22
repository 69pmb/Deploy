## What is Ng-Cli ?

The goal of this image is to provide the [Angular cli](https://angular.io/cli) in a Docker container.  
The image is based on [node's official image](https://hub.docker.com/_/node), npm and git is also provided.

## How to use it ?

# Build it

You can overwrite the angular or the node version by building your own docker image:

```bash
docker build --build-arg NODE_VERSION=14.18.2-alpine3.12 --build-arg ANGULAR_VERSION=12 --build-arg BUILD_DATE="2022-09-23T09:18:48Z" -t ng-cli .
```

# Use it

You can use this image for instance to build an Angular project in a Dockerfile:  
`FROM pmb69/ng-cli:${ANGULAR_VERSION} AS builder`

Here is the mapping between the Docker Node alpine image with the Angular version:

| Angular version |       Node version |
| :-------------- | -----------------: |
| 10              | 14.18.2-alpine3.12 |
| 11              | 14.18.2-alpine3.12 |
| 12              | 14.18.2-alpine3.12 |
| 13              | 16.12.0-alpine3.12 |
| 14              | 16.12.0-alpine3.12 |
