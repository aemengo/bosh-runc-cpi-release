FROM alpine:3.8 as alpine

ENV COMMIT=v3.10

RUN apk update && apk add \
  gcc \
  build-base \
  ccache \
  coreutils \
  git \
  libaio-dev \
  libcap-dev \
  libnet-dev \
  libnl3-dev \
  pkgconfig \
  protobuf-c-dev \
  protobuf-dev \
  python

RUN git clone https://github.com/checkpoint-restore/criu /criu
WORKDIR /criu
RUN git checkout $COMMIT

RUN make criu

FROM scratch
ENTRYPOINT []
CMD []
WORKDIR /
COPY --from=alpine /criu/criu/criu /usr/bin/criu
COPY --from=alpine /usr/lib/libprotobuf-c.so.1 /usr/lib/libprotobuf-c.so.1
COPY --from=alpine /usr/lib/libnl-3.so.200 /usr/lib/libnl-3.so.200
COPY --from=alpine /usr/lib/libnet.so.1 /usr/lib/libnet.so.1
COPY --from=alpine /lib/ld-musl-x86_64.so.1  /lib/ld-musl-x86_64.so.1
