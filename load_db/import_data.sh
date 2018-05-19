#!/bin/bash
set -e
set -x

osm_file='${DATA_DIR}/*.pbf'

user='gis'
database='gis'
host='postgres'

echo 'importing osm data in postgres'
mkdir -p ${MAIN_DIR}/imposm

# if there is a backup schema imposm cannot delete the tables in to (with the -deployproduction, so we delete them to be able to reload the data several times
psql -Xq -h $host -U $user -d $database --set ON_ERROR_STOP="1" -c "drop schema if exists backup cascade;"
psql -Xq -h $host -U $user -d $database --set ON_ERROR_STOP="1" -c "CREATE TABLE IF NOT EXISTS wd_names (id          varchar(20) UNIQUE, page          varchar(200) UNIQUE,    labels      hstore);"

cd $MAIN_DIR/config/import_data

# Launch import pipeline
PYTHONPATH='.' luigi --module luigi_tasks InitialImport \
	--importOsmConfig-import-id="initial" \
	--importOsmConfig-pbf-url="https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf" \
	--local-scheduler --workers=4

# we tell redis that the import is finished so tilerator can start
if [ "$REDIS_SET_KEY" = "true" ]; then
	redis-cli -h redis set 'data_imported' 'true'
fi

# Wait for tilerator to start
sleep 10

# Generate tiles for Luxembourg
PYTHONPATH='.' luigi --module luigi_tasks GenerateTiles \
	--importOsmConfig-import-id="initial" \
	--tilerator-url="http://tilerator:16534" \
	--zoom=7 --tile-x=66 --tile-y=43 --parts=8 \
	--local-scheduler
