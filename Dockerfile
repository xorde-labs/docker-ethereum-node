FROM golang:1.19-alpine as builder

ENV BLOCKCHAIN_NAME=ethereum

WORKDIR /workdir

ARG SOURCE_VERSION
ARG SOURCE_REPO=https://github.com/ethereum/go-ethereum
ARG DOCKER_GIT_SHA

### Install required dependencies
RUN apk upgrade -U \
    && apk add gcc musl-dev curl linux-headers git

RUN mkdir -p build_info && printenv | tee build_info/build_envs.txt

### checkout latest _RELEASE_ so we will build stable
### (we do not want to build working master for production)
RUN git clone --depth 1 -c advice.detachedHead=false \
    -b ${SOURCE_VERSION:-$(basename $(curl -Ls -o /dev/null -w %{url_effective} ${SOURCE_REPO}/releases/latest))} \
    ${SOURCE_REPO}.git ${BLOCKCHAIN_NAME}

### Save git commit sha of the repo to build_info dir
RUN cd ${BLOCKCHAIN_NAME} && echo "SOURCE_SHA=$(git rev-parse HEAD)" | tee -a ../build_info/build_envs.txt \
    && go env

###
RUN cd ${BLOCKCHAIN_NAME} && go run build/ci.go install ./cmd/geth

### Output any missing library deps:
RUN { for i in $(find /workdir/go-ethereum/build/bin -type f -executable -print); do readelf -d $i 2>/dev/null | grep NEEDED | awk '{print $5}' | sed "s/\[//g" | sed "s/\]//g"; done; } | sort -u

FROM alpine:latest

### https://specs.opencontainers.org/image-spec/annotations/
LABEL org.opencontainers.image.title="Ethereum Node Docker Image"
LABEL org.opencontainers.image.vendor="Xorde Technologies"
LABEL org.opencontainers.image.source="https://github.com/xorde-nodes/ethereum-node"

ENV BLOCKCHAIN_NAME=ethereum
WORKDIR /home/${BLOCKCHAIN_NAME}

### Add packages
RUN apk upgrade -U \
    && apk add ca-certificates

### Add group
RUN addgroup -S ${BLOCKCHAIN_NAME}

### Add user
RUN adduser -S -D -H -h /home/${BLOCKCHAIN_NAME} \
    -s /sbin/nologin \
    -G ${BLOCKCHAIN_NAME} \
    -g "User of ${BLOCKCHAIN_NAME}" \
    ${BLOCKCHAIN_NAME}

### Copy script files (entrypoint, config, etc)
COPY ./scripts .
RUN chmod 755 ./*.sh && ls -adl ./*.sh

### Copy build result from builder context
COPY --from=builder /workdir/${BLOCKCHAIN_NAME}/build/bin/geth /usr/bin/
COPY --from=builder /workdir/build_info/ .

### Output build binary deps to check if it is compiled static (or else missing some libraries):
RUN find . -type f -exec sha256sum {} \; \
    && ldd /usr/bin/geth \
    && echo "Built version: $(./version.sh)" \
    && cat build_envs.txt

RUN mkdir -p .${BLOCKCHAIN_NAME} \
    && chown -R ${BLOCKCHAIN_NAME} .

USER ${BLOCKCHAIN_NAME}

ENTRYPOINT ["./entrypoint.sh"]

### 8545 RPC API
### 8546 WS API
### 30303 Network
EXPOSE 8545 8546 30303
