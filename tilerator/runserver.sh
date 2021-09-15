#!/bin/bash
set -e

# wait for cassandra to be up
CASSANDRA_PORT=9042

TILERATOR_MODE="${TILERATOR_MODE:-worker}"

if [[ "$TILERATOR_MODE" == "api" ]]; then
    TILERATOR_CONFIG_FILE=config.api.yaml
else
    TILERATOR_CONFIG_FILE=config.worker.yaml
fi

function wait_for_cassandra() {(
    set +e
    for i in `seq 1 100`; do
        nc -vz $TILERATOR_CASSANDRA_SERVERS $CASSANDRA_PORT
        if [[ "$?" == "0" ]]; then
            return 0
        fi
        sleep 1
    done
    # cassandra unreachable, exiting
    exit 1
)}

wait_for_cassandra

node /opt/kartotherian/packages/tilerator/server.js -c /etc/tilerator/$TILERATOR_CONFIG_FILE
