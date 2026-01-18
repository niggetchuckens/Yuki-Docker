ARG OS_IMAGE
FROM ${OS_IMAGE}

ARG BUILD_USER
ARG BUILD_PASSWORD

ENV USER=${BUILD_USER} \
    PASSWORD=${BUILD_PASSWORD} \
    DISPLAY=:99

RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config && \
    echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config && \
    usermod -aG video,render,input ${USER} && \
    mkdir -p /var/log/X11 /var/run/dbus && \
    chmod 777 /var/log/X11

RUN pacman -Syu --noconfirm \
    xorg-server xorg-xinit xorg-server-xvfb xorg-xhost xorg-xrandr \
    awesome supervisor wget cuda dbus mesa-utils

RUN su ${USER} -c "yay -S --noconfirm icu76-bin" && ldconfig

RUN wget "https://github.com/LizardByte/Sunshine/releases/download/v2026.117.142916/sunshine-2026.117.142916-1-x86_64.pkg.tar.zst" -O /tmp/sunshine.pkg.tar.zst && \
    pacman -U --noconfirm /tmp/sunshine.pkg.tar.zst && \
    rm /tmp/sunshine.pkg.tar.zst

RUN mkdir -p /home/${USER}/.config/sunshine && \
    echo '{ \
  "apps": [ \
    { \
      "name": "Desktop (Container)", \
      "output": "screen", \
      "cmd": "awesome --replace" \
    }, \
    { \
      "name": "Desktop Low Res", \
      "output": "screen", \
      "cmd": "xrandr --size 1280x720 && awesome --replace" \
    } \
  ] \
}' > /home/${USER}/.config/sunshine/apps.json

RUN touch /home/${USER}/.Xauthority && \
    chown -R ${USER}:${USER} /home/${USER}

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
[program:x11]\n\
# Cleans locks and starts Xvfb on :99 to avoid host conflicts\n\
command=bash -c \"rm -f /tmp/.X99-lock; Xvfb :99 -screen 0 1920x1080x24 -listen tcp\"\n\
autorestart=true\n\
priority=2\n\
\n\
[program:awesome]\n\
# Authorizes :99 and starts Awesome inside a dbus session\n\
command=bash -c \"sleep 2 && DISPLAY=:99 xhost + && DISPLAY=:99 dbus-run-session awesome\"\n\
autorestart=true\n\
priority=3\n\
\n\
[program:sunshine]\n\
# Starts Sunshine explicitly targeting the virtual display\n\
command=bash -c \"sleep 5 && su - ${USER} -c 'DISPLAY=:99 /usr/bin/sunshine'\"\n\
autorestart=true\n\
priority=4" > /etc/supervisor/conf.d/supervisord.conf

USER root
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]