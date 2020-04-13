#!/bin/bash

set -eu

sudo hostnamectl set-hostname ${domain}

sudo sed -i 's/.*localhost$/127.0.0.1 localhost '${domain}'/g' /etc/hosts

sudo tee -a /etc/systemd/system.conf <<EOT > /dev/null 
DefaultLimitNOFILE=65000
DefaultLimitNPROC=65000
DefaultTasksMax=65000
EOT
sudo systemctl daemon-reload

sudo apt install -y apt-transport-https

sudo tee /etc/apt/sources.list.d/jitsi-stable.list <<EOT > /dev/null 
deb https://download.jitsi.org stable/
EOT
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

sudo apt install -y nginx
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

cat <<EOT | sudo debconf-set-selections
jitsi-meet-web-config jitsi-meet/cert-choice             select Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)
jitsi-meet-web-config jitsi-meet/jvb-hostname            string ${domain}
jitsi-meet-turnserver jitsi-meet-turnserver/jvb-hostname string ${domain}
jitsi-videobridge2    jitsi-videobridge/jvb-hostname     string ${domain}
EOT

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jitsi-meet
