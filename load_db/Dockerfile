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

RUN git clone https://github.com/QwantResearch/kartotherian_config.git ${MAIN_DIR}/config \
    && cd ${MAIN_DIR}/config \
	&& git checkout 0af5aba6e6657c8b42842704947108c33934197a \
	&& git submodule update --init

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
