#!/bin/bash

url="https://raw.githubusercontent.com/69pmb/Deploy/main/docker/ng-build/Dockerfile"
dockerfile=$(curl -s $url)

# Mapping latest Angular version by Major version
declare -A NgMap
NgMap[10]=10.2.5
NgMap[11]=11.2.14
NgMap[12]=12.2.16
NgMap[13]=13.3.5

# Mapping Docker Node alpine image by Angular version
declare -A NodeMap
NodeMap[10]=14.18.2-alpine3.12
NodeMap[11]=14.18.2-alpine3.12
NodeMap[12]=14.18.2-alpine3.12
NodeMap[13]=16.12.0-alpine3.12

function getArgVersion() {
  local version=$(echo $dockerfile | sed 's/ /\n/g' | grep -i ''"$1"'_version=' | cut -d = -f2)
  echo $version
}

function selectBranch() {
  echo "Which branch do you want to build ?" >&2
  branches=$(git ls-remote -h --refs https://github.com/$1/$2 | cut -f2 | grep -v "snyk\|renovate\|dependabot" | cut -d/ -f3- | sort -r)
  select branch in $branches "Manual"
  do
    echo $branch >&2
    let br;
    if [[ ! -z $branch ]]
    then
      br=$branch
      break;
    fi
  done
  echo "You have selected '$br'" >&2
  echo $br
}

function getPackage() {
  pack=$(curl -s "https://raw.githubusercontent.com/$1/$2/$3/package.json")
  local ngVersion=$(echo $pack | jq '.dependencies["@angular/core"]' | sed 's/"//g' | cut -d. -f1 | sed 's/\^//g')
  echo $ngVersion
}

let branch;
echo "Which project do you want to build ?"
select project in Dsm-Landing AllMovies NgMusic Manual
do
  let directory;
  if [[ ! -z $project ]]
  then
    echo $project
    if [[ $project == "Manual" ]]
    then
      let pj;
      while [ -z $pj ]
      do
        read -p "Which project ? " pj
      done
      project=$pj
      read -p "Enter the Github directory [69pmb]: " directory
    else
      echo "You have selected '$project'"
    fi
    directory=${directory:-69pmb}
    
    branch=$(selectBranch "$directory" "$project")
    if [[ $branch == "Manual" ]]
    then
      read -p "Enter the commit hash [master]: " br
      branch=${br:-master}
    fi

    package=$(getPackage $directory $project $branch)
    echo $package
    
    angular=${NgMap[$package]} 
    node=${NodeMap[$package]} 

    let nginx;
    nginx_version=$(getArgVersion "ng_nginx")
    read -p "Enter the pmb69/Ng-Nginx version [$nginx_version]: " nginx
    nginx=${nginx:-$nginx_version}
    
    break;
  else
    echo " You have entered wrong option, please choose the correct option from the listed menu."
  fi
done

cmd="docker build --build-arg GITHUB_DIR=$directory --build-arg GITHUB_PROJECT=$project --build-arg GITHUB_HASH=$branch --build-arg NODE_VERSION=$node --build-arg ANGULAR_VERSION=$angular --build-arg NG_NGINX_VERSION=$nginx --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" -t ${project,,}-$branch $url"

echo -e "Do you want to run the following command:\n$(echo $cmd | sed 's/--/\n  --/g' | sed 's/https/\n  https/g')"
let choice
while [ -z $choice ]
do
	read -p "[y/n] #? " choice
	if [[ $choice =~ ^(y|Y)([eE][sS])?$ ]]
	then 
	  echo $($cmd)
	elif [ ! -z $choice ]
	then 
	  echo "Do nothing"
	fi
done
