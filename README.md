# Build project to Cordova App

Builds and deploys Angular/Node.js apps into APK file using the `deploy.ps1` script and the `deploy-properties.json` file.

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
--build-arg ANGULAR_VERSION=angular_version \
--build-arg NG_NGINX_VERSION=ng_nginx_version \
--build-arg BUILD_DATE=build_date \
-t image_name https://raw.githubusercontent.com/69pmb/Deploy/main/docker/ng-build/Dockerfile
```

with the following parameters:

- `GITHUB_DIR`: the github profile of the project
- `GITHUB_PROJECT`: the github project name
- `GITHUB_HASH`: the git hash commit/branch of the project version to build
- `ANGULAR_VERSION`: project angular version
- `NG_NGINX_VERSION`: [ng-nginx](./docker/ng-nginx/Readme.md) version
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
