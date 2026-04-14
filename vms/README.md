# VM Lifecycle

Create and destroy libvirt VMs that Sushy exposes as Redfish-managed systems.
These VMs simulate bare-metal nodes for ACM/MCE assisted installer deployments.

## Files

| File | Purpose |
|------|---------|
| `create-vms.sh` | Create N libvirt VMs on `br0` with qcow2 disks in `testPool`, Fedora netinst ISO as CDROM, fixed MACs, and VNC consoles. First 2 nodes get more resources (16GB RAM, 8 vCPUs) for control plane; remaining nodes are lighter workers. |
| `delete-vms.sh` | Destroy and undefine all VMs matching the cluster basename, delete their disk volumes from `testPool`. |

## Quick start

```bash
# 1. Ensure host-setup is complete (bridge, storage pools)
# 2. Download a boot ISO into /var/lib/libvirt/boot/
# 3. Create VMs
./create-vms.sh

# 4. Verify via Sushy Redfish
curl http://localhost:8000/redfish/v1/Systems/ | jq '.Members[]'

# 5. When done, tear down
./delete-vms.sh
```

## Configuration

Edit the variables at the top of each script:

| Variable | Default | Description |
|----------|---------|-------------|
| `NETWORK` | `br0` | Bridge network for VM NICs |
| `BASENAME` | `4node-cluster` | libvirt domain name prefix |
| `DISKNAME` | `bm-node` | Disk volume name prefix |
| `ISO` | `Fedora-netinst-43.iso` | Boot ISO filename in `/var/lib/libvirt/boot/` |
| `NUMVMS` | `4` | Number of VMs to create (max 9) |
| `VNC_PASSWORD` | *(unset)* | Optional VNC console password |

After creation, each VM's libvirt domain UUID is printed. These UUIDs appear
in the Sushy Redfish `/redfish/v1/Systems/<uuid>` endpoints and are used in
`BareMetalHost` BMC addresses.
