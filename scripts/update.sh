#!/bin/bash

function update() {
    if [ -L "$1" ] ; then rm $1.sh ; fi
    wget -q --no-cache https://raw.githubusercontent.com/69pmb/Deploy/main/scripts/$1.sh
    chmod +x $1.sh
    if [ -L "/usr/bin/$1" ] ; then sudo rm /usr/bin/$1 ; fi
    sudo ln -s ~/workspace/$1.sh /usr/bin/$1
}

cd ~/workspace
update "run"
update "build"
