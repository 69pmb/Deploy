# Building Docker images

Builds and deploys Angular apps using [ng-build DockerFile](./docker/ng-build/Dockerfile).  
Builds and deploys Java apps using [jbuild DockerFile](./docker/jbuild/Dockerfile).

## Scripts

You can use the _[build.sh](./scripts/build.sh)_ and _[run.sh](./scripts/run.sh)_ scripts to ease the launch of building docker images and running containers of configured projects (see _[deploy-properties.json](./deploy-properties.json)_).

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
- `BUILD_DATE`: adds a label with the build date to the Docker image
- `image_name`: your image name

Only for Angular apps:

- `NODE_VERSION`: project node version, defaults to _16.13.1-alpine3.12_
- `NG_NGINX_VERSION`: [ng-nginx](./docker/ng-nginx/Readme.md) version, defaults to _latest_
- `ENV_VAR`: use `envsubst` to substitute variables in project's `assets/configuration.json`

## Run

Once the image built, you can run it with the following:

```bash
docker run --name my_name --restart unless-stopped -d -p my_port:8080 -t image_name
```

with the following parameters:

- `my_name`: container name
- `my_port`: the expose container port
- `image_name`: the previously specified image name

# WebHook

It is based on the [TheCatLady/docker-webhook](https://github.com/TheCatLady/docker-webhook) image to containarized [webhook](https://github.com/adnanh/webhook).  
It adds a triggerable _Deploy_ hook to build and launch a Docker image of an application.

The webhook's image can be built with `docker build -t ci-webhook .` and be run with `docker-compose up -d`.

Then the deploy hook is available at `localhost:9900/hooks/deploy` and can be triggered with these arguments:

1. The project name
1. The branch to build
1. Arguments, to be used in docker-compose or configuration file
1. Directory
1. Port number

**RAF**
docker-compose
args
project/dir
deploy-prop


# Workflows

# Build project to Cordova App (Deprecated)

Builds and deploys Angular/Node.js apps into APK file using the _[deploy.ps1](./deploy.ps1)_ script and the _[deploy-properties.json](./deploy-properties.json)_ file.

## Params

| Param     | Description                                             |      Required      |  Type  |
| :-------- | :------------------------------------------------------ | :----------------: | :----: |
| java_path | Java 8 path to used to build APK file                   | Only for _cordova_ |  Path  |
| outputDir | Target folder where the generated APK will be deposited | Only for _cordova_ |  Path  |
| apps      | Array of apps                                           |                    |   []   |
| app.name  | Name of the folder app                                  |        Yes         | String |
| app.size  | Minimum size in _KB_ of the APK file                    | Only for _cordova_ | Number |
| app.port  | Application port on the server                          | Only for _docker_  | Number |

## Steps

_Cordova_ steps:

1. `npm run cordova` to build the app with a specific _base-href_
1. `cordova build android` generating the APK file
1. Renames the file by `app.name_YYYY.MM.dd'T'HH.mm.ss.apk`
1. Moves it to the specify `app.outputDir`
1. Tests if its size is greater than `app.size`
