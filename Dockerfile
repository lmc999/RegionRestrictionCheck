FROM python:2.7-alpine

COPY check.sh /check.sh

RUN chmod +x /check.sh && \
    apk add --no-cache curl wget bash bind‑tools

ENTRYPOINT ["/bin/bash", "-l", "-c", "/check.sh"]
