#!/bin/bash
set -e
set -x

optional_invoke_args=$1

osm_file='${DATA_DIR}/*.pbf'

# run the python script that loads all the data
INVOKE_DATA_DIR=$DATA_DIR INVOKE_OSM_FILE=$osm_file invoke $optional_invoke_args

# we tell redis that the import is finished so tilerator can start
if [ "$REDIS_SET_KEY" = "true" ]; then
	redis-cli -h redis set 'data_imported' 'true'
fi
