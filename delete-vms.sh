
#!/bin/bash


DELETEPOOL=true
NETWORK=br0
#NETWORK=routednet
BASENAME=sonic-tuna
DISKNAME=tuna


# make a vm definition 
## Note custom --network for my wireless bridge needs changing
# ignore crc vms
for domain in $( virsh list --all --name | grep "$BASENAME2" | grep -v crc )
do
  echo "working on $domain for BASENAME $BASENAME"
  virsh destroy $domain
  virsh undefine $domain
done


sudo virsh vol-list testPool | grep $DISKNAME | awk '{print $1}' | sudo xargs -L 1 virsh vol-delete --pool testPool

if $DELETEPOOL
then
  virsh pool-destroy testPool
  virsh pool-delete testPool
fi
