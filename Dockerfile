FROM jfloff/alpine-python:2.7

RUN apk add --no-cache curl

COPY check.sh /check.sh

RUN chmod +x /check.sh

ENTRYPOINT ["/check.sh"]
