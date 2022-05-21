FROM golang:1.18-alpine as builder

WORKDIR /workdir

ARG SOURCE_VERSION
ARG SOURCE_REPO=https://github.com/ethereum/go-ethereum
ARG DOCKER_GIT_SHA

RUN apk add --no-cache gcc musl-dev curl linux-headers git

RUN mkdir -p info && printenv | tee info/build_envs.txt

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git clone --depth 1 -c advice.detachedHead=false \
    -b ${SOURCE_VERSION:-$(basename $(curl -Ls -o /dev/null -w %{url_effective} ${SOURCE_REPO}/releases/latest))} \
    ${SOURCE_REPO}.git

###
RUN cd go-ethereum && echo "SOURCE_SHA=$(git rev-parse HEAD)" | tee -a ../info/build_envs.txt && go env

###
RUN cd go-ethereum && go run build/ci.go install ./cmd/geth

### Output any missing library deps:
RUN { for i in $(find /workdir/go-ethereum/build/bin -type f -executable -print); do readelf -d $i 2>/dev/null | grep NEEDED | awk '{print $5}' | sed "s/\[//g" | sed "s/\]//g"; done; } | sort -u

FROM alpine:latest

WORKDIR /root

# Add packages
RUN apk add --no-cache ca-certificates && \
    mkdir -p /root/.ethereum/

###
COPY ./scripts /root
RUN chmod 777 /root/*.sh && ls -la /root/*.sh

###
COPY --from=builder /workdir/go-ethereum/build/bin/geth /usr/bin/
COPY --from=builder /workdir/info/ .

### Output bitcoind library deps to check if executable binary is compiled static:
RUN /usr/bin/geth version && ldd /usr/bin/geth

RUN ls -lah /root && cat *.txt

ENTRYPOINT ["/root/entrypoint.sh"]

EXPOSE 8545 8546 30303 30303/udp
