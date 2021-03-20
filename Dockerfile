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
apt install -y squid dropbear openssh-server wget curl git unzip zip zsh iptables qrencode procps openresolv inotify-tools sudo openvpn pptpd net-tools jq screen nano bc build-essential gnupg ifupdown iputils-ping libc6 libelf-dev perl pkg-config lsof dos2unix nload figlet python3 python3-pip speedtest-cli iproute2 sshuttle && \
# remove old config files
rm -fv /etc/ssh/sshd_config /etc/default/dropbear /etc/squid*/squid.conf && \
# --?
echo resolvconf resolvconf/linkify-resolvconf boolean false | debconf-set-selections && \
# Install nodeJS
curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && apt install -y nodejs && \
apt install -y tzdata openssl ca-certificates && mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray && \
pip3 install -U git+https://github.com/shadowsocks/shadowsocks.git@master
ENV container=docker
RUN mkdir -p /home/configs/ && chmod 7777 -R /home/configs

# Root COPY
COPY root_docker/ /

RUN echo "PATH=${PATH}:/scripts" >> /etc/PATH && \
echo "export PATH=${PATH}:/scripts" >> /etc/zsh/zshenv && \
usermod --shell /usr/bin/zsh root

# NodeJS files
RUN echo "Installing node dependencies"; cd /nodejs/; if [ -d "node_modules" ];then rm -rf "node_modules/" && npm i --no-save; else npm i --no-save &> /dev/null;fi

# Start Scripts
RUN chmod 7777 -R /scripts

RUN cd /tmp && curl https://raw.githubusercontent.com/v2fly/docker/master/v2ray.sh | bash -

EXPOSE 22/tcp 80/tcp 8080/tcp 443/tcp 51820/udp
ENV ADMIN_USERNAME="ubuntu" ADMIN_PASSWORD="123456789"
# Entrypoint
RUN chmod a+x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
# CMD [ "/sbin/init" ]
