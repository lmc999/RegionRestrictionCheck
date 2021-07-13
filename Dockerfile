FROM python:2.7-alpine

RUN apk add --no-cache curl bash

COPY check.sh /check.sh

RUN chmod +x /check.sh

ENTRYPOINT ["/bin/bash","/check.sh"]
