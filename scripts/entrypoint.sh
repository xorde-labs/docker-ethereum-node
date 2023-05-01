#!/bin/sh

alias echo="echo ENTRYPOINT:"

CONFIG_FILE_DEFAULT=${HOME}/.ethereum/ethereum.toml
CONFIG_FILE="${CONFIG_FILE:-${CONFIG_FILE_DEFAULT}}"
CONFIG_FILE_DIR=$(dirname "${CONFIG_FILE}")

mkdir -p "${CONFIG_FILE_DIR}"

### Generate ethereum.toml
$HOME/config.sh ${CONFIG_FILE} || exit 1

echo "Loading ${CONFIG_FILE}"
echo "-----------------------"
cat "${CONFIG_FILE}"
echo "-----------------------"

set -ex

# shellcheck disable=SC2068
exec geth --config "${CONFIG_FILE}" $@
