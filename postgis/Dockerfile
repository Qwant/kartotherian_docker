FROM mdillon/postgis:9.5-alpine

RUN echo 'psql -c "create extension hstore"' > /docker-entrypoint-initdb.d/z_hstoire.sh
