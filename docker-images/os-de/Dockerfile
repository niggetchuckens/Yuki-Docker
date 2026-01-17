ARG OS_IMAGE
FROM ${OS_IMAGE}

ARG BUILD_USER
ENV \ 
    USER=${BUILD_USER}

RUN \
    echo -e "#!/bin/bash\nexit 0" > /usr/usr/bin/systemctl && \
    chmod +x /usr/usr/bin/systemctl

RUN \ 
    su ${USER} -c "git clone https://github.com/niggetchuckens/dotfiles" && \
    su ${USER} -c "yay -S --noconfirm awesome xorg-server xorg-xinit xterm supervisor sunshine cuda"

RUN \
    echo "exec awesome" > /home/${USER}/.xinitrc && \
    chown ${USER}:${USER} /home/${USER}/.xinitrc

RUN \
    mkdir -p /etc/supervisor/conf.d && \
    echo -e '[supervisord]\n\
            nodaemon=true\n\
            user=root\n\
            logfile=/dev/stdout\n\
            logfile_maxbytes=0\n\
            \n\
            [program:x11]\n\
            command=su - ${USER} -c "startx -- -nocursor"\n\
            stdout_logfile=/dev/stdout\n\
            stdout_logfile_maxbytes=0\n\
            stderr_logfile=/dev/stderr\n\
            stderr_logfile_maxbytes=0\n\
            priority=1\n\
            \n\
            [program:sunshine]\n\
            command=su - ${USER} -c "sunshine"\n\
            stdout_logfile=/dev/stdout\n\
            stdout_logfile_maxbytes=0\n\
            stderr_logfile=/dev/stderr\n\
            stderr_logfile_maxbytes=0\n\
            autorestart=true\n\
            priority=2' > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 47984-47990/tcp 47998-48000/udp
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]