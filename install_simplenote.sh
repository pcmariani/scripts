#!/usr/bin/env sh

downloadpage='https://github.com/Automattic/simplenote-electron/releases'
downloadurl=$(curl -s $downloadpage | grep -o -m 1 '\".*amd64.deb' | sed 's/\"/https:\/\/github.com/')
filename=$(echo $downloadurl | sed 's/^.*\///')

sudo apt install gconf2

pushd '.'
cd /tmp/
curl -O -L $downloadurl 
sudo dpkg -i $filename
popd
