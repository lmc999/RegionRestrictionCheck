FROM alpine:latest

RUN apk add --no-cache curl wget bash grep openssl ca-certificates uuidgen && \
    apk add --no-cache bind-tools --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main

COPY check.sh /check.sh
RUN chmod +x /check.sh

ENTRYPOINT ["/bin/bash", "/check.sh"]
