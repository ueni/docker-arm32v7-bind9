FROM ubuntu:20.04

LABEL maintainer="ueniueni, ueni"

ARG ARG_VERSION=1.0.0.0-dev
ENV VERSION=$ARG_VERSION

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get autoremove -y && \
    apt-get install -y \
        bind9 \
        bind9-utils && \
    apt-get clean;

VOLUME ["/etc/bind"]
VOLUME ["/var/cache/bind"]
VOLUME ["/var/log/named"]
VOLUME ["/var/usr/share/geoip"]
VOLUME ["/var/bind"]

EXPOSE 53/udp

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
