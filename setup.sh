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

cat <<EOT | sudo debconf-set-selections
jitsi-videobridge2 jitsi-videobridge/jvb-hostname string $DOMAIN
jitsi-meet-web-config jitsi-meet/cert-choice string Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)
jitsi-meet-web-config jitsi-meet/cert-path-crt string /etc/ssl/$DOMAIN.crt
jitsi-meet-web-config jitsi-meet/cert-path-key string /etc/ssl/$DOMAIN.key
jitsi-meet-web-config jitsi-videobridge/jvb-hostname string $DOMAIN
jitsi-meet-web-config jitsi-meet/jvb-hostname string $DOMAIN
EOT

sudo DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install jitsi-meet
