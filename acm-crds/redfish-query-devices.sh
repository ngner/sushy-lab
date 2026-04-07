#!/bin/bash

REDFISH_HOST="192.168.188.50"
REDFISH_PORT="8000"

for UUID in `curl -s http://${REDFISH_HOST}:${REDFISH_PORT}/redfish/v1/Systems | jq -r '.Members[]."@odata.id"' | awk -F'/' '{print $5}' `; do
  curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$UUID/EthernetInterfaces | jq -r '.Members[]."@odata.id"'
done