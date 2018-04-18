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
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -c "drop schema if exists backup cascade;"
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -c "CREATE TABLE IF NOT EXISTS wd_names (id          varchar(20) UNIQUE, page          varchar(200) UNIQUE,    labels      hstore);"

cd $MAIN_DIR/config/import_data
# run the python script that loads all the data


INVOKE_DATA_DIR=$DATA_DIR INVOKE_OSM_FILE=$osm_file pipenv run invoke

# we tell redis that the import is finished so tilerator can start
redis-cli -h redis set 'data_imported' 'true'
