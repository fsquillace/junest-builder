#!/bin/bash
# Usage: ./start TOKEN IMAGE_ID ORGANIZATION_ID ARCH
# i.e. ./start w2390jabafoijfewaefmp2 33333 343240-34-23-4 x86_64

TOKEN=$1
IMAGE_ID=$2
ORGANIZATION=$3
ARCH=$4

set -eu

ENDPOINT="https://api.cloud.online.net"

echo "Creating server with image id:${IMAGE_ID}..."
ID=$(curl -sX POST -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -d "{\"name\":\"arch\",\"image\":\"${IMAGE_ID}\",\"organization\":\"${ORGANIZATION}\"}" "${ENDPOINT}/servers" | jq .server.id)

echo "Created droplet ${ID}"

trap "echo \"Deleting server with id: ${ID}...\" && curl -sX DELETE -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" \"${ENDPOINT}/servers/${ID}\" && echo \"Deleted server\"" EXIT QUIT ABRT KILL TERM INT

echo "Getting the server ip..."
curl -sX POST -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" -d "{\"action\":\"poweron\"}" "${ENDPOINT}/servers/${ID}/action"

STATUS="new"
while [ "${STATUS}" != "running" ]
do
    STATUS=$(curl -sX GET -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" "${ENDPOINT}/servers/${ID}" | jq .server.state)
    IP=$(curl -sX GET -H 'Content-Type: application/json' -H "X-Auth-Token: ${TOKEN}" "${ENDPOINT}/servers/${ID}" | jq .server.public_ip.address)
    echo "Current droplet status: $STATUS"
    sleep 10
done
echo "Got droplet ip: ${IP}"

sleep 15

echo "Building JuNest image..."
ssh -o "StrictHostKeyChecking no" -i ~/.ssh/scaleway_rsa builder@${IP} -- /usr/bin/sh << EOF
    sudo git clone https://github.com/fsquillace/junest-builder.git /opt/junest-builder
    /opt/junest-builder/build_image.sh $ARCH
EOF
