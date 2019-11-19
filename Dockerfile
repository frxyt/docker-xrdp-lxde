# Copyright (c) 2019 FEROX YT EIRL, www.ferox.yt <devops@ferox.yt>
# Copyright (c) 2019 Jérémy WALTHER <jeremy.walther@golflima.net>
# See <https://github.com/frxyt/docker-xrdp-lxde> for details.

FROM debian:stable

LABEL maintainer="Jérémy WALTHER <jeremy@ferox.yt>"

# Install required packages to run
RUN     DEBIAN_FRONTEND=noninteractive apt-get update \
    &&  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --fix-missing --no-install-recommends \
            ca-certificates \
            curl \
            dbus-x11 \
            midori \
            nano \
            openssh-server \
            sudo \
            supervisor \
            task-lxde-desktop \
            terminator \
            tigervnc-standalone-server \
            unzip \
            vim \
            wget \
            xorgxrdp \
            xrdp \
    &&  apt-get clean -y && apt-get clean -y && apt-get autoclean -y && rm -r /var/lib/apt/lists/*
    
ENV FRX_XRDP_CERT_SUBJ='/C=FX/ST=None/L=None/O=None/OU=None/CN=localhost' \
    FRX_XRDP_USER_NAME=debian \
    FRX_XRDP_USER_PASSWORD=ChangeMe \
    FRX_XRDP_USER_SUDO=1 \
    FRX_XRDP_USER_GID=1000 \
    FRX_XRDP_USER_UID=1000 \
    TZ=Europe/Paris

COPY build/start                /usr/local/sbin/frx-start
COPY build/supervisord.conf     /etc/supervisor/supervisord.conf
COPY build/xrdp.ini             /etc/xrdp/xrdp.ini

RUN     echo "startlxde" > /etc/skel/.xsession \
    &&  echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ALL \
    &&  sed -e 's/^#\?\(PermitRootLogin\)\s*.*$/\1 no/' \
            -e 's/^#\?\(PasswordAuthentication\)\s*.*$/\1 yes/' \
            -e 's/^#\?\(PermitEmptyPasswords\)\s*.*$/\1 no/' \
            -e 's/^#\?\(PubkeyAuthentication\)\s*.*$/\1 yes/' \
            -i /etc/ssh/sshd_config \
    &&  mkdir -p /run/sshd \
    &&  rm -f /etc/xrdp/cert.pem /etc/xrdp/key.pem /etc/xrdp/rsakeys.ini \
    &&  rm -f /etc/ssh/ssh_host_*

EXPOSE 22
EXPOSE 3389

VOLUME [ "/home" ]
WORKDIR /home

CMD [ "/usr/local/sbin/frx-start" ]