FROM python:alpine3.18

RUN apk add --no-cache curl wget bash bind-tools

COPY check.sh /check.sh

RUN chmod +x /check.sh

ENTRYPOINT ["/bin/bash", "-l", "-c", "/check.sh"]
