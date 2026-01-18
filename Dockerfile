# syntax=docker/dockerfile:1.4
FROM archlinux:multilib-devel-20260111.0.480139

# --- 1. Build Arguments & Environment ---
ARG BUILD_USER=hime
ARG BUILD_PASSWORD=completo
ARG BUILD_HOSTNAME=YukiOS

ENV USER=${BUILD_USER} \
    PASSWORD=${BUILD_PASSWORD} \
    HOSTNAME=${BUILD_HOSTNAME} \
    DISPLAY=:99 \
    XDG_RUNTIME_DIR=/tmp/runtime-${BUILD_USER} \
    WLR_BACKEND=headless \
    WLR_LIBINPUT_NO_DEVICES=1 \
    XDG_SESSION_TYPE=wayland \
    __GLX_VENDOR_LIBRARY_NAME=nvidia \
    GBM_BACKEND=nvidia-drm

# --- 2. Base System Setup ---
RUN pacman -Syu --noconfirm base-devel sudo git curl wget nano libglvnd dbus supervisor mesa && \
    useradd -m -G wheel ${USER} && \
    echo -e "${USER}:${PASSWORD}" | chpasswd && \
    echo 'root ALL=(ALL:ALL) ALL' > /etc/sudoers && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo "${HOSTNAME}" > /etc/hostname

# --- 3. Setup Yay (AUR Helper) ---
WORKDIR /home/${USER}
RUN sudo -u ${USER} git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    sudo -u ${USER} makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay-bin

# --- 4. Install Nvidia Open Drivers & Hyprland ---
RUN sudo -u ${USER} yay -S --noconfirm \
    nvidia-open-dkms nvidia-utils nvidia-settings \
    hyprland kitty xorg-xwayland qt5-wayland qt6-wayland \
    pipewire pipewire-pulse wireplumber xdg-desktop-portal-hyprland \
    icu76-bin gosu

# --- 5. Install Sunshine ---
RUN wget "https://github.com/LizardByte/Sunshine/releases/download/v2026.117.142916/sunshine-2026.117.142916-1-x86_64.pkg.tar.zst" -O /tmp/sunshine.pkg.tar.zst && \
    pacman -U --noconfirm /tmp/sunshine.pkg.tar.zst && \
    rm /tmp/sunshine.pkg.tar.zst

# --- 6. Prepare Filesystem & Runtime ---
RUN mkdir -p ${XDG_RUNTIME_DIR} /tmp/.X11-unix && \
    chmod 700 ${XDG_RUNTIME_DIR} && \
    chmod 1777 /tmp/.X11-unix && \
    chown ${USER}:${USER} ${XDG_RUNTIME_DIR} && \
    dbus-uuidgen > /etc/machine-id

# --- 7. Supervisor Configuration (Headless Wayland + Sunshine) ---
RUN mkdir -p /etc/supervisor/conf.d && \
    echo -e "[supervisord]\n\
nodaemon=true\n\
user=root\n\
\n\
[program:dbus]\n\
command=dbus-daemon --system --nofork\n\
autorestart=true\n\
priority=1\n\
\n\
[program:hyprland]\n\
# Starts Hyprland in headless mode. Note: DISPLAY=:99 is set in ENV\n\
command=bash -c \"su - ${USER} -c 'dbus-run-session hyprland'\"\n\
autorestart=true\n\
priority=2\n\
\n\
[program:sunshine]\n\
# Waits for Hyprland to create the Wayland socket\n\
command=bash -c \"sleep 7 && su - ${USER} -c 'XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} DISPLAY=:99 /usr/bin/sunshine'\"\n\
autorestart=true\n\
priority=3" > /etc/supervisor/conf.d/supervisord.conf

# --- 8. Final Permissions ---
RUN usermod -aG video,render,input ${USER} && \
    chown -R ${USER}:${USER} /home/${USER}

USER root
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]