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

RUN \
apt update && \
apt install -y linux-headers-$(uname -r) && \
add-apt-repository ppa:wireguard/wireguard && \
apt install -y squid dropbear openssh-server wget curl git unzip zip zsh wireguard wireguard-tools \
wireguard-dkms iptables qrencode procps openresolv inotify-tools sudo net-tools jq screen bc \
build-essential dkms gnupg ifupdown iputils-ping libc6 libelf-dev perl pkg-config nano lsof dos2unix \
nload figlet python3 python3-pip speedtest-cli iproute2 && \
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid/squid.conf && \
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs
# Wireguard

RUN mkdir /app
RUN cd /app && git clone https://git.zx2c4.com/wireguard-linux-compat && git clone https://git.zx2c4.com/wireguard-tools && cd wireguard-tools && git checkout "${WIREGUARD_RELEASE}" && make -C src -j$(nproc) && make -C src install && echo "**** install CoreDNS ****" && COREDNS_VERSION=$(curl -sX GET "https://api.github.com/repos/coredns/coredns/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]' | awk '{print substr($1,2); }') && curl -o /tmp/coredns.tar.gz -L "https://github.com/coredns/coredns/releases/download/v${COREDNS_VERSION}/coredns_${COREDNS_VERSION}_linux_amd64.tgz" && tar xf /tmp/coredns.tar.gz -C /app && echo "**** clean up ****" && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# # Wireguard
# Setup Scripts
COPY SetupScripts/ /setup/
RUN chmod a+x -R /setup
COPY raw_bin/sysctl /usr/sbin/sysctl
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

ENV container=docker
# Scripts
COPY scripts/ /scripts/
RUN chmod 7777 -R /scripts
ENV PATH="$PATH:/scripts"
RUN echo "PATH=\"${PATH}:/scripts\"" > /etc/profile;echo "PATH=\"${PATH}:/scripts\"" > /etc/environment

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod a+x /sbin/entrypoint.sh
# VOLUME [ "/sys/fs/cgroup" ]
# CMD [ "/usr/bin/systemd" ]
# ENTRYPOINT [ "/sbin/entrypoint.sh" ]
ENTRYPOINT [ "systemd", "/sbin/entrypoint.sh" ]
