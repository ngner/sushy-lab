
  #!/bin/bash

## References overall blog with explenations 
#  intial virt setup https://cloudcult.dev/libvirt-setup-on-rhel-and-fedora/
#  sushy install idea not used as using podman https://cloudcult.dev/sushy-emulator-redfish-for-the-virtualization-nation/#part-ii-containerized-sushy-tools
#  using sushy for testing with curl https://cloudcult.dev/fishing-for-sushy-with-curl/



## Official Sushy tools docs from OpenStack

# https://docs.openstack.org/sushy/latest/

#virt-install --name sonic-vs --ram 2048 --vcpus 4 --machine q35 --disk path=sonic-vs.img,device=disk,bus=sata --network network=default,model=e1000 --virt-type kvm --os-variant rhel7 --nographics --cpu host --extra-args 'console=ttyS0' --forward-port tcp=5555 --import

virsh pool-list


##  Check it is using the path /var/lib/libvirt/images 
# if not then delete the pool if it is empty and define as below.
# if it is already used change the other references to the path in the virt-install etc.
mkdir -p /var/lib/libvirt/testPoolimages


if ! virsh pool-info testPool; then
  virsh pool-define-as testPool --type dir --target /var/lib/libvirt/testPoolimages
  virsh pool-autostart testPool
  virsh pool-start testPool
  pool-info testPool
fi

if ! virsh pool-info boot; then
  virsh pool-define-as boot --type dir --target /var/lib/libvirt/boot
  virsh pool-autostart boot
  virsh pool-start boot
fi


## Note custom --network routednet for my wireless bridge needs changing
NETWORK=br0
#NETWORK=routednet
BASENAME=sonic-tuna
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
  done

  echo `virsh list --all`

