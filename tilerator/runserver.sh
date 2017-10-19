#!/bin/bash

set -e
set -x

/usr/local/bin/cassandra.wait && \
/usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/config.yaml

sleep infinity
