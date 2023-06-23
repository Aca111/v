FROM debian:sid

RUN set -ex\
    && apt update -y \
    && apt upgrade -y \
    && apt install -y wget unzip qrencode\
    && apt install -y shadowsocks-libev\
    && apt install -y nginx\
    && apt install -y bash coreutils grep sed net-tools\
    && apt autoremove -y

COPY conf/ /conf
COPY entrypoint.sh /entrypoint.sh
COPY v2 /v2

#RUN mkdir /wwwroot
RUN ln -sf /tmp/wwwroot /wwwroot
RUN ln -sf /tmp/etc/shadowsocks-libev/config.json /etc/shadowsocks-libev/config.json
RUN ln -sf /tmp/var/log/nginx/error.log /var/log/nginx/error.log
RUN ln -sf /tmp/var/log/nginx/access.log /var/log/nginx/access.log
RUN ln -sf /tmp/ngnix.pid /run/ngnix.pid
RUN rm -rf /etc/nginx/sites-enabled/default

RUN chmod +x /v2
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh
