
#!/bin/bash

NUMVMS=3
DELETEPOOL=true

# make a tmp file location
tmpfile=$(mktemp /tmp/sushy-domain.XXXXXX)

# make a vm definition 
## Note custom --network for my wireless bridge needs changing
for node in $( seq 1 $NUMVMS )
do
  virsh destroy vbmc-node-$node
  virsh undefine vbmc-node-$node --remove-all-storage
done


if $DELETEPOOL
then
   for node in $(seq 1 $NUMVMS)
   do
     virsh vol-delete testVol$node
   done
  virsh pool-destroy testPool
  virsh pool-delete testPool
fi

