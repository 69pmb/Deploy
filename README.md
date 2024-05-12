# Docker

Builds and deploys Angular/Node.js apps using [ng-build DockerFile](./docker/ng-build/Dockerfile).

## Scripts

You can use the `build.sh` and `run.sh` scripts to build docker images and to run containers of configured projects.

## Build

To build an docker image, run the following command:

```bash
docker build \
--build-arg GITHUB_DIR=user_id \
--build-arg GITHUB_PROJECT=project_id \
--build-arg GITHUB_HASH=commit_hash \
--build-arg NODE_VERSION=node_version \
--build-arg NG_NGINX_VERSION=ng_nginx_version \
--build-arg BUILD_DATE=build_date \
-t image_name https://raw.githubusercontent.com/69pmb/Deploy/main/docker/ng-build/Dockerfile
```

with the following parameters:

- `GITHUB_DIR`: the github profile of the project
- `GITHUB_PROJECT`: the github project name
- `GITHUB_HASH`: the git hash commit/branch of the project version to build
- `NODE_VERSION`: project node version, defaults to _16.13.1-alpine3.12_
- `NG_NGINX_VERSION`: [ng-nginx](./docker/ng-nginx/Readme.md) version, defaults to _latest_
- `BUILD_DATE`: adds a label with the build date
- `image_name`: your image name

## Run

Once the image built, you can run it with the following:

```bash
docker run --name my_name --restart unless-stopped -d -p my_port:8080 -t image_name
```

with the following parameters:

- `my_name`: container name
- `my_port`: the expose container port
- `image_name`: the previously specified image name
