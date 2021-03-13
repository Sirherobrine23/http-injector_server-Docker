FROM ubuntu:latest AS badvpn
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install --reinstall -y cmake make build-essential git pkg-config cmake-data
RUN git clone https://github.com/ambrop72/badvpn.git /tmp/badvpn
RUN mkdir /tmp/build /tmp/output && cd /tmp/build/ && \
cmake /tmp/badvpn -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1 -DBUILD_UDPGW=1 -DCMAKE_INSTALL_PREFIX=/tmp/output && \
make install

FROM ubuntu:latest
USER root
LABEL name="Http Injector Server in docker"
COPY LICENSES/ /docker_run_licenses/

# badVPN copy
COPY --from=badvpn /tmp/output/bin/badvpn-udpgw /bin/badvpn-udpgw
COPY --from=badvpn /tmp/output/bin/badvpn-tun2socks /bin/badvpn-tun2socks
EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp 8000/tcp 8001/tcp 6971-6999/tcp 51820/udp
ENV DEBIAN_FRONTEND=noninteractive ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789"

RUN \
apt update && \
# Install wireguard, squid, openssh, dropbear
apt install -y squid dropbear openssh-server wget curl git unzip zip zsh wireguard wireguard-tools \
wireguard-dkms iptables qrencode procps openresolv inotify-tools sudo net-tools jq screen bc \
build-essential dkms gnupg ifupdown iputils-ping libc6 libelf-dev perl pkg-config nano lsof dos2unix \
nload figlet python3 python3-pip speedtest-cli iproute2 && \
# remove old config files
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid/squid.conf && \
# --?
echo resolvconf resolvconf/linkify-resolvconf boolean false | debconf-set-selections && \
# Install nodeJS
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs

# # Wireguard
# Setup Scripts
COPY SetupScripts/ /setup/
RUN chmod a+x -R /setup
# SSH Config
COPY config/ /etc/
COPY texts/banner.html /etc/bannerssh

# Configs Folder
RUN mkdir -p /home/configs/ && chmod 7777 -R /home/configs

# Javascript
COPY node_scripts/ /node_scripts/
RUN cd /node_scripts/ && npm i -f --no-save

ENV container=docker
# Scripts
COPY scripts/ /scripts/
RUN chmod 7777 -R /scripts
RUN echo "PATH=\"${PATH}:/scripts\"" >> /etc/profile;echo "PATH=\"${PATH}:/scripts\"" >> /etc/environment;echo ${PATH}; cat /etc/profile /etc/environment

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod a+x /sbin/entrypoint.sh
ENTRYPOINT [ "/sbin/entrypoint.sh" ]
