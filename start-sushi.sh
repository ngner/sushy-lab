#!/bin/sh

export SUSHY_TOOLS_IMAGE=${SUSHY_TOOLS_IMAGE:-"quay.io/metal3-io/sushy-tools"}
#sudo podman create --replace --net host --privileged --name sushy-emulator -v "/etc/sushy":/etc/sushy -v "/var/run/libvirt":/var/run/libvirt "${SUSHY_TOOLS_IMAGE}" sushy-emulator -i :: -p 8000 --config /etc/sushy/sushy-emulator.conf
sudo podman start sushy-emulator

#response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://127.0.0.1:8000/redfish/v1/Managers)
response=$(curl http://127.0.0.1:8000/redfish/v1/Managers)
echo "response for sushi = $response"

