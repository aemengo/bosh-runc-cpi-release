FROM alpine:3.8 as alpine

RUN apk update && apk add \
	iptables \
	ip6tables

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /

# linked libs
COPY --from=alpine /usr/lib/libip4tc.so.0 /usr/lib/libip4tc.so.0
COPY --from=alpine /usr/lib/libip6tc.so.0 /usr/lib/libip6tc.so.0
COPY --from=alpine /usr/lib/libxtables.so.12 /usr/lib/libxtables.so.12
COPY --from=alpine /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

# iptables
COPY --from=alpine /etc/conf.d/iptables /etc/conf.d/iptables
COPY --from=alpine /etc/init.d/iptables /etc/init.d/iptables
COPY --from=alpine /sbin/iptables-compat-save /sbin/iptables-compat-save
COPY --from=alpine /sbin/iptables-compat /sbin/iptables-compat
COPY --from=alpine /sbin/iptables-restore /sbin/iptables-restore
COPY --from=alpine /sbin/ebtables-compat /sbin/ebtables-compat
COPY --from=alpine /sbin/arptables-compat /sbin/arptables-compat
COPY --from=alpine /sbin/iptables-save /sbin/iptables-save
COPY --from=alpine /sbin/iptables-compat-restore /sbin/iptables-compat-restore
COPY --from=alpine /sbin/iptables-translate /sbin/iptables-translate
COPY --from=alpine /sbin/xtables-compat-multi /sbin/xtables-compat-multi
COPY --from=alpine /sbin/iptables /sbin/iptables
COPY --from=alpine /sbin/iptables-restore-translate /sbin/iptables-restore-translate
COPY --from=alpine /sbin/xtables-multi /sbin/xtables-multi
COPY --from=alpine /usr/etc/ethertypes /usr/etc/ethertypes
COPY --from=alpine /usr/lib/libip4tc.so.0.1.0 /usr/lib/libip4tc.so.0.1.0
COPY --from=alpine /usr/lib/libip6tc.so.0 /usr/lib/libip6tc.so.0
COPY --from=alpine /usr/lib/libipq.so.0.0.0 /usr/lib/libipq.so.0.0.0
COPY --from=alpine /usr/lib/libiptc.so.0.0.0 /usr/lib/libiptc.so.0.0.0
COPY --from=alpine /usr/lib/libiptc.so.0 /usr/lib/libiptc.so.0
COPY --from=alpine /usr/lib/libip4tc.so.0 /usr/lib/libip4tc.so.0
COPY --from=alpine /usr/lib/libipq.so.0 /usr/lib/libipq.so.0
COPY --from=alpine /usr/lib/libxtables.so.12 /usr/lib/libxtables.so.12
COPY --from=alpine /usr/lib/libip6tc.so.0.1.0 /usr/lib/libip6tc.so.0.1.0
COPY --from=alpine /usr/lib/libxtables.so.12.0.0 /usr/lib/libxtables.so.12.0.0
COPY --from=alpine /usr/bin/iptables-xml /usr/bin/iptables-xml

# ip6tables
COPY --from=alpine /etc/init.d/ip6tables /etc/init.d/ip6tables
COPY --from=alpine /etc/conf.d/ip6tables /etc/conf.d/ip6tables
COPY --from=alpine /sbin/ip6tables /sbin/ip6tables
COPY --from=alpine /sbin/ip6tables-restore /sbin/ip6tables-restore
COPY --from=alpine /sbin/ip6tables-restore-translate /sbin/ip6tables-restore-translate
COPY --from=alpine /sbin/ip6tables-compat /sbin/ip6tables-compat
COPY --from=alpine /sbin/ip6tables-compat-restore /sbin/ip6tables-compat-restore
COPY --from=alpine /sbin/ip6tables-save /sbin/ip6tables-save
COPY --from=alpine /sbin/ip6tables-translate /sbin/ip6tables-translate
COPY --from=alpine /sbin/ip6tables-compat-save /sbin/ip6tables-compat-save

# everything else
COPY --from=alpine /usr/lib/xtables /usr/lib/xtables
