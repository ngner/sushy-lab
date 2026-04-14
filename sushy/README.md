# Sushy Redfish Emulator

Install and configure the [Sushy](https://docs.openstack.org/sushy/latest/)
Redfish emulator to expose libvirt VMs as Redfish-managed bare-metal systems.
This is what allows ACM/MCE assisted installer to treat libvirt VMs as if they
were physical servers with real baseboard management controllers.

## Files

| File | Purpose |
|------|---------|
| `install-sushy` | Install script: pulls the `sushy-tools` container image, writes the emulator config, and creates a Podman quadlet for systemd management. |
| `sushy-emulator.conf` | Reference Sushy emulator configuration (listen address, libvirt URI, UEFI boot loader map). |
| `test-virt-media-via-sushy.sh` | Test script: queries Redfish for systems matching a basename, sets boot to CD, and power-cycles VMs. |
| `redfish-query-devices.sh` | Debug helper: lists Ethernet interface member URLs for each Redfish system. |

## Quick start

```bash
# 1. Install Sushy emulator as a systemd service
sudo ./install-sushy

# 2. Verify the service is running
sudo systemctl status sushy-emulator

# 3. Check Redfish endpoint
curl http://localhost:8000/redfish/v1/Systems/ | jq .

# 4. (After VMs are created) Test virtual media and power control
export REDFISH_HOST=192.168.188.50  # your host IP
./test-virt-media-via-sushy.sh
```

## Configuration

The emulator listens on `0.0.0.0:8000` by default and connects to the local
libvirt daemon at `qemu:///system`. Edit `/etc/sushy/sushy-emulator.conf` to
change these settings.

The `REDFISH_HOST` and `REDFISH_PORT` variables in the test scripts default to
`192.168.188.50:8000`. Override them for your environment:

```bash
REDFISH_HOST=10.0.0.5 REDFISH_PORT=8000 ./test-virt-media-via-sushy.sh
```

## Next steps

Once Sushy is running and VMs are created (see [vms/](../vms/)), the Redfish
endpoints are ready for ACM/MCE to consume. See
[federated-fleet-forge](https://github.com/federated-fleet-forge) for the
ZTP site config that targets these endpoints.

## References

- [Sushy tools docs (OpenStack)](https://docs.openstack.org/sushy/latest/)
- [Containerised Sushy setup](https://cloudcult.dev/sushy-emulator-redfish-for-the-virtualization-nation/#part-ii-containerized-sushy-tools)
- [Fishing for Sushy with curl](https://cloudcult.dev/fishing-for-sushy-with-curl-2/)
