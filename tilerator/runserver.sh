#!/bin/bash
set -e

# wait for cassandra to be up
CASSANDRA_SERVER=cassandra
CASSANDRA_PORT=9042

function wait_for_cassandra() {
    for i in `seq 1 100`; do
        nc -vz $CASSANDRA_SERVER $CASSANDRA_PORT
        if [[ "$?" == "0" ]]; then
            return 0
        fi
        sleep 1
    done
    # cassandra unreachable, exiting
    exit 1
}

wait_for_cassandra

# wait for the database to be loaded
while true; do
     if [ $(redis-cli -h redis get data_imported) ]; then 
        echo "database loaded, starting tilerator"
        break
    fi
    echo "waiting for the database to be loaded"
    sleep 1
done

/usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/config.yaml

sleep infinity
