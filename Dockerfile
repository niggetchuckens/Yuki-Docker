# syntax=docker/dockerfile:1.4
FROM archlinux:multilib-devel-20260111.0.480139

# --- 1. Environment & Arguments ---
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

# --- 2. Base System & Sudo Fix ---
RUN pacman -Syu --noconfirm base-devel sudo git curl wget nano libglvnd dbus supervisor mesa && \
    useradd -m -G wheel ${USER} && \
    echo -e "${USER}:${PASSWORD}" | chpasswd && \
    echo 'root ALL=(ALL:ALL) ALL' > /etc/sudoers && \
    echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    echo "${HOSTNAME}" > /etc/hostname

# --- 3. Setup Yay & AUR Packages ---
WORKDIR /home/${USER}
RUN sudo -u ${USER} git clone https://aur.archlinux.org/yay-bin.git && \
    cd yay-bin && \
    sudo -u ${USER} makepkg -si --noconfirm && \
    cd .. && rm -rf yay-bin

# --- 4. Setup BlackArch Repository ---
RUN curl -O https://blackarch.org/strap.sh && \
    chmod +x strap.sh && \
    ./strap.sh && \
    rm strap.sh

# --- 5. Install Drivers, Hyprland, and Core Tools ---
RUN sudo -u ${USER} yay -Syu --noconfirm \
    gosu nvidia-open-dkms nvidia-utils nvidia-settings \
    hyprland kitty xorg-xwayland qt5-wayland qt6-wayland \
    pipewire pipewire-pulse wireplumber xdg-desktop-portal-hyprland icu76-bin

# --- 6. Install personal apps (Split to avoid timeout) ---
RUN sudo -u ${USER} yay -S --noconfirm brave-bin visual-studio-code-bin \
    oh-my-posh nvtop htop neofetch python python-pip python-virtualenv \
    nodejs npm typescript android-studio fpc texlive-core texlive-lang \
    bash-completion rofi ninja meson cmake reflector rsync python-pywal16 \
    swww waybar swaync starship myfetch neovim python-pywalfox hypridle \
    hyprpicker hyprshot hyprlock pacman-contrib pyprland wlogout fd cava \
    brightnessctl clock-rs-git nerd-fonts nwg-look qogir-icon-theme materia-gtk-theme \
    illogical-impulse-bibata-modern-classic-bin thunar gvfs tumbler eza \
    libreoffice-fresh ncspot blueman bluez pavucontrol pulsemixer gst-plugins-bad

# --- 7. Dotfiles installation (FIXED: No systemctl that were on the install script from the repo) ---
WORKDIR /home/${USER}
RUN sudo -u ${USER} git clone https://github.com/elifouts/Dotfiles && \
    mkdir -p /home/${USER}/.config && \
    cp -a /home/${USER}/Dotfiles/wallpapers /home/${USER}/ && \
    cp -a /home/${USER}/Dotfiles/.config/* /home/${USER}/.config/ && \
    cp -a /home/${USER}/Dotfiles/.bashrc /home/${USER}/.bashrc && \
    sudo -u ${USER} wal -i /home/${USER}/Dotfiles/wallpapers/pywallpaper.jpg -n || true && \
    rm -rf /home/${USER}/Dotfiles

# --- 8. Sunshine Installation ---
RUN wget "https://github.com/LizardByte/Sunshine/releases/download/v2026.117.142916/sunshine-2026.117.142916-1-x86_64.pkg.tar.zst" -O /tmp/sunshine.pkg.tar.zst && \
    pacman -U --noconfirm /tmp/sunshine.pkg.tar.zst && \
    rm /tmp/sunshine.pkg.tar.zst

# --- 9. D-Bus & Runtime Dir Stabilization ---
RUN mkdir -p /var/run/dbus /run/dbus ${XDG_RUNTIME_DIR} /tmp/.X11-unix && \
    chown -R messagebus:messagebus /var/run/dbus /run/dbus && \
    chown -R ${USER}:${USER} ${XDG_RUNTIME_DIR} /home/${USER} && \
    chmod 700 ${XDG_RUNTIME_DIR} && \
    chmod 1777 /tmp/.X11-unix && \
    dbus-uuidgen --ensure=/etc/machine-id

# --- 10. Robust Supervisor Configuration ---
RUN mkdir -p /etc/supervisor/conf.d && \
    echo -e "[supervisord]\n\
            nodaemon=true\n\
            user=root\n\
            \n\
            [program:dbus]\n\
            command=bash -c \"rm -f /var/run/dbus/pid && exec dbus-daemon --system --nofork --nopidfile\"\n\
            autorestart=true\n\
            priority=1\n\
            \n\
            [program:hyprland]\n\
            command=bash -c \"exec gosu ${USER} dbus-run-session hyprland\"\n\
            autorestart=true\n\
            priority=2\n\
            \n\
            [program:sunshine]\n\
            command=bash -c \"sleep 10 && exec gosu ${USER} sunshine\"\n\
            autorestart=true\n\
            priority=3" > /etc/supervisor/conf.d/supervisord.conf

# --- 11. Final Permissions ---
RUN usermod -aG video,render,input ${USER} && \
    chown -R ${USER}:${USER} /home/${USER}

USER root
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]