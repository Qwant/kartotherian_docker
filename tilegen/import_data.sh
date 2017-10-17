#!/bin/bash
set -e
set -x

osm_file='/data/*.pbf'

user='gis'
database='gis'
host='postgres'

readonly PGCONN="dbname=$database user=$user host=$host"

echo 'importing osm data in postgres'
 
time /usr/local/bin/imposm3 \
  import \
  -write --connection "postgis://$user@$host/$database" \
  -read $osm_file \
  -diff \
  -mapping /imposm3_mapping.yml \
  -deployproduction -overwritecache \
  -diffdir ./diff -cachedir ./cache

wget https://raw.githubusercontent.com/openmaptiles/import-sql/master/language.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f language.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /postgis-vt-util/postgis-vt-util.sql

echo 'importing natural earth shapes in postgres'
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
    /import/natural_earth_vector.sqlite


echo 'importing ocean shapes in postgres'
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /mapnik-german-l10n/plpgsql/get_localized_name.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /mapnik-german-l10n/plpgsql/get_localized_name_from_tags.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /mapnik-german-l10n/plpgsql/get_country.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /mapnik-german-l10n/plpgsql/get_country_name.sql
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /mapnik-german-l10n/plpgsql/geo_transliterate.sql

/import_water.sh


echo 'importing the lakes border'
PGCLIENTENCODING=UTF8 ogr2ogr \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    PG:"$PGCONN" \
    /import/lake_centerline.geojson \
    -nln "lake_centerline"

echo 'importing the borders'
POSTGRES_PASSWORD= POSTGRES_PORT=5432 IMPORT_DIR=/import POSTGRES_HOST=postgres POSTGRES_DB=gis POSTGRES_USER=gis import_osmborder_lines.sh

# additional function needed by tilegen
psql -Xq -h postgres -U $user -d $database --set ON_ERROR_STOP="1" -f /generated_sql.sql
