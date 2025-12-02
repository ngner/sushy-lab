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


qemu-system-x86_64 -name sonic-simulator_1 -m 2048M -smp cpus=2 -drive file=/var/lib/libvirt/testPoolimages/sonic-tuna-1.qcow2,index=0,media=disk,id=drive0 -serial telnet:127.0.0.1:5001,server,nowait -monitor tcp:127.0.0.1:44001,server,nowait -device e1000,netdev=net0 -netdev user,id=net0