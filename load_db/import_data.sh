#!/bin/bash
set -e
set -x

osm_file='/data/*.pbf'

user='gis'
database='gis'
host='postgres'

readonly PGCONN="dbname=$database user=$user host=$host"

echo 'importing osm data in postgres'
mkdir -p ${MAIN_DIR}/imposm

time /usr/local/bin/imposm3 \
  import \
  -write --connection "postgis://$user@$host/$database" \
  -read $osm_file \
  -diff \
  -mapping ${MAIN_DIR}/imposm3_mapping.yml \
  -deployproduction -overwritecache \
  -diffdir ${MAIN_DIR}/imposm/diff -cachedir ${MAIN_DIR}/imposm/cache

# load several psql functions
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/language.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/postgis-vt-util.sql
## localization sql function
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/get_localized_name.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/get_localized_name_from_tags.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/get_country.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/get_country_name.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/geo_transliterate.sql

# natural earth data
echo 'importing natural earth shapes in postgres'
if [ ! -f "${DATA_DIR}/natural_earth_vector.sqlite" ]; then
    wget --quiet http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
        && unzip -oj natural_earth_vector.sqlite.zip -d ${DATA_DIR} \
        && rm natural_earth_vector.sqlite.zip
fi
PGCLIENTENCODING=LATIN1 ogr2ogr \
    -progress \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -clipsrc -180.1 -85.0511 180.1 85.0511 \
    PG:"$PGCONN" \
    -lco GEOMETRY_NAME=geometry \
    -lco DIM=2 \
    -nlt GEOMETRY \
    -overwrite \
    ${DATA_DIR}/natural_earth_vector.sqlite

# country shapes
# if [ ! -f "${DATA_DIR}/country_grid.sql" ]; then
#     wget --quiet http://www.nominatim.org/data/country_grid.sql.gz \
#     && gunzip -oj country_grid.sql -d ${DATA_DIR} \
#     && rm country_grid.sql.gz
# fi
# psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${DATA_DIR}/country_grid.sql

# water polygons
echo 'importing the water polyons'
if [ ! -f "${DATA_DIR}/water_polygons.shp" ]; then
    wget --quiet http://data.openstreetmapdata.com/water-polygons-split-3857.zip \
    && unzip -oj water-polygons-split-3857.zip -d ${DATA_DIR} \
    && rm water-polygons-split-3857.zip
fi
if [ ! -f "${DATA_DIR}/simplified_water_polygons.shp" ]; then
    wget --quiet http://data.openstreetmapdata.com/simplified-water-polygons-complete-3857.zip \
    && unzip -oj simplified-water-polygons-complete-3857.zip -d ${DATA_DIR} \
    && rm simplified-water-polygons-complete-3857.zip 
fi
POSTGRES_PASSWORD= POSTGRES_PORT=5432 IMPORT_DATA_DIR=${DATA_DIR} POSTGRES_HOST=postgres POSTGRES_DB=gis POSTGRES_USER=gis ${MAIN_DIR}/import-water.sh

# lake borders
if [ ! -f "${DATA_DIR}/lake_centerline.geojson" ]; then
    echo "no lake border file found, downloading it"
    wget --quiet -L -P ${DATA_DIR} https://github.com/lukasmartinelli/osm-lakelines/releases/download/v0.9/lake_centerline.geojson
fi
echo 'importing the lakes border'
PGCLIENTENCODING=UTF8 ogr2ogr \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    PG:"$PGCONN" \
    ${DATA_DIR}/lake_centerline.geojson \
    -nln "lake_centerline"

# borders
if [ ! -f "${DATA_DIR}/osmborder_lines.csv"]; then
    wget -P ${DATA_DIR} https://github.com/openmaptiles/import-osmborder/releases/download/v0.1/osmborder_lines.csv
fi
echo 'importing the borders'
POSTGRES_PASSWORD= POSTGRES_PORT=5432 IMPORT_DIR=${DATA_DIR} POSTGRES_HOST=postgres POSTGRES_DB=gis POSTGRES_USER=gis ${MAIN_DIR}/import_osmborder_lines.sh

# load the sql file with all the functions to generate the layers
# this file has been generated using https://github.com/openmaptiles/openmaptiles-tools generate-sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f ${SQL_DIR}/generated_sql.sql
