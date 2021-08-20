#!/bin/bash
set -e

TILERATOR_MODE="${TILERATOR_MODE:-worker}"

TILERATOR_CONFIG_FILE=config.yaml

node /opt/kartotherian/packages/tilerator/server.js -c /etc/tilerator/$TILERATOR_CONFIG_FILE
