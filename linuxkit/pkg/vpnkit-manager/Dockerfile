FROM alpine:3.8 as alpine

RUN apk add --no-cache iptables

COPY vpnkit-manager /usr/bin/vpnkit-manager
COPY sha /etc/vpnkit-manager/sha

CMD ["/usr/bin/vpnkit-manager"]