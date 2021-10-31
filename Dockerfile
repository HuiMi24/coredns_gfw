FROM golang:1.14.1 as build
RUN set -x &&\
#    go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct &&\
    git clone https://github.com/coredns/coredns &&\
#    echo "proxy:github.com/coredns/proxy" >> coredns/plugin.cfg &&\
#    cat coredns/plugin.cfg &&\
    cd coredns &&\
#    echo proxy:github.com/coredns/proxy >> plugin.cfg &&\
    echo "dnsredir:github.com/leiless/dnsredir" >> plugin.cfg&&\
    go generate coredns.go &&\
    make
FROM alpine:3.11.5
COPY --from=build /go/coredns/coredns /usr/local/bin/coredns
WORKDIR /
HEALTHCHECK CMD wget 127.0.0.1:8080/health -q -O - | grep OK
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 9053
ENTRYPOINT ["coredns"]
