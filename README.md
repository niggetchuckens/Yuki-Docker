# Yuki Project

This project defines a set of custom Arch Linux-based Docker images designed for development and potentially desktop environments.

## Directory Structure

The project is organized into modular Docker contexts within the `docker-images/` directory:

- **os-base/**: The foundation image.
- **os-de/**: An extension image (Desktop Environment configuration).

## Images

### os-base

Located in `docker-images/os-base/Dockerfile`.

This is the base image derived from `archlinux:multilib-devel`. It sets up a complete development environment including:

- **Core Tools:** `base-devel`, `sudo`, `git`, `curl`, `wget`.
- **Editors & Terminals:** `nvim`, `kitty`.
- **Driver Support:** Nvidia 580xx series drivers and utils.
- **AUR Helper:** `yay` pre-installed and configured for the build user.
- **User Configuration:** Creates a sudo-enabled user based on build arguments.

**Build Arguments:**
- `BUILD_USER`: The username to create inside the container.
- `BUILD_HOSTNAME`: The hostname for the container.

### os-de

Located in `docker-images/os-de/Dockerfile`.

This image builds upon the base image (passed via `OS_IMAGE` arg) to layer on desktop environment customizations.

**Features:**
- Inherits the user configuration from `os-base`.
- Clones personal repositories.
- *(Work in Progress)* Installs additional packages via `yay`.

**Build Arguments:**
- `OS_IMAGE`: The base image to use (e.g., the built `os-base` image).
- `BUILD_USER`: The username matching the base image.

## Usage

To build the images, you would typically run commands similar to:

```bash
# Build os-base
docker build \
  --build-arg BUILD_USER=myuser \
  --build-arg BUILD_HOSTNAME=myhost \
  -t yuki-os-base \
  docker-images/os-base

# Build os-de
docker build \
  --build-arg OS_IMAGE=yuki-os-base \
  --build-arg BUILD_USER=myuser \
  -t yuki-os-de \
  docker-images/os-de
```
