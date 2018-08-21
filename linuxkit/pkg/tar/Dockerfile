FROM alpine:3.8 as alpine

RUN apk update && apk add \
	tar

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=alpine /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=alpine /bin/tar /bin/tar
COPY --from=alpine /usr/bin/tar /usr/bin/tar
COPY --from=alpine /usr/libexec/rmt /usr/libexec/rmt
