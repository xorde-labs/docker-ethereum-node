#!/bin/sh

geth version | grep '^Version.*' | awk 'NF{ print $NF }'