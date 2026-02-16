# Wayland Passthrough for Incus Container (Android Emulator)

## Problem

Android emulator in Incus container (`flutter`) running headless with scrcpy. Goal: native display via host Wayland compositor.

## Host Environment

- Wayland compositor with socket at `/run/user/1000/wayland-1`
- User: `james` (uid 1000)
- AMD GPU (RX 580)

## Container Environment

- Ubuntu Questing, running as root (uid 0)
- Already had: GPU passthrough (`amdgpu`), KVM (`/dev/kvm`), `security.nesting: true`

## Steps

### 1. Create runtime directory in container

```bash
incus exec flutter -- mkdir -p /run/user/0
```

### 2. Add Wayland socket proxy device

Incus proxies the host Wayland socket into the container, handling UID remapping transparently.

```bash
incus config device add flutter wayland-socket proxy \
  connect=unix:/run/user/1000/wayland-1 \
  listen=unix:/run/user/0/wayland-0 \
  bind=container \
  uid=0 gid=0 \
  mode=0770
```

**Note:** The runtime directory must exist before adding the device or it will fail.

### 3. Set environment variables

Added to `/root/.bashrc`:

```bash
export XDG_RUNTIME_DIR=/run/user/0
export WAYLAND_DISPLAY=wayland-0
export DISPLAY=:0
```

### 4. Install XWayland and Mesa libraries

The Android emulator uses Qt with only an X11 (xcb) backend — no Wayland plugin. XWayland bridges X11 to the Wayland socket.

```bash
apt-get install -y xwayland libegl1 libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers
```

### 5. Start XWayland

```bash
export XDG_RUNTIME_DIR=/run/user/0 WAYLAND_DISPLAY=wayland-0
Xwayland :0 &
```

A blank root window appearing on the host desktop confirms it's working.

### 6. Launch the emulator

```bash
emulator -avd flutter_emulator -gpu host -no-audio -no-metrics
```

## Caveats

- `/run/user/0` is tmpfs and won't survive container restarts. Create it on boot (e.g., systemd tmpfiles rule).
- XWayland needs to be started after each container restart before the emulator can run.
- The `connect` path in the proxy device must match the host's `$WAYLAND_DISPLAY` socket.
- If Xvfb or another X server is holding display `:0`, kill it first or use a different display number.
