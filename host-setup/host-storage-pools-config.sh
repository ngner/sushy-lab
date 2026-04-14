
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

