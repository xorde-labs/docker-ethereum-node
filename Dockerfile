FROM golang:1.18-alpine as builder

WORKDIR /workdir

RUN apk add --no-cache gcc musl-dev curl linux-headers git

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git clone --depth 1 -c advice.detachedHead=false -b $(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/ethereum/go-ethereum/releases/latest)) https://github.com/ethereum/go-ethereum.git

###
RUN cd go-ethereum && mkdir -p /workdir/build && echo "$(git rev-parse HEAD)" | tee /workdir/build/git-commit.txt && go env

###
RUN cd go-ethereum && go run build/ci.go install ./cmd/geth

### Output any missing library deps:
RUN { for i in $(find /workdir/go-ethereum/build/bin -type f -executable -print); do readelf -d $i 2>/dev/null | grep NEEDED | awk '{print $5}' | sed "s/\[//g" | sed "s/\]//g"; done; } | sort -u

FROM alpine:latest

WORKDIR /root

# Add packages
RUN apk add --no-cache ca-certificates

RUN mkdir -p /root/.ethereum/

###
COPY ./scripts /root
RUN chmod 777 /root/*.sh && ls -la /root/*.sh

###
COPY --from=builder /workdir/go-ethereum/build/bin/geth /usr/bin/

### Output bitcoind library deps to check if bitcoind is compiled static:
RUN ldd /usr/bin/geth

RUN ls -la /root
CMD ["/root/entrypoint.sh"]

EXPOSE 8545 8546 30303 30303/udp