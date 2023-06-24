#!/bin/bash

if [[ -z "${Password}" ]]; then
  Password="5c301bb8-6c77-41a0-a606-4ba11bbab084"
fi
ENCRYPT="chacha20-ietf-poly1305"
QR_Path="/qr"

#V2Ray Configuration
V2_Path="/v2"
mkdir /tmp/wwwroot
mkdir -p /tmp/etc/shadowsocks-libev
mkdir -p /tmp/etc/nginx/conf.d
mkdir -p /tmp/usr/bin
mkdir -p /tmp/var/log/nginx/
#touch /tmp/etc/nginx/conf.d/ss.conf
touch /tmp/var/log/nginx/access.log
touch /tmp/var/log/nginx/error.log
cp -a /v2 /tmp/usr/bin/v2


if [ ! -d /etc/shadowsocks-libev ]; then  
  mkdir /etc/shadowsocks-libev
fi

# TODO: bug when PASSWORD contain '/'
sed -e "/^#/d"\
    -e "s/\${PASSWORD}/${Password}/g"\
    -e "s/\${ENCRYPT}/${ENCRYPT}/g"\
    -e "s|\${V2_Path}|${V2_Path}|g"\
    /conf/shadowsocks-libev_config.json >  /etc/shadowsocks-libev/config.json
echo /etc/shadowsocks-libev/config.json
cat /etc/shadowsocks-libev/config.json

sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s|\${V2_Path}|${V2_Path}|g"\
    -e "s|\${QR_Path}|${QR_Path}|g"\
    -e "$s"\
    /conf/nginx_ss.conf > /tmp/etc/nginx/conf.d/ss.conf 

if [ "${Domain}" = "no" ]; then
  echo "APERSONALPN"
else
  plugin=$(echo -n "v2ray;path=${V2_Path};host=${Domain};tls" | sed -e 's/\//%2F/g' -e 's/=/%3D/g' -e 's/;/%3B/g')
  ss="ss://$(echo -n ${ENCRYPT}:${Password} | base64 -w 0)@${Domain}:443?plugin=${plugin}" 
  echo "${ss}" | tr -d '\n' > /wwwroot/index.html
  echo -n "${ss}" | qrencode -s 6 -o /wwwroot/vpn.png
fi

ss-server -v -c /etc/shadowsocks-libev/config.json -d 8.8.8.8 &
nginx -g 'daemon off;'
