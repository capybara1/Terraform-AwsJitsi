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
sudo apt-get update &>> ~/install_log

sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

sudo apt install -y nginx &>> ~/install_log
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

cat <<EOT | LANG=C.UTF-8 sudo debconf-set-selections
jitsi-meet-web-config jitsi-meet/cert-choice         select Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)
jitsi-videobridge2    jitsi-videobridge/jvb-hostname string ${domain}
EOT

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y jitsi-meet &>> ~/install_log

echo "${email}" | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh &>> ~/install_log
