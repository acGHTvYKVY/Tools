#!/bin/bash

sudo apt update
sudo apt install snapd
sudo systemctl enable --now snapd.socket
sudo snap install multipass
multipass --version
wget https://pcdn.titannet.io/test4/bin/agent-linux.zip
mkdir -p /root/titanagent
unzip agent-linux.zip -d /root/titanagent
rm -rf agent-linux.zip
