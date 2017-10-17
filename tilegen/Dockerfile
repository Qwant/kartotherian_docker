FROM ubuntu:16.04 as osm2pgsql_builder
RUN mkdir /osm2pgsql 
WORKDIR /osm2pgsql

RUN apt update && \
    apt install -y \
    make \
    wget \
    cmake \
    g++ \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libexpat1-dev \
    zlib1g-dev \
    libbz2-dev \
    libpq-dev \
    libproj-dev \
    lua5.2 \
    liblua5.2-dev \
    libgeos++-dev

RUN wget https://github.com/openstreetmap/osm2pgsql/archive/0.92.1.tar.gz
RUN tar xvfz 0.92.1.tar.gz && mv osm2pgsql-0.92.1/* .
RUN mkdir build && cd build && cmake .. && make -j 4

FROM ubuntu:16.04

COPY --from=osm2pgsql_builder /osm2pgsql/build/osm2pgsql /usr/local/bin
COPY --from=osm2pgsql_builder /osm2pgsql/default.style /usr/local/share/osm2pgsql/default.style

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
        libcunit1-dev \
        libkakasi2-dev \
        libtool \
        pandoc \
        unzip \
        xsltproc \
        # PostGIS build dependencies
            libgdal-dev \
            libjson0-dev \
            libutf8proc-dev \
             postgresql-server-dev-9.5 \
            libproj-dev \
libxml2-dev \
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs

# RUN wget --quiet http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
#     && unzip -oj natural_earth_vector.sqlite.zip -d /import \
#     && rm natural_earth_vector.sqlite.zip

RUN wget https://imposm.org/static/rel/imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    tar xvfz imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    ln -sf /imposm3-0.4.0dev-20170519-3f00374-linux-x86-64/imposm3 /usr/local/bin/imposm3 

# water polygons
RUN wget --quiet http://data.openstreetmapdata.com/water-polygons-split-3857.zip \
    && unzip -oj water-polygons-split-3857.zip -d /import \
    && rm water-polygons-split-3857.zip \
    && wget --quiet http://data.openstreetmapdata.com/simplified-water-polygons-complete-3857.zip \
    && unzip -oj simplified-water-polygons-complete-3857.zip -d /import \
    && rm simplified-water-polygons-complete-3857.zip 

# lake borders
RUN  wget --quiet -L -P /import https://github.com/lukasmartinelli/osm-lakelines/releases/download/v0.9/lake_centerline.geojson

# borders
# RUN wget -O pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
#     && chmod +x pgfutter \
#     && mv pgfutter /usr/local/bin/ \
#     && mkdir -p /import \
#     && wget -O /import/osmborder_lines.csv https://github.com/openmaptiles/import-osmborder/releases/download/v0.1/osmborder_lines.csv && \
#     wget -O /usr/local/bin/import_osmborder_lines.sh https://raw.githubusercontent.com/openmaptiles/import-osmborder/master/import/import_osmborder_lines.sh && \
#     chmod +x /usr/local/bin/import_osmborder_lines.sh

#TODO 
#http://www.nominatim.org/data/country_grid.sql.gz


RUN git clone --depth=1 https://github.com/openmaptiles/import-sql.git
RUN git clone --depth=1 https://github.com/openmaptiles/mapnik-german-l10n.git \
    && cd mapnik-german-l10n \
    && make \
    && make install

COPY import_data.sh /
COPY import_water.sh /
RUN chmod +x /import_data.sh && \
    chmod +x /import_water.sh

COPY imposm3_mapping.yml /imposm3_mapping.yml

RUN git clone --branch v1.0.0 --depth=1 https://github.com/mapbox/postgis-vt-util.git
COPY generated_sql.sql /generated_sql.sql

RUN git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source && \
    cd opt/osm-bright.tm2source && \
    npm install --production

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1; done"]