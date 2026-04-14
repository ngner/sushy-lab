#!/bin/bash


REDFISH_HOST="${REDFISH_HOST:-192.168.188.50}"
REDFISH_PORT="${REDFISH_PORT:-8000}"
ISO_URL="${ISO_URL:-http://your-host:8080/rhcos.iso}"

NUMVMS=3

POWERON=false


## Note custom --network routednet for my wireless bridge needs changing
NETWORK=br0
#NETWORK=routednet
BASENAME=3nodetuna
DISKNAME=tuna
#Only needed if you want to manually boot machines e.g. discovery images.
ISO=Fedora-netinst-43.iso

# PRINT System information and st#Only ore in associative array
declare -A SYSTEM_NAMES  # UUID -> Name mapping
declare -a SYSTEM_UUIDS  # Array of UUIDs for iteration

echo "Name UUID"
while read uuid; do
  name=$(curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$uuid | jq -r '.Name // "N/A"')
  if [[ $name == $BASENAME* ]]; then
    SYSTEM_NAMES[$uuid]=$name
    SYSTEM_UUIDS+=($uuid)
    echo "$name $uuid"
  fi
done < <(curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/ | jq -r '.Members[]? | ."@odata.id" | split("/") | last')


# Iterate over all UUIDs
for uuid in "${SYSTEM_UUIDS[@]}"; do
  curl -s http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$uuid/VirtualMedia | jq .
  name="${SYSTEM_NAMES[$uuid]}"
  echo "Processing $name ($uuid)"
done

# Or iterate over keys directly
for uuid in "${!SYSTEM_NAMES[@]}"; do
  name="${SYSTEM_NAMES[$uuid]}"
  echo "System: $name has UUID: $uuid"
done




for uuid in "${SYSTEM_UUIDS[@]}"; do
    nodename="${SYSTEM_NAMES[$uuid]}"
    echo "Working on node $nodename (UUID: $uuid)"

    ##Insert CD ROM
    REDFISH_SYSTEM=$uuid
    REDFISH_MANAGER=$uuid
    # don't bother to add ISO URL as there is a disk image mounted to the CD ROM at creation of the VM 
    #curl -d \
    #     '{"Image":"'"$ISO_URL"'", "Inserted": true}' \
    #     -H "Content-Type: application/json" \
    #     -X POST \
    #     http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_MANAGER/VirtualMedia/Cd/Actions/VirtualMedia.InsertMedia

    ## Set the boot order CD Rom first

    curl -X PATCH -H 'Content-Type: application/json' \
        -d '{
          "Boot": {
              "BootSourceOverrideTarget": "Cd",
              "BootSourceOverrideEnabled": "Continuous"
          }
        }' \
      "http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM" | jq .

done



for uuid in "${SYSTEM_UUIDS[@]}"; do
    nodename="${SYSTEM_NAMES[$uuid]}"
    echo "Working on node $nodename (UUID: $uuid)"

    ##Power off or On
    REDFISH_SYSTEM=$uuid
    REDFISH_MANAGER=$uuid
    if ! $POWERON
    then
        echo "Powering off $nodename with UUID $REDFISH_SYSTEM"
    
        curl -s -d '{"ResetType":"ForceOff"}'  \
            -H "Content-Type: application/json" -X POST  \
            http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM/Actions/ComputerSystem.Reset
    fi
    if $POWERON
    then
        echo "Powering on $nodename"
        curl -s -d '{"ResetType":"ForceOn"}' \
            -H "Content-Type: application/json" -X POST \
            http://$REDFISH_HOST:$REDFISH_PORT/redfish/v1/Systems/$REDFISH_SYSTEM/Actions/ComputerSystem.Reset
        sleep 5
    fi
done

exit
