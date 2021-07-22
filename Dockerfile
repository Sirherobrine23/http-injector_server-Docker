FROM ubuntu:latest AS badvpn
ENV DEBIAN_FRONTEND="noninteractive"
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

ENV DEBIAN_FRONTEND="noninteractive" container="docker"
EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp

# Install depedencies
RUN \
# Update Apt
apt update && \
\
# Install squid, openssh, dropbear, sshuttle
apt install -y squid dropbear openssh-server wget curl git unzip zip zsh iptables qrencode procps openresolv inotify-tools sudo openvpn pptpd net-tools jq screen nano bc build-essential gnupg ifupdown iputils-ping libc6 libelf-dev perl pkg-config lsof dos2unix nload figlet python3 python3-pip iproute2 sshuttle && \
\
# remove old config files
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid*/squid.conf && \
\
# Install nodeJS
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt install -y nodejs && \
apt install -y tzdata openssl ca-certificates && \
pip3 install -U git+https://github.com/shadowsocks/shadowsocks.git@master && \
pip3 install git+https://github.com/sivel/speedtest-cli.git

# Install chromium
RUN apt install -y chromium-browser || apt install -y chromium

# Change bash to zsh
RUN usermod --shell /usr/bin/zsh root
ENV ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789" IS_DOCKER="true" CONFIG_FILE="/home/configs/settings.json"

# Copy and Install Dependecies
WORKDIR /usr/src/Backend
COPY ./ ./
RUN npm install -d --no-save

EXPOSE 8080
ENTRYPOINT [ "node", "index.js"]