#!/bin/bash

select project in Dsm-Landing AllMovies NgMusic
do
  if [[ ! -z $project ]]
  then
    echo "You have selected '$project'"

    let directory;
    read -p "Enter the Github directory [69pmb]: " directory
    directory=${directory:-69pmb}
    
    let hash;
    read -p "Enter the Github commit Hash [master]: " hash
    hash=${hash:-master}
    
    break;
  else
    echo " You have entered wrong option, please choose the correct option from the listed menu."
  fi
done

cmd="docker build --build-arg GITHUB_DIR=$directory --build-arg GITHUB_PROJECT=$project --build-arg GITHUB_HASH=$hash -t ${project,,} https://raw.githubusercontent.com/69pmb/Deploy/main/docker/ng-build/Dockerfile"

echo -e "Do you want to run the following command:\n$cmd"
read -p "[y/n] #? " choice
if [[ $choice =~ ^(y|Y)([eE][sS])?$ ]]
then $($cmd)
else
  echo "Do nothing"
fi
