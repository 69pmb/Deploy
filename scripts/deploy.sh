#!/bin/bash
set -eo pipefail

project=$1
branch=$2
directory=$3
port=$4

buildBranch="main"
deployRepo="https://raw.githubusercontent.com/69pmb/Deploy"
deployFile="$deployRepo/$buildBranch/deploy-properties.json"
ngUrl="$deployRepo/$buildBranch/docker/ng-build/Dockerfile"
jUrl="$deployRepo/$buildBranch/docker/jbuild/Dockerfile"
ngDockerfile=$(curl -s $ngUrl)

# Mapping Docker Node alpine image by Angular version
declare -A NodeMap
NodeMap[10]=14.18.2-alpine3.12
NodeMap[11]=14.18.2-alpine3.12
NodeMap[12]=14.18.2-alpine3.12
NodeMap[13]=16.12.0-alpine3.12
NodeMap[14]=16.12.0-alpine3.12

function getNgArgVersion() {
    local version=$(echo $ngDockerfile | sed 's/ /\n/g' | grep -i ''"$1"'_version=' | cut -d = -f2)
    echo $version
}

function isBranchExist() {
    branches=$(git ls-remote -h --refs https://github.com/$1/$2 | cut -f2 | grep -v "snyk\|renovate\|dependabot" | cut -d/ -f3- | sort -r)
    local branch=$(echo $branches | grep -wi $3 | wc -l)
    echo $branch
}

function getAngularVersion() {
    package=$(curl -s "https://raw.githubusercontent.com/$1/$2/$3/package.json")
    local ngVersion=$(echo $package | jq '.dependencies["@angular/core"]' | sed 's/"//g' | cut -d. -f1 | sed 's/\^//g')
    echo $ngVersion
}

function isAngularProject() {
    local isNg=$(curl -s -I "https://raw.githubusercontent.com/$1/$2/$3/package.json" | grep -E "^HTTP" | awk -F " " '{print $2}')
    if [[ $isNg -eq 200 ]]
        then echo 1
        else echo 0
    fi
}

function getPort() {
  apps=$(echo $1 | jq '.apps[] | .name |= ascii_downcase')
  app_port=$(echo $apps | jq 'select(.name == '\"$2\"')' | grep port | cut -d: -f 2 | sed 's/,//g')
  if [[ -z $app_port ]]
  then echo 8080
  else echo $app_port
  fi
}

if [[ -z $project ]]
then 
    echo "Project is required"; 
    exit 1; 
fi 
if [[ -z $branch ]]
then 
    echo "Branch not provided, default is 'master'";
    branch="master"
fi
if [[ -z $directory ]]
then 
    echo "Directory not provided, default is '69pmb'";
    directory="69pmb"
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

clean_branch=$(echo $branch | sed -e "s/\//-/g")
cmdBuild="docker build --build-arg GITHUB_DIR=$directory --build-arg GITHUB_PROJECT=$project --build-arg GITHUB_HASH=$branch --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "
image=${project,,}.$clean_branch

isAngular=$(isAngularProject $directory $project $branch)
if [[ $isAngular -eq 1 ]]
then
    angularVersion=$(getAngularVersion $directory $project $branch)
    echo "Angular version detected: $angularVersion"
    
    node=${NodeMap[$angularVersion]} 

    nginx_version=$(getNgArgVersion "ng_nginx")
    cmdBuild+=" --build-arg NODE_VERSION=$node --build-arg NG_NGINX_VERSION=$nginx_version -t $image $ngUrl"
else 
    cmdBuild+=" -t $image $jUrl"
fi

echo -e "Building with the following command:\n$(echo $cmdBuild | sed 's/--/\n --/g' | sed 's/https/\n https/g')"
eval "$cmdBuild"

name=$(echo $image | cut -d : -f 1 | cut -d / -f 2 | cut -d . -f 1)
if [[ -z $port ]]
then 
    port=$(getPort "$apps" $name)
fi

cmdRun="docker run --name $name --restart unless-stopped -d -p $port:8080 -t $image"
echo -e "Running with the following command:\n$(echo $cmdRun | sed 's/--/\n --/g' | sed 's/https/\n https/g')"
docker ps -qaf "publish=$port" | xargs -r docker rm -f
docker ps -qaf "name=$name" | xargs -r docker rm -f
eval "$cmdRun"
