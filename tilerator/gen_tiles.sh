#!/bin/bash
set -e
set +x

/usr/local/bin/cassandra.wait && \
/usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/config.yaml &

node /opt/tilerator/scripts/tileshell.js \
	--config /etc/tilerator/config.yaml \
	--source /etc/tilerator/sources.yaml \
	-j.zoom 0 -j.fromZoom 0 -j.beforeZoom 11 \
	-j.generatorId gen -j.storageId v2 \
	-j.parts 8 -j.deleteEmpty
