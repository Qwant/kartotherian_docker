FROM ubuntu:16.04

ENV MAIN_DIR=/srv/import_data \
    SQL_DIR=${MAIN_DIR}/sql \
    DATA_DIR=/data

RUN apt update && \
    apt install -y \
             git \
             unzip \
             python-pip \
             screen \
             curl \
             libpq-dev \
             libproj-dev \
             liblua5.2-dev \
             libgeos++-dev \
             osmctools \
             nmap \
             sqlite3 \
             gdal-bin \
             postgis \
             redis-tools \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    # install imposm
    && wget https://imposm.org/static/rel/imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    tar xvfz imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    ln -sf /imposm3-0.4.0dev-20170519-3f00374-linux-x86-64/imposm3 /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter \
    # a script to import the osm borders
    && wget -P ${MAIN_DIR} https://raw.githubusercontent.com/openmaptiles/import-osmborder/v0.4/import/import_osmborder_lines.sh \
    && chmod +x ${MAIN_DIR}/import_osmborder_lines.sh \
    # a script to import the water polygons
    && wget -P ${MAIN_DIR} https://raw.githubusercontent.com/openmaptiles/import-water/master/import-water.sh \
    && chmod +x ${MAIN_DIR}/import-water.sh \
    # fetch lots of sql script
    && mkdir -p ${SQL_DIR} \
    && wget -P ${SQL_DIR}/ https://raw.githubusercontent.com/openmaptiles/import-sql/master/language.sql \
    && wget -P ${SQL_DIR}/ https://raw.githubusercontent.com/mapbox/postgis-vt-util/v1.0.0/postgis-vt-util.sql \
    && git clone --depth=1 https://github.com/openmaptiles/mapnik-german-l10n.git \
    && mv mapnik-german-l10n/plpgsql/* ${SQL_DIR}/ \
    && rm -rf mapnik-german-l10n

COPY import_data.sh ${MAIN_DIR}/import_data.sh
RUN chmod +x ${MAIN_DIR}/import_data.sh


# Prevent Caching
# According to: https://stackoverflow.com/questions/36996046/how-to-prevent-dockerfile-caching-git-clone
ADD https://api.github.com/repos/QwantResearch/kartotherian_config/git/refs/heads/master version.json
RUN git clone -b master https://github.com/QwantResearch/kartotherian_config.git ${MAIN_DIR}/config

RUN ln -s ${MAIN_DIR}/config/imposm/imposm3_mapping.yml ${MAIN_DIR}/imposm3_mapping.yml
RUN ln -s ${MAIN_DIR}/config/imposm/generated_sql.sql ${SQL_DIR}/generated_sql.sql

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

CMD ["sleep", "infinity"]
