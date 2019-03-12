# Build go package
FROM golang:1.11.5-alpine3.9

RUN apk add --no-cache make git && \
	go get -u github.com/golang/dep/cmd/dep && \
	mkdir -p /go/src/github.com/giantswarm/etcd-backup

COPY Gopkg.lock Gopkg.toml /go/src/github.com/giantswarm/etcd-backup/

WORKDIR /go/src/github.com/giantswarm/etcd-backup/
RUN dep ensure -vendor-only

COPY . /go/src/github.com/giantswarm/etcd-backup/

RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o /etcd-backup


FROM alpine

RUN apk add --no-cache curl

# Get etcdctl
ENV ETCD_VER=v3.2.4
RUN \
  cd /tmp && \
  curl -L https://storage.googleapis.com/etcd/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz | \
  tar xz -C /usr/local/bin --strip-components=1

COPY --from=0 /etcd-backup /
ENTRYPOINT ["/etcd-backup"]
CMD ["-h"]
