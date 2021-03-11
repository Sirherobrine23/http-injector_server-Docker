FROM ubuntu:latest AS badvpn
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install --reinstall -y cmake make build-essential git pkg-config cmake-data
RUN git clone https://github.com/ambrop72/badvpn.git /tmp/badvpn
RUN mkdir /tmp/build /tmp/output && cd /tmp/build/ && \
cmake /tmp/badvpn -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1 -DCMAKE_INSTALL_PREFIX=/tmp/output && \
make install

FROM ubuntu:latest
USER root
# badVPN
COPY --from=badvpn /tmp/output/bin/badvpn-udpgw /bin/badvpn-udpgw
COPY --from=badvpn /tmp/output/bin/badvpn-tun2socks /bin/badvpn-tun2socks
EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp 53/tcp 554/tcp 1935/tcp 7070/tcp 8000/tcp 8001/tcp 6971-6999/tcp
ENV DEBIAN_FRONTEND=noninteractive ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789"
RUN apt update && apt install -y squid dropbear openssh-server wget curl git unzip zip zsh sudo net-tools jq screen bc nano lsof dos2unix nload figlet python3 python3-pip speedtest-cli && \
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid/squid.conf && \
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs

# SSH Config
COPY config/ /etc/
COPY texts/banner.html /etc/bannerssh

# SSh Plus Scripts
# COPY plus_install.sh /tmp/plus.sh
# RUN bash /tmp/plus.sh

# Configs Folder
RUN mkdir -p /home/configs/ && chmod 7777 -R /home/configs

# Javascript
COPY node_scripts/ /node_scripts/

# Scripts
COPY scripts/ /scripts/
RUN chmod 7777 -R /scripts
ENV PATH="$PATH:/scripts"
RUN echo "PATH=\"${PATH}:/scripts\"" > /etc/profile;echo "PATH=\"${PATH}:/scripts\"" > /etc/environment

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod a+x /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]