#!/bin/bash
set -e

# wait for cassandra to be up
CASSANDRA_SERVER=cassandra
CASSANDRA_PORT=9042

TILERATOR_MODE="${TILERATOR_MODE:-default}"

if [[ "$TILERATOR_MODE" == "api" ]]; then
    TILERATOR_CONFIG_FILE=config.api.yaml
else
    TILERATOR_CONFIG_FILE=config.yaml
fi

function wait_for_cassandra() {(
    set +e
    for i in `seq 1 100`; do
        nc -vz $CASSANDRA_SERVER $CASSANDRA_PORT
        if [[ "$?" == "0" ]]; then
            return 0
        fi
        sleep 1
    done
    # cassandra unreachable, exiting
    exit 1
)}

wait_for_cassandra

/usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/$TILERATOR_CONFIG_FILE

sleep infinity
