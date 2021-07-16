FROM python:2.7-alpine

COPY check.sh /check.sh

RUN chmod +x /check.sh && \
    apk add --no-cache curl wget bash && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    shc

ENTRYPOINT ["/bin/bash","/check.sh"]
