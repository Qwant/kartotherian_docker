FROM openmaptiles/postgis

RUN echo 'psql -c "create extension hstore; create extension osml10n;"' > /docker-entrypoint-initdb.d/z_hstore.sh
