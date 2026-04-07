#!/bin/bash

DELETEPOOL=false

NETWORK=br0
BASENAME=4node-cluster
DISKNAME=bm-node

# make a vm definition 
# ignore crc vms
for domain in $( sudo virsh list --all --name | grep "$BASENAME" | grep -v crc )
do
  echo "working on $domain for BASENAME $BASENAME"
  sudo virsh destroy $domain
  sudo virsh undefine $domain
done

sudo virsh vol-list testPool | grep $DISKNAME | awk '{print $1}' | sudo xargs -L 1 virsh vol-delete --pool testPool

if $DELETEPOOL
then
  sudo virsh pool-destroy testPool
  sudo virsh pool-delete testPool
fi
