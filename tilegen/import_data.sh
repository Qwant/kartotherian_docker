#!/bin/bash
set -e
set +x

osm_file='/data/*.pbf'

user='gis'
database='gis'
host='postgres'

echo 'importing osm data in postgres'
time /usr/local/bin/osm2pgsql \
    --create \
    --database $database \
    --username $user \
    --slim \
    --style /usr/local/share/osm2pgsql/default.style \
    --hstore \
    --cache 16000 \
    --number-processes 6 \
    --flat-nodes /node.cache \
    --host $host \
    $osm_file
 
echo 'importing ocean shapes in postgres'

curl -O http://data.openstreetmapdata.com/water-polygons-split-3857.zip
unzip water-polygons-split-3857.zip && rm water-polygons-split-3857.zip

shp2pgsql -I -s 3857 -g way water-polygons-split-3857/water_polygons | psql -Xqd gis -h postgres -U $user -d $database

psql -Xq -h postgres -U $user -d $database -c "select UpdateGeometrySRID('', 'water_polygons', 'way', 3857);"

psql -Xq -h postgres -U $user -d $database -f /opt/osm-bright.tm2source/node_modules/postgis-vt-util/lib.sql
psql -Xq -h postgres -U $user -d $database -f /opt/osm-bright.tm2source/sql/admin.sql
psql -Xq -h postgres -U $user -d $database -f /opt/osm-bright.tm2source/sql/functions.sql
psql -Xq -h postgres -U $user -d $database -f /opt/osm-bright.tm2source/sql/create-indexes.sql
psql -h postgres -U $user -d $database -c 'select populate_admin();'
psql -h postgres -U $user -d $database -c 'ALTER TABLE water_polygons OWNER TO gis; ALTER TABLE admin OWNER TO gis;'
