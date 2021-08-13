FROM python:2.7-alpine

COPY check.sh /check.sh

RUN chmod +x /check.sh && \
    apk add --no-cache curl wget bash && \
    apk add  --no-cache bind-tools --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main

ENTRYPOINT ["/bin/bash", "-l", "-c", "/check.sh"]
