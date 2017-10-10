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
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x && \
    apt-get install -y nodejs npm

COPY import_data.sh /
RUN chmod +x /import_data.sh

RUN git clone https://bitbucket.org/qmap/osm-bright.tm2source.git /opt/osm-bright.tm2source && \
    cd opt/osm-bright.tm2source && \
    npm install --production

# needed for sql script, else the BOM in the file makes the query impossible
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ENTRYPOINT ["/bin/sh", "-c", "while true; do sleep 1; done"]
