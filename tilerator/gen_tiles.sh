#!/bin/bash

# bash script used to generate all tiles from 0 to 11 zoom level
# this script needs to be run explicitly if needed

set -e
set +x

node /opt/tilerator/scripts/tileshell.js \
	--config /etc/tilerator/config.yaml \
	--source /etc/tilerator/sources.yaml \
	-j.zoom 0 -j.fromZoom 0 -j.beforeZoom 11 \
	-j.generatorId substbasemap -j.storageId basemap \
	-j.parts 8 -j.deleteEmpty -j.keepJob \
	-j.checkZoom "-1"

node /opt/tilerator/scripts/tileshell.js \
	--config /etc/tilerator/config.yaml \
	--source /etc/tilerator/sources.yaml \
	-j.zoom 0 -j.fromZoom 0 -j.beforeZoom 11 \
	-j.generatorId gen_poi -j.storageId poi \
	-j.parts 8 -j.deleteEmpty -j.keepJob \
	-j.checkZoom "-1"
