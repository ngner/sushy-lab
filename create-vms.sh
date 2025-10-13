#!/bin/bash

NUMVMS=3


# make a tmp file location
tmpfile=$(mktemp /tmp/sushy-domain.XXXXXX)

# make a vm definition 
## Note custom --network routednet for my wireless bridge needs changing

NETWORK=br0
#NETWORK=routednet

for node in $(seq 1 $NUMVMS)
do
  virt-install --name vbmc-node-$node --network network=${NETWORK} --ram 1024 --disk size=1 --vcpus 2 --os-type linux --os-variant rhel9.5 --graphics vnc    --print-xml > $tmpfile
  virsh define --file $tmpfile
  rm $tmpfile
done

echo `virsh list`

virsh pool-define-as testPool dir - - - - "/tmp/testPool"
virsh pool-build testPool
virsh pool-start testPool
virsh pool-autostart testPool

for node in $(seq 1 $NUMVMS)
do
  virsh vol-create-as testPool testVol$node 1G
  virsh attach-disk vbmc-node-$node /tmp/testPool/testVol$node sda --persistent
done


