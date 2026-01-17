FROM archlinux:multilib-devel-20260111.0.480139

ARG BUILD_USER
ARG BUILD_HOSTNAME

ENV \
  USER=${BUILD_USER} \
  HOSTNAME=${BUILD_HOSTNAME}

# Initial setup of the image
RUN \
  pacman -Syu --noconfirm base-devel \
  sudo git curl wget nvim kitty libglvnd && \

  useradd -m -G wheel ${USER} && \
  echo -e "${USER}:testing" | chpasswd && \
  echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers && \
  echo "${BUILD_HOSTNAME}" > /etc/hostname

RUN \
  # Install yay package manager to more easy package installs
  cd /home/${USER} && \
  git clone https://aur.archlinux.org/yay.git && \
  chown -R ${USER}:${USER} yay && \
  cd yay && \
  su ${USER} -c "makepkg -si --noconfirm" && \
  cd .. && \
  rm -rf yay 

RUN \
  su ${USER} -c "yay -Syu --noconfirm" && \
  su ${USER} -c "yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils nvidia-580xx-settings"