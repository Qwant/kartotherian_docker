FROM python:3.6-stretch

ENV MAIN_DIR=/srv

RUN apt-get update && \
    apt-get upgrade -y openssl && \
    apt-get install -y --no-install-recommends \
        git \
        unzip \
        curl \
        osmctools \
        gdal-bin \
        postgis \
        postgresql-client \
        jq \
    && rm -rf /var/lib/apt/lists/* \
# install imposm 0.11.0 (custom release, waiting for https://github.com/omniscale/imposm3/pull/206 to be merged)
    && wget https://github.com/qwant/imposm3/releases/download/v0.11.0-qwant.1/imposm-0.11.0-qwant.1-linux-x86-64.tar.gz \
    && tar xvfz imposm-0.11.0-qwant.1-linux-x86-64.tar.gz \
    && ln -sf /imposm-0.11.0-qwant.1-linux-x86-64/imposm /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter \
    && pip install pipenv==2018.11.26

# install openmaptiles
COPY openmaptiles /opt/openmaptiles
COPY import_data ${MAIN_DIR}/import_data

RUN mkdir -p ${MAIN_DIR}/imposm \
    && mkdir -p ${MAIN_DIR}/import_data/imposm/

# needed for sql script, else the BOM in the file makes the query impossible
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN cd ${MAIN_DIR}/import_data \
    && pipenv install --system --deploy

# generate imposm files \
RUN mkdir -p ${MAIN_DIR}/tilerator \
    && ln -s ${MAIN_DIR}/import_data/* ${MAIN_DIR}/imposm/ \
    && cd /opt/openmaptiles \
    && rm -f /usr/bin/python3 \
    && ln -s `which python3.6` /usr/bin/python3 \
    && CONFIG_DIR=${MAIN_DIR} make qwant

WORKDIR ${MAIN_DIR}/import_data

COPY load_db/import_data.sh ./import_data.sh
COPY load_db/config.yml ./config.yml
RUN chmod +x ./import_data.sh

ENTRYPOINT ["./import_data.sh"]
