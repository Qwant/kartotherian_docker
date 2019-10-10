# Dockerfile to load all the data in the database

It is based on the [openmaptiles](https://github.com/openmaptiles) architecture which is based on [imposm3](https://imposm.org).

Data should be loaded in a database with the `postgis`, `hstore`, and `osml10n` extensions.

## Data sources

Many data sources are used:

* A `.pbf` file containing osm data.
* [natural earth](http://www.naturalearthdata.com/) data.
* A [precise water polygon](http://data.openstreetmapdata.com/water-polygons-split-3857.zip) from openstreetmap.
* Some [precise lake borders](https://github.com/lukasmartinelli/osm-lakelines/releases/download/v0.9/lake_centerline.geojson).
* Some borders (in `.csv` files), either computed from the osm `.pbf` file, or a [precomputed file](https://github.com/openmaptiles/import-osmborder/releases/download/v0.1/osmborder_lines.csv). The generation/import of a generated file can be found [here](https://github.com/openmaptiles/import-osmborder).

Because of the size of the dataset, they are downloaded only if not present in the directory.
