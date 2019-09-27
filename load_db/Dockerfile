FROM python:3.6-stretch@sha256:bccbebc715c9b0c0bf247ba3781248c1b0d075d5ef462ee86a396a394a19f6b0

ENV MAIN_DIR=/srv/import_data

RUN apt-get update && \
    apt-get install -y \
        git \
        unzip \
        curl \
        libpq-dev \
        libproj-dev \
        liblua5.2-dev \
        libgeos++-dev \
        osmctools \
        sqlite3 \
        gdal-bin \
        postgis \
        osmosis \
        jq \
# install imposm
    && wget https://github.com/omniscale/imposm3/releases/download/v0.6.0-alpha.4/imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && tar xvfz imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && ln -sf /imposm-0.6.0-alpha.4-linux-x86-64/imposm3 /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter \
    && pip install pipenv==2018.11.26

# install openmaptiles
COPY openmaptiles /opt/openmaptiles

COPY import_data ${MAIN_DIR}/import_data

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL C.UTF-8

RUN cd ${MAIN_DIR}/import_data \
    && pipenv install --system --deploy

# generate imposm files
RUN mkdir -p ${MAIN_DIR}/imposm \
    && mkdir -p ${MAIN_DIR}/tilerator \
    && ln -s ${MAIN_DIR}/import_data/* ${MAIN_DIR}/imposm/ \
    && cd /opt/openmaptiles \
    && rm -f /usr/bin/python3 \
    && ln -s `which python3.6` /usr/bin/python3 \
    && CONFIG_DIR=${MAIN_DIR} make qwant

WORKDIR ${MAIN_DIR}/import_data

COPY load_db/import_data.sh ./import_data.sh
COPY load_db/config.yml ./config.yml
RUN chmod +x ./import_data.sh
RUN chmod +x ./osm_update.sh

ENTRYPOINT ["./import_data.sh"]
