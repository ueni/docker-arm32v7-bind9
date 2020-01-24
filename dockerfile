FROM arm32v7/alpine:3.11

LABEL maintainer="ueni"

ARG VERSION_BIND=9.14.8-r5
ENV VERSION=1.0.0
ENV VERSION_BIND=$VERSION_BIND

RUN apk --update --no-cache add bind=$VERSION_BIND 
RUN mkdir -m 0755 -p /var/run/named && chown -R root:named /var/run/named

VOLUME ["/etc/bind"]
VOLUME ["/var/cache/bind"]
VOLUME ["/var/log/named"]

EXPOSE 53 53/udp 953 8053

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]



