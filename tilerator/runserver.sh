#!/bin/bash
set -e

# wait for cassandra to be up
/usr/local/bin/cassandra.wait

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
