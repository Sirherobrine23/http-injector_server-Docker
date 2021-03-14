FROM ubuntu:latest AS badvpn
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install --reinstall -y cmake make build-essential git pkg-config cmake-data
RUN git clone https://github.com/ambrop72/badvpn.git /tmp/badvpn
RUN mkdir /tmp/build /tmp/output && cd /tmp/build/ && \
cmake /tmp/badvpn -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 -DCMAKE_INSTALL_PREFIX=/tmp/output && \
make install

FROM ubuntu:latest
USER root
LABEL name="Http Injector Server in docker"
# badVPN copy
COPY --from=badvpn /tmp/output/bin/badvpn-udpgw /bin/badvpn-udpgw

# Install depedencies
ENV DEBIAN_FRONTEND=noninteractive
RUN \
apt update && apt upgrade -y &&\
# Install wireguard, squid, openssh, dropbear, sshuttle
apt install -y squid dropbear openssh-server wget curl git unzip zip zsh wireguard wireguard-tools wireguard-dkms iptables qrencode procps openresolv inotify-tools sudo net-tools jq screen bc build-essential dkms gnupg ifupdown iputils-ping libc6 libelf-dev perl pkg-config nano lsof dos2unix nload figlet python3 python3-pip speedtest-cli iproute2 sshuttle && \
# remove old config files
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid/squid.conf && \
# --?
echo resolvconf resolvconf/linkify-resolvconf boolean false | debconf-set-selections && \
# Install nodeJS
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs
ENV container=docker
RUN mkdir -p /home/configs/ && chmod 7777 -R /home/configs
# Root COPY
COPY root_docker/ /

RUN echo "PATH=\"\${PATH}:/scripts\"" >> /etc/profile; \
echo "PATH=\"\${PATH}:/scripts\"" >> /etc/environment; \
cat /etc/profile /etc/environment

# Setup files
RUN chmod a+x -R /setup

# NodeJS files
RUN cd /node_scripts/ ; if [ -d "node_modules" ];then rm -rfv "node_modules"; fi ; npm i --no-save

# Start Scripts
RUN chmod 7777 -R /scripts

EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp 51820/udp
ENV ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789"
# Entrypoint
RUN chmod a+x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
