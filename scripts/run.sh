#!/bin/bash

function getPort() {
  apps_url=$(curl -s "https://raw.githubusercontent.com/69pmb/Deploy/main/deploy-properties.json")
  apps=$(echo $apps_url | jq '.apps[] | .name |= ascii_downcase')
  app_port=$(echo $apps | jq 'select(.name == '\"$1\"')' | grep port | cut -d: -f 2 | sed 's/,//g')
  if [[ -z $app_port ]]
  then echo 8080
  else echo $app_port
  fi
}

select image in $(docker images --format '{{.Repository}}:{{.Tag}}' -f dangling=false | sort)
do
  if [[ ! -z $image ]]
  then
    echo "You have selected '$image'"
    name=$(echo $image | cut -d : -f 1 | cut -d / -f 2 | cut -d . -f 1)

    let port
    conf_port=$(getPort $name)
    read -p "Enter the exposed port [$conf_port]: " port
    port=${port:-$conf_port}

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
then cmd="$cmd_start $cmd_end"
else
  cmd="$cmd_start --env-file $env $cmd_end"
fi

echo -e "Do you want to run the following command:\n$cmd"
let choice
while [ -z $choice ]
do
	read -p "[y/n] #? " choice
	if [[ $choice =~ ^(y|Y)([eE][sS])?$ ]]
	then 
    docker ps -qaf "publish=$port" | xargs -r docker rm -f
    docker ps -qaf "name=$name" | xargs -r docker rm -f
    eval "$cmd"
	elif [ ! -z $choice ]
	then 
    echo "Do nothing"
	fi
done
