# CRC / OpenShift Local Utilities

Tools for managing multiple [CRC (OpenShift Local)](https://developers.redhat.com/products/openshift-local/overview)
profiles and DNS resolution on a Fedora laptop.

## Files

| File | Purpose |
|------|---------|
| `crc-swap-profile` | Manage multiple independent CRC profiles using symlinks and a shared image cache. Supports `init`, `create`, `clone`, `switch`, `list`, and `upgrade` commands. |
| `crc-switch-dns` | Switch CRC DNS resolution between local (CRC-managed `systemd-resolved` per-link) and remote (VyOS router). Manages HAProxy for external CRC access. |
| `crc-dns-resolution.html` | Standalone HTML reference doc explaining CRC DNS resolution architecture. |

## Prerequisites

- CRC installed (`crc` binary in PATH)
- Red Hat pull secret at `~/pull-secret.json` (download from [console.redhat.com](https://console.redhat.com/openshift/create/local))
- `systemd-resolved` active (for `crc-switch-dns`)
- HAProxy installed (for remote DNS mode)

## Profile management quick start

```bash
# First-time setup
./crc-swap-profile init

# Boot and configure a base install
crc start
# ... install operators, configure users ...
crc stop

# Save as a named profile
./crc-swap-profile create base-install

# Clone for a demo
./crc-swap-profile clone base-install my-demo
crc setup   # re-creates bin/ in the new profile
crc start

# Switch between profiles
./crc-swap-profile switch base-install
crc start
```

## DNS switching

```bash
# Check current state
./crc-switch-dns status

# Switch DNS to VyOS router (for remote access)
./crc-switch-dns remote 192.168.188.55

# Revert to local CRC-managed DNS
./crc-switch-dns local
```

## CRC as ACM hub

CRC can serve as the ACM hub cluster for this lab. See
[federated-fleet-forge](https://github.com/federated-fleet-forge) for
deploying ACM on the hub and provisioning clusters onto sushy-backed VMs.
