# Wayland Socket Passthrough to Incus Container

## Problem

Running Android emulator headless in an Incus container (`flutter`) and using scrcpy. Want native Wayland display access instead.

## Host Environment

- Wayland socket: `/run/user/1000/wayland-1`
- User: `james` (uid 1000)
- Container runs as root (uid 0)
- Container already has GPU passthrough (`amdgpu`) and KVM

## Steps

### 1. Create the runtime directory inside the container

The proxy device needs the parent directory to exist before it can create the socket.

```bash
incus exec flutter -- mkdir -p /run/user/0
```

### 2. Add a Wayland socket proxy device

This creates a socket inside the container that proxies to the host's Wayland socket. Incus handles the UID remapping transparently.

```bash
incus config device add flutter wayland-socket proxy \
  connect=unix:/run/user/1000/wayland-1 \
  listen=unix:/run/user/0/wayland-0 \
  bind=container \
  uid=0 gid=0 \
  mode=0770
```

### 3. Set environment variables

Added to `/root/.bashrc` so the container knows where to find Wayland:

```bash
incus exec flutter -- bash -c 'cat >> /root/.bashrc << "EOF"
export XDG_RUNTIME_DIR=/run/user/0
export WAYLAND_DISPLAY=wayland-0
EOF'
```

## Verification

```bash
# Check socket exists
incus exec flutter -- ls -la /run/user/0/wayland-0

# Test with a new shell
incus exec flutter -- bash -l
wayland-info  # if wayland-utils is installed
```

## Notes

- `/run/user/0` is a tmpfs and may not survive container restarts. You may need to re-create it on boot (e.g., via a systemd tmpfiles rule or a startup script).
- The `connect` path must match your host's `$WAYLAND_DISPLAY` socket path.
