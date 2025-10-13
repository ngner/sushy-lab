#!/bin/bash


REDFISH_HOST="127.0.0.1"
REDFISH_PORT="8000"
ISO_URL="http://laptop.routednet.labs.nickday.biz:8080/rhcos.iso"

NUMVMS=3

POWERON=false

# PRINT System information

curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/ | jq -r



for node in $(seq 1 $NUMVMS)
do

    REDFISH_SYSTEM=$(sudo virsh domuuid vbmc-node-$node)
    REDFISH_MANAGER=$REDFISH_SYSTEM

    curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM/ | jq '[{hostname: .Name, manufacturer: .Manufacturer}, {"hardware": {cpu: .ProcessorSummary.Count, memory: .MemorySummary.TotalSystemMemoryGiB}}, {"health": {system: .Status.Health, cpu: .ProcessorSummary.Status.Health, memory: .MemorySummary.Status.Health}}]'

done

# for node in $(seq 1 $NUMVMS)
# do

#     ##Insert CD ROM
#     REDFISH_SYSTEM=$(sudo virsh domuuid vbmc-node-$node)
#     REDFISH_MANAGER=$REDFISH_SYSTEM
#     curl -d \
#         '{"Image":"'"$ISO_URL"'", "Inserted": true}' \
#         -H "Content-Type: application/json" \
#         -X POST \
#         http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_MANAGER/VirtualMedia/Cd/Actions/VirtualMedia.InsertMedia

#     ## Set the boot order CD Rom first

#     curl -X PATCH -H 'Content-Type: application/json' \
#         -d '{
#           "Boot": {
#               "BootSourceOverrideTarget": "Cd",
#               "BootSourceOverrideEnabled": "Continuous"
#           }
#         }' \
#       "http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM" | jq .

# done


for node in $(seq 1 $NUMVMS)
do
   
    ## POWER OFF
    REDFISH_SYSTEM=$(sudo virsh domuuid vbmc-node-$node)
    REDFISH_MANAGER=$REDFISH_SYSTEM

    echo "Powering off vmbc-node-$node with UUID $REDFISH_SYSTEM"
    
    curl -s -d '{"ResetType":"ForceOff"}'  \
        -H "Content-Type: application/json" -X POST  \
        http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM/Actions/ComputerSystem.Reset

    ## POWER ON
    if $POWERON
    then
      echo "Powering on vmbc-node-$node"
      curl -s -d '{"ResetType":"ForceOn"}' \
          -H "Content-Type: application/json" -X POST \
          http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM/Actions/ComputerSystem.Reset
    fi
done

exit
