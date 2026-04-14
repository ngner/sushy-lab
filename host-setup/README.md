# Host Setup

Prepare a Fedora/RHEL host with the networking and storage needed to run
libvirt VMs managed through Sushy Redfish.

## Files

| File | Purpose |
|------|---------|
| `host-bridge-setup.sh` | Create a primary linux bridge (`br0`) from a physical NIC. Edit `NET_DEV` to match your NIC. |
| `host-vlan-bridge-config.sh` | Add VLAN bridges (`br-123`, `br-100`, `br-150`) and register them as libvirt networks. |
| `host-network-config` | Combined nmcli recipe covering both bridge and VLAN setup. |
| `host-storage-pools-config.sh` | Define libvirt storage pools `testPool` and `boot` for VM disks and ISOs. |
| `routednet.xml` | Libvirt routed network with DHCP reservations for cluster nodes. |
| `dnsmasq/` | NetworkManager dnsmasq plugin config and static DNS host entries. |

## Quick start

```bash
# 1. Create the primary bridge (edit NET_DEV first)
./host-bridge-setup.sh

# 2. Create storage pools for VM disks and ISOs
sudo ./host-storage-pools-config.sh

# 3. Define the routed libvirt network (edit IPs/domain to match your subnet)
sudo virsh net-define routednet.xml
sudo virsh net-start routednet
sudo virsh net-autostart routednet

# 4. (Optional) VLAN bridges for trunk exercises
./host-vlan-bridge-config.sh

# 5. (Optional) DNS resolution for lab cluster endpoints
sudo cp dnsmasq/00-use-dnsmasq.conf /etc/NetworkManager/conf.d/
sudo cp dnsmasq/01-DNS-dnsmasq-routednet.conf /etc/NetworkManager/dnsmasq.d/
sudo cp dnsmasq/virsh-routednet-dnsmasq.hosts /etc/virsh-routednet-dnsmasq.hosts
sudo systemctl reload NetworkManager
```

## Adapting to your environment

The default IP scheme uses `192.168.192.0/24` for the routed network and
assumes the Sushy host is at `192.168.188.50`. Edit `routednet.xml` and
the dnsmasq hosts file to match your lab subnet. Replace `lab.example.com`
with your own domain.

For a deep dive into the networking constructs used here, see the
[networklab](https://github.com/ngner/networklab) curriculum.
