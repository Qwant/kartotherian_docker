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
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs


RUN git clone https://bitbucket.org/qmap/demultiplexer.git /opt/demultiplexer

RUN git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source

RUN git clone https://bitbucket.org/qmap/tilerator.git  /opt/tilerator && \
    cd /opt/tilerator && \
    git checkout 18c39cc


RUN cd /opt/tilerator && npm install --production && npm dedupe

RUN cd /opt/tilerator && \
    npm install git+https://github.com/openmaptiles/mapbox-studio-osm-bright.tm2.git

COPY omt_osm_bright.xml /opt/tilerator/node_modules/\@mapbox/mapbox-studio-osm-bright/project.xml

COPY variables.yaml /opt/tilerator
COPY sources.yaml /opt/tilerator
COPY config.yaml /opt/tilerator
COPY config.yaml /opt/tilerator
COPY gen_tiles.sh /gen_tiles.sh

RUN chmod +x /gen_tiles.sh
RUN chmod 600 /opt/tilerator/variables.yaml

COPY data_tm2source.xml /etc/tilerator/data_tm2source.xml

RUN mkdir -p /etc/tilerator
RUN ln -sf /opt/tilerator/config.yaml /etc/tilerator
RUN ln -sf /opt/tilerator/variables.yaml /etc/tilerator
RUN ln -sf /opt/tilerator/sources.yaml /etc/tilerator

RUN ln -sf /opt/tilerator/dist/init-scripts/cassandra.wait /usr/local/bin

# CMD /usr/local/bin/cassandra.wait && \
#    /usr/bin/nodejs /opt/tilerator/server.js -c /etc/tilerator/config.yaml

ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1; done"]
