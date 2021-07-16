FROM golang:1.16-alpine as builder
WORKDIR /go/src/RegionRestrictionCheck
COPY check.sh go.mod main.go go.sum ./

RUN go get -v github.com/jteeuwen/go-bindata/... && \
    /go/bin/go-bindata -o check.go check.sh && \
    go build -o RegionRestrictionCheck


FROM python:2.7-alpine
COPY --from=builder /go/src/RegionRestrictionCheck/RegionRestrictionCheck /check
RUN chmod +x /check && \
    apk add --no-cache curl wget bash
ENTRYPOINT ["/check.sh"]
