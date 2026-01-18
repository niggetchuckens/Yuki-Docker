# Yuki Project

This project defines a custom Arch Linux-based Docker image designed for a headless cloud gaming or development environment using **Hyprland** and **Sunshine**.

## Overview

The `Dockerfile` in the root directory builds a complete environment featuring:

- **Base OS:** Arch Linux (`multilib-devel`)
- **Desktop Environment:** Hyprland (Wayland compositor)
- **Streaming Host:** Sunshine
- **Driver Support:** Nvidia Open Drivers
- **Process Management:** Supervisord (manages D-Bus, Hyprland, and Sunshine)
- **User Environment:** Creates a sudo-enabled user with `yay` configured.

## Configuration

The image uses `supervisord` to manage services. The entrypoint starts:
1. `dbus-daemon`
2. `hyprland` (Headless)
3. `sunshine`

## Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `BUILD_USER` | `hime` | The username to create inside the container. |
| `BUILD_PASSWORD` | `hime` | The password for the user. |
| `BUILD_HOSTNAME` | `yukios` | The hostname for the container. |

## Usage

### Build the Image

```bash
docker build -t yuki .
```

### Run the Container

Since this image relies on Nvidia drivers and hardware acceleration, you'll need the Nvidia Container Toolkit.

```bash
docker run -d \
  --gpus all \
  --cap-add=SYS_ADMIN \
  -p 47984-47990:47984-47990/tcp \
  -p 47998-48010:47998-48010/udp \
  --name yuki-instance \
  yuki
```

*Note: Port mappings correspond to Sunshine default ports.*
