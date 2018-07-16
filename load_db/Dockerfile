FROM python:3.6-stretch


ENV MAIN_DIR=/srv/import_data \
    SQL_DIR=/srv/import_data/sql \
    DATA_DIR=/data \
    REDIS_SET_KEY=true
# nb: REDIS_SET_KEY is overriden in k8s configmap

RUN apt update && \
    apt install -y \
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
             redis-tools \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    # install imposm
    && wget https://imposm.org/static/rel/imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    tar xvfz imposm3-0.4.0dev-20170519-3f00374-linux-x86-64.tar.gz && \
    ln -sf /imposm3-0.4.0dev-20170519-3f00374-linux-x86-64/imposm3 /usr/local/bin/imposm3 \
    && wget -O /usr/local/bin/pgfutter https://github.com/lukasmartinelli/pgfutter/releases/download/v1.1/pgfutter_linux_amd64 \
    && chmod +x /usr/local/bin/pgfutter \
    && mkdir -p ${SQL_DIR} \
    && pip install pipenv

# Prevent Caching
# According to: https://stackoverflow.com/questions/36996046/how-to-prevent-dockerfile-caching-git-clone
ADD https://api.github.com/repos/QwantResearch/kartotherian_config/git/refs/heads/master version.json
RUN git clone -b master https://github.com/QwantResearch/kartotherian_config.git ${MAIN_DIR}/config
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

RUN pipenv install --system --deploy

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8  
ENV LANG C.UTF-8
ENV LANGUAGE en_US:en  
ENV LC_ALL C.UTF-8

ENTRYPOINT ["./import_data.sh"]
