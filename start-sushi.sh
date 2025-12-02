#!/bin/sh

#response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://127.0.0.1:8000/redfish/v1/Managers)
response=$(curl http://127.0.0.1:8000/redfish/v1/Managers)
echo "response for sushi = $response"

