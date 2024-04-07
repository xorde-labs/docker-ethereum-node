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

#### Environment variables

| Variable                  | Default value                             | Description                                                                                            |
|---------------------------|-------------------------------------------|--------------------------------------------------------------------------------------------------------|
| `NETWORK`                 | `1`                                       | Network ID (see https://besu.hyperledger.org/en/stable/public-networks/concepts/network-and-chain-id/) |
| `SYNCMODE`                | `snap`                                    | Synchronisation mode of the downloader. Modes: `full`, `light`, `snap`                                 |
| `DB_CACHE`                | `512`                                     | Enable RPC server. Modes: `0`, `1`                                                                     |
| `NOPRUNING_ENABLE`        | `false`                                   | Disable pruning and flush everything to disk                                                           |
| `RPC_ENABLE`              | `false`                                   | Enable RPC                                                                                             |
| `RPC_MODULES`             | `net,web3,eth`                            | Enabled modules for HTTP RPC                                                                           |
| `RPC_WS_MODULES`          | `net,web3,eth`                            | Enabled modules for WebSocket RPC                                                                      |
| `RPC_HOST`                | `0.0.0.0`                                 | Address for HTTP RPC listener                                                                          |
| `RPC_WS_HOST`             | `0.0.0.0`                                 | Address for WebSocket RPC listener                                                                     |
| `RPC_VHOSTS`              | `localhost,ethereum-node`                 | HTTP header hostnames used to validate incoming requests (protection against DNS-rebinding attack)     |
| `RPC_ALLOW_UNPROTECTEDTX` | `false`                                   | Allows non EIP-155 protected transactions to be send over RPC                                          |
| `RPC_AUTH_ADDR`           | `127.0.0.1`                               | Address for Authenticated HTTP RPC listener                                                            |
| `RPC_AUTH_PORT`           | `8551`                                    | Port for Authenticated HTTP RPC listener                                                               |
| `RPC_AUTH_VHOSTS`         | `locahost,ethereum-node`                  | HTTP header hostnames used to validate incoming requests                                               |
| `RPC_JWT_PATH`            | `/home/ethereum/.ethereum/geth/jwtsecret` | JWT secret for Authenticated HTTP requests                                                             |
| `P2P_MAX_PEERS`           | `50`                                      | Maximum number of peers that can be connected                                                          |
| `P2P_DISCOVERY_DISABLE`   | `false`                                   | Disable peer discovery                                                                                 |
| `EXTRA_OPTS`              | empty                                     | Extra command line options passed to `geth` process upon start                                         |

## Upgrading

Simple steps to upgrade to new version of the docker image:

```shell
docker compose down \
&& docker compose pull \
&& docker compose up
```

## Troubleshooting

### I can't connect to my node

Please check if you have `RPC_ENABLE` environment variable set to `true`.
Then use curl to check connection to RPC server:

```shell
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}' \
  http://localhost:8545
```

Or:

```shell
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```
