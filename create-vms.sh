#!/bin/bash

## Note custom --network routednet for my wireless bridge needs changing
NETWORK=br0
#NETWORK=routednet
BASENAME=3nodetuna
DISKNAME=tuna
#Only needed if you want to manually boot machines e.g. discovery images.
ISO=Fedora-netinst-43.iso


NUMVMS=3   #NOTE max 9 as used for last digit in MAC
for node in $(seq 1 $NUMVMS)
do
  ## Create a disk called tuna in the testPool pool  (note thin provisioned
  echo "working on node $node with DISK ${DISKNAME} and basenanme ${BASENAME}"
  qemu-img create -f qcow2 /var/lib/libvirt/testPoolimages/${DISKNAME}-${node}.qcow2 50G

  ##  Create a testing VM which is blank and uses the above empty disk.
  virt-install \
    --name=${BASENAME}-${node} \
    --ram=1024 \
    --vcpus=2 \
    --cpu host-passthrough \
    --os-variant debian12 \
    --noreboot \
    --events on_reboot=restart \
    --noautoconsole \
    --boot hd,cdrom \
    --import \
    --disk path=/var/lib/libvirt/testPoolimages/${DISKNAME}-${node}.qcow2,size=20,pool=testPool \
    --disk /var/lib/libvirt/boot/${ISO},device=cdrom \
    --network type=direct,source=${NETWORK},mac=aa:aa:aa:aa:aa:0${node},source_mode=bridge,model=virtio \
    --graphics vnc,port=590${node},listen=0.0.0.0,password=test123
  domuuid=`sudo virsh domuuid ${BASENAME}-${node}`
  echo "${BASENAME}-${node} has domain ID $domuuid"
done

echo `virsh list --all`



