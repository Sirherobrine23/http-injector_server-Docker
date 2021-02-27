FROM ubuntu:latest
USER root
ENV DEBIAN_FRONTEND=noninteractive ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789"
EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp 53/tcp 554/tcp 1935/tcp 7070/tcp 8000/tcp 8001/tcp 6971-6999/tcp
RUN apt update
RUN apt install -y squid dropbear openssh-server wget curl git unzip zip zsh sudo net-tools jq screen && echo "" && echo "" && \
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid/squid.conf && echo "" && echo "" && \
wget "https://github.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE/blob/master/Install/Sistema/Script/badvpn-udpgw?raw=true" -O /bin/badvpn-udpgw && \
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs

# SSH Config
COPY config/sshd /etc/ssh/sshd_config
COPY config/dropbear.properties /etc/default/dropbear
COPY texts/banner.html /etc/bannerssh

# SSh Plus Scripts
# COPY plus_install.sh /tmp/plus.sh
# RUN bash /tmp/plus.sh

# Configs Folder
RUN mkdir -p /home/configs/ && chmod 7777 -R /home/configs

# Javascript
COPY node_scripts/set_users.js /node_scripts/set_users.js

# Scripts
COPY scripts/ /scripts
RUN chmod 7777 -R /scripts
ENV PATH="$PATH:/scripts"
RUN echo "PATH=\"${PATH}:/scripts\"" > /etc/profile;echo "PATH=\"${PATH}:/scripts\"" > /etc/environment

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod a+x /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]