
# Use alpine as a base image to keep the image size small
FROM golang:1.21 AS builder

# Set the working directory to /go/src
WORKDIR /go/src

# Install git and copy the coredns source code
RUN set -x && \
    git clone https://github.com/coredns/coredns && \
    cd coredns && \
    # git fetch && \
    # git checkout tags/v1.8.3 && \
    echo "dnsredir:github.com/leiless/dnsredir" >> plugin.cfg

# Build coredns with the dnsredir plugin
RUN cd coredns && \
    GOFLAGS="-buildvcs=false" make gen && GOFLAGS="-buildvcs=false" make

# Use a new stage to create the final image
FROM alpine:3.19.1

# Set the working directory
WORKDIR /config

# Copy the built coredns binary from the builder stage
COPY --from=builder /go/src/coredns/coredns /usr/local/bin/coredns

# Expose the DNS ports and health check endpoint
EXPOSE 53/tcp
EXPOSE 53/udp
EXPOSE 9053

# Set the entrypoint to coredns
ENTRYPOINT ["coredns"]
