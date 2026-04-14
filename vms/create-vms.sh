#!/bin/bash

NETWORK=br0
BASENAME=4node-cluster
DISKNAME=bm-node
ISO=Fedora-netinst-43.iso

NUMVMS=4   #NOTE max 9 as used for last digit in MAC
for node in $(seq 1 $NUMVMS)
do
  if [ "$node" -le 2 ]; then
    # SNO nodes
    RAM=16384
    VCPUS=8
  else
    # Worker nodes
    RAM=8192
    VCPUS=2
  fi

  echo "working on node $node with DISK ${DISKNAME} and basenanme ${BASENAME} (RAM: ${RAM}MB, vCPUs: ${VCPUS})"
  sudo qemu-img create -f qcow2 /var/lib/libvirt/testPoolimages/${DISKNAME}-${node}.qcow2 50G

  sudo virt-install \
    --name=${BASENAME}-${node} \
    --ram=${RAM} \
    --vcpus=${VCPUS} \
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
    --graphics vnc,port=590${node},listen=0.0.0.0${VNC_PASSWORD:+,password=$VNC_PASSWORD}
  
  domuuid=$(sudo virsh domuuid ${BASENAME}-${node})
  echo "${BASENAME}-${node} has domain ID $domuuid"
done

echo $(sudo virsh list --all)
