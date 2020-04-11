#!/bin/bash

set -eu

sudo tee -a /etc/systemd/system.conf <<EOT > /dev/null 
DefaultLimitNOFILE=65000
DefaultLimitNPROC=65000
DefaultTasksMax=65000
EOT
sudo systemctl daemon-reload

sudo tee /etc/apt/sources.list.d/jitsi-stable.list <<EOT > /dev/null 
deb https://download.jitsi.org stable/
EOT
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo apt-get update

echo chef chef/chef_server_url string | sudo debconf-set-selections

sudo apt-get update \
&& sudo DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install jitsi-meet
