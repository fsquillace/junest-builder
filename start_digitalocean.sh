#!/bin/bash
# Usage: ./start TOKEN IMAGE_ID SSH_ID ARCH
# i.e. ./start w2390jabafoijfewaefmp2 66666 x86_64

TOKEN=$1
IMAGE_ID=$2
SSH_ID=$3
ARCH=$4

set -eu

ENDPOINT="https://api.digitalocean.com/v2/droplets"

echo "Creating droplet with image id:${IMAGE_ID}..."
ID=$(curl -sX POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${TOKEN}" -d "{\"name\":\"arch\",\"region\":\"ams3\",\"size\":\"512mb\",\"image\":${IMAGE_ID},\"ssh_keys\":[${SSH_ID}],\"backups\":false,\"ipv6\":false,\"user_data\":null,\"private_networking\":null}" "${ENDPOINT}" | jq .droplet.id)
echo "Created droplet ${ID}"

trap "echo \"Deleting droplet with id: ${ID}...\" && curl -sX DELETE -H 'Content-Type: application/json' -H \"Authorization: Bearer ${TOKEN}\" \"${ENDPOINT}/${ID}\" && echo \"Deleted droplet\"" EXIT QUIT ABRT KILL TERM INT

echo "Getting the droplet ip..."
STATUS="new"
while [ "${STATUS}" != "active" ]
do
    IP=$(curl -sX GET -H 'Content-Type: application/json' -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/${ID}" | jq .droplet.networks.v4[0].ip_address | sed -e 's/\"//g')
    STATUS=$(curl -sX GET -H 'Content-Type: application/json' -H "Authorization: Bearer ${TOKEN}" "${ENDPOINT}/${ID}" | jq .droplet.status | sed -e 's/\"//g')
    echo "Current droplet status: $STATUS"
    sleep 10
done
echo "Got droplet ip: ${IP}"

sleep 15

echo "Setting up the builder user..."
ssh -o "StrictHostKeyChecking no" -i ~/.ssh/digitalocean_rsa root@${IP} -- /usr/bin/sh << EOF
    curl -k https://raw.githubusercontent.com/fsquillace/junest-builder/master/setup_builder.sh | bash
EOF

echo "Building JuNest image..."
ssh -o "StrictHostKeyChecking no" -i ~/.ssh/digitalocean_rsa builder@${IP} -- /usr/bin/sh << EOF
    sudo git clone https://github.com/fsquillace/junest-builder.git /opt/junest-builder
    /opt/junest-builder/build_image.sh $ARCH
EOF
