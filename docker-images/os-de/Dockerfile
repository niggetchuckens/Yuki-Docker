ARG OS_IMAGE
ARG BUILD_USER

FROM ${OS_IMAGE}


ENV \ 
    USER=${BUILD_USER}

RUN \ 
    su ${USER} -c "git clone https://github.com/niggetchuckens" && \
    su ${USER} -c "yay -S --noconfirm "