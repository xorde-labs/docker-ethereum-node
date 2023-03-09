# Ethereum Docker Node

Main goal of this project is to dockerize blockchain nodes, so we could run them in pure DevOps fashion: dockerized, cluster-ready, manageable.

[![Docker Image CI](https://github.com/xordelabs/docker-ethereum-node/actions/workflows/docker-image.yml/badge.svg)](https://github.com/xordelabs/docker-ethereum-node/actions/workflows/docker-image.yml)

## Installing

### Quick start

#### Standalone Docker

```shell
docker run -d -p 8545:8545 -p 8546:8546 -p 30303:30303 --restart unless-stopped ghcr.io/xordelabs/docker-ethereum-node:latest
```

Store all settings and blockchain outside docker container:

```shell
docker run -d --name ethereum-node -v /data/ethereum:/home/ethereum/.ethereum -p 8545:8545 -p 8546:8546 -p 30303:30303 --restart always -e "RPC_SERVER=1" ghcr.io/xordelabs/docker-ethereum-node:latest
```

Store all settings and blockchain outside docker container and run node on testnet:

```shell
docker run -d --name ethereum-node -v /data/ethereum:/home/ethereum/.ethereum -p 8545:8545 -p 8546:8546 -p 30303:30303 --restart always -e "TESTNET=1" -e "RPC_SERVER=1" ghcr.io/xordelabs/docker-ethereum-node:latest
```

#### Docker Compose

```shell
git clone https://github.com/xordelabs/docker-ethereum-node.git
cd ethereum-node
cp example.env .env
# now please edit .env file to your choice, save it, and continue:
# you can skip editing .env file, and leave it unchanged 
# as it is pre-configured to run on testnet
docker compose up -d
```

## Upgrading

Simple steps to upgrade to new version of the docker image:

```shell
docker compose down \
&& docker compose pull \
&& docker compose up
```
