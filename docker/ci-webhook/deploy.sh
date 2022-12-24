#!/bin/bash
set -eo pipefail

## Script's arguments
project=$1
branch=$2
args=$3
directory=$4
port=$5

## Constants
buildBranch="main"
deployRepo="https://raw.githubusercontent.com/69pmb/Deploy"
deployFile="$deployRepo/$buildBranch/deploy-properties.json"
ngUrl="$deployRepo/$buildBranch/docker/ng-build/Dockerfile"
jUrl="$deployRepo/$buildBranch/docker/jbuild/Dockerfile"
ngDockerfile=$(curl -s $ngUrl)
keySeparator="@"
valueSeparator=","

# Mapping Docker Node alpine image by Angular version
declare -A NodeMap
NodeMap[10]=14.18.2-alpine3.12
NodeMap[11]=14.18.2-alpine3.12
NodeMap[12]=14.18.2-alpine3.12
NodeMap[13]=16.12.0-alpine3.12
NodeMap[14]=16.12.0-alpine3.12

# Find docker file argument value
function getArgVersion() {
    local version=$(echo $ngDockerfile | sed 's/ /\n/g' | grep -i ''"$1"'_version=' | cut -d = -f2)
    echo $version
}

# Test if branch exist in project
function isBranchExist() {
    branches=$(git ls-remote -h --refs https://github.com/$1/$2 | cut -f2 | grep -v "snyk\|renovate\|dependabot" | cut -d/ -f3- | sort -r)
    local branch=$(echo $branches | grep -wi $3 | wc -l)
    echo $branch
}

# Find Angular version used in project
function getAngularVersion() {
    package=$(curl -s "https://raw.githubusercontent.com/$1/$2/$3/package.json")
    local ngVersion=$(echo $package | jq '.dependencies["@angular/core"]' | sed 's/"//g' | cut -d. -f1 | sed 's/\^//g')
    echo $ngVersion
}

# Test if project is an Angular one
function isAngularProject() {
    local isNg=$(curl -s -I "https://raw.githubusercontent.com/$1/$2/$3/package.json" | grep -E "^HTTP" | awk -F " " '{print $2}')
    if [[ $isNg -eq 200 ]]
        then echo 1
        else echo 0
    fi
}

# Find port in property file
function getPort() {
  apps=$(echo $1 | jq '.apps[] | .name |= ascii_downcase')
  app_port=$(echo $apps | jq 'select(.name == '\"$2\"')' | grep port | cut -d: -f 2 | sed 's/,//g')
  if [[ -z $app_port ]]
  then echo 8080
  else echo $app_port
  fi
}

# Validate & process arguments
if [[ -z $project ]]
then
    echo "Project is required";
    exit 1;
fi
if [[ -z $branch ]]
then
    branch="master"
    echo "Branch not provided, default is '$branch'";
fi
clean_branch=$(echo $branch | sed -e "s/\//-/g")
if [[ -z $directory ]]
then
    if [[ $(echo $project | grep '/' | wc -l) -eq 1 ]]
    then
        directory=$(echo $project | cut -d "/" -f1)
        project=$(echo $project | cut -d "/" -f2)
    else
        directory="69pmb"
        echo "Directory not provided, default is '$directory'";
    fi
fi

apps=$(curl -s $deployFile)
names=$(echo $apps | jq .apps[].name | sed 's/"//g')
if [[ ! $(echo $names | grep -wi $project | wc -l) -eq 1 ]]
then
    echo "Specified project '$project' is not recognized"
    exit 1;
fi
isBrExist=$(isBranchExist "$directory" "$project" "$branch")
if [[ $isBrExist -eq 0 ]]
then
    echo "Specified branch '$branch' does not exist on project '$project'"
    exit 1;
fi

# Build docker image
cmdBuild="docker build --build-arg GITHUB_DIR=$directory --build-arg GITHUB_PROJECT=$project --build-arg GITHUB_HASH=$branch --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "
image=${project,,}.$clean_branch

isAngular=$(isAngularProject $directory $project $branch)
if [[ $isAngular -eq 1 ]]
then
    angularVersion=$(getAngularVersion $directory $project $branch)
    echo "Angular version detected: $angularVersion"
   
    node=${NodeMap[$angularVersion]}

    nginx_version=$(getArgVersion "ng_nginx")
    cmdBuild+=" --build-arg NODE_VERSION=$node --build-arg NG_NGINX_VERSION=$nginx_version -t $image $ngUrl"
else
    cmdBuild+=" -t $image $jUrl"
fi

echo -e "Building with the following command:\n$(echo $cmdBuild | sed 's/--/\n --/g' | sed 's/https/\n https/g')"
eval "$cmdBuild"

# Run the docker image
name=$(echo $image | cut -d : -f 1 | cut -d / -f 2 | cut -d . -f 1)
compose=$(curl -s https://raw.githubusercontent.com/$directory/$project/$branch/docker-compose.yml)
if [[ $(echo $compose  | grep 404 | wc -l) -eq 1 ]]
then
    # no docker compose file, using regular "docker run" command
    if [[ -z $port ]]
    then
        port=$(getPort "$apps" $name)
    fi
    cmdRun="docker run --name $name --restart unless-stopped -d -p $port:8080 -t $image"
    echo -e "Running with the following command:\n$(echo $cmdRun | sed 's/--/\n --/g' | sed 's/https/\n https/g')"
    docker ps -qaf "publish=$port" | xargs -r docker rm -f
    docker ps -qaf "name=$name" | xargs -r docker rm -f
    eval "$cmdRun"
else
    # using docker compose file to run the project
    for i in $(echo $args | tr "$keySeparator" "\n")
    do
        key=$(echo $i | cut -d $valueSeparator -f 1)
        value=$(echo $i | cut -d $valueSeparator -f 2)
        compose=$(echo "$compose" | sed "s/{{$key}}/$value/")
    done
    compose=$(echo "$compose" | sed "s/image: $name[a-z\.]*/image: $image/")
    docker ps -aqf 'label=com.docker.compose.project=$project' | xargs -r docker rm -f
    echo "$compose" > docker-compose.yml
    env COMPOSE_PROJECT_NAME=$project docker compose up -d
fi
