FROM ubuntu:16.04

ENV NODE_PATH='/opt/kartotherian/node_modules' \
    KARTOTHERIAN_PORT=6533

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
             netcat \
             net-tools \
             libcairo2-dev libjpeg8-dev libpango1.0-dev libgif-dev build-essential g++ \
             postgis && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs

RUN git clone https://github.com/QwantResearch/kartotherian.git /opt/kartotherian \
    && cd /opt/kartotherian \
    && git checkout c4fc56843f \
    && npm install --production && npm dedupe \
    && git clone https://github.com/QwantResearch/kartotherian_config.git /opt/kartotherian_config \
    && cd /opt/kartotherian_config \
    && git checkout f7231c109ca4e4c35cc68427f76336b9f8758ad6

# .xml style is overridden to use system fonts (DejaVu instead of Arial)
COPY omt_osm_bright.xml /opt/kartotherian/node_modules/\@mapbox/mapbox-studio-osm-bright/project.xml

COPY variables.yaml /opt/kartotherian
COPY config.yaml /opt/kartotherian

RUN chmod 600 /opt/kartotherian/variables.yaml

RUN mkdir -p /etc/kartotherian\
    && ln -sf /opt/kartotherian/config.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian/variables.yaml /etc/kartotherian\
    && ln -sf /opt/kartotherian_config/kartotherian/sources.yaml /etc/kartotherian

CMD /usr/bin/nodejs /opt/kartotherian/server.js -c /etc/kartotherian/config.yaml
