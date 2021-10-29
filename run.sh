#!/bin/bash

select image in $(docker images --format '{{.Repository}}:{{.Tag}}' -f dangling=false | sort)
do
  if [[ ! -z $image ]]
  then
    echo "You have selected '$image'"
    name=$(echo $image | cut -d : -f 1 | rev | cut -d / -f 1 | rev)

    let port
    read -p "Enter the exposed port [8080]: " port
    port=${port:-8080}

    let env
    read -p "Enter the env file [Empty for no file]: " env

    break;
  else
    echo "There is no image associated with this number, try again !"
  fi
done

cmd_start="docker run --name $name"
cmd_end="--restart unless-stopped -d -p $port:8080 -t $image"
let cmd
if [[ -z $env || ! -e $env || ! -f $env ]]
then cmd="$cmd_start$cmd_end"
else
  cmd="$cmd_start --env $env $cmd_end"
fi

echo -e "Do you want to run the following command:\n$cmd"
read -p "[y/n] #? " choice
if [[ $choice =~ ^(y|Y)([eE][sS])?$ ]]
then $($cmd)
else
  echo "Do nothing"
fi
