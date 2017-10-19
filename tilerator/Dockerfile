FROM ubuntu:16.04

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
             postgis \
             redis-tools \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    && git clone https://bitbucket.org/qmap/demultiplexer.git /opt/demultiplexer \
    && git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source \
    && git clone https://bitbucket.org/qmap/tilerator.git  /opt/tilerator \
    && cd /opt/tilerator \
    && git checkout 18c39cc \
    && cd /opt/tilerator && npm install --production && npm dedupe

COPY variables.yaml /opt/tilerator
COPY sources.yaml /opt/tilerator
COPY config.yaml /opt/tilerator
COPY config.yaml /opt/tilerator
COPY gen_tiles.sh /gen_tiles.sh
COPY data_tm2source.xml /etc/tilerator/data_tm2source.xml

RUN chmod +x /gen_tiles.sh \
    && chmod 600 /opt/tilerator/variables.yaml \
    && mkdir -p /etc/tilerator \
    && ln -sf /opt/tilerator/config.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/variables.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/sources.yaml /etc/tilerator \
    && ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

COPY runserver.sh /runserver.sh
RUN chmod +x /runserver.sh

CMD ["/runserver.sh"]
