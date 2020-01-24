FROM arm32v7/alpine:latest

LABEL maintainer="ueniueni, ueni"

ENV VERSION=1.0.0

RUN apk --update add bind 
RUN mkdir -m 0755 -p /var/run/named && chown -R root:named /var/run/named

VOLUME ["/etc/bind"]
VOLUME ["/var/cache/bind"]
VOLUME ["/var/log/named"]

EXPOSE 53 53/udp 953 8053

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
