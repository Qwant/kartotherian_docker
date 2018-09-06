FROM python:3.6-stretch


ENV MAIN_DIR=/srv/import_data \
    SQL_DIR=/srv/import_data/sql \
    DATA_DIR=/data \
    REDIS_SET_KEY=true
# nb: REDIS_SET_KEY is overriden in k8s configmap


RUN apt-get update && \
    apt-get install -y \
        git \
        unzip \
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
        osmosis \
        jq \
        redis-tools \
# install imposm
    && wget https://github.com/omniscale/imposm3/releases/download/v0.6.0-alpha.4/imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && tar xvfz imposm-0.6.0-alpha.4-linux-x86-64.tar.gz \
    && ln -sf /imposm-0.6.0-alpha.4-linux-x86-64/imposm3 /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter \
    && mkdir -p ${SQL_DIR} \
    && pip install pipenv

RUN git clone https://github.com/QwantResearch/kartotherian_config.git ${MAIN_DIR}/config \
    && cd ${MAIN_DIR}/config \
    && git checkout 738abe8c1060ef104be379087612b3a5b6348cfe

RUN cd ${MAIN_DIR}/config && git submodule update --init
RUN ln -s ${MAIN_DIR}/config/imposm/generated_mapping_base.yaml ${MAIN_DIR}/generated_mapping_base.yaml
RUN ln -s ${MAIN_DIR}/config/imposm/generated_mapping_poi.yaml ${MAIN_DIR}/generated_mapping_poi.yaml
RUN ln -s ${MAIN_DIR}/config/imposm/generated_base.sql ${SQL_DIR}/generated_base.sql
RUN ln -s ${MAIN_DIR}/config/imposm/generated_poi.sql ${SQL_DIR}/generated_poi.sql

RUN ln -s ${MAIN_DIR}/config/external_dependencies/import-osmborder/import/import_osmborder_lines.sh ${MAIN_DIR}/
RUN ln -s ${MAIN_DIR}/config/external_dependencies/import-water/import-water.sh ${MAIN_DIR}/
RUN ln -s ${MAIN_DIR}/config/external_dependencies/import-sql/language.sql ${SQL_DIR}/
RUN ln -s ${MAIN_DIR}/config/external_dependencies/postgis-vt-util/postgis-vt-util.sql ${SQL_DIR}/

WORKDIR ${MAIN_DIR}/config/import_data

COPY import_data.sh ./import_data.sh
COPY config.yml ./config.yml
RUN chmod +x ./import_data.sh
RUN chmod +x ./osm_update.sh

RUN pipenv install --system --deploy

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL C.UTF-8

ENTRYPOINT ["./import_data.sh"]
