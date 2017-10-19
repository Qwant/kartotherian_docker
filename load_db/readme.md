# Dockerfile to load all the data in the database

it is based on the [openmaptiles](https://github.com/openmaptiles) architecture which is based on [imposm3](https://imposm.org).

Those data should be loaded in a database with the extension `postgis`, `hstore`, and `osml10n`.

## data sources
Many data sources are used:

* a .pbf file containing osm data
* [natural earth](http://www.naturalearthdata.com/) data
* a [precise water polygon](http://data.openstreetmapdata.com/water-polygons-split-3857.zip) from openstreetmap
* some [precise lake borders](https://github.com/lukasmartinelli/osm-lakelines/releases/download/v0.9/lake_centerline.geojson)
* some borders (in .csv), either computed from the osm .pbf file, or a [precomputed file](https://github.com/openmaptiles/import-osmborder/releases/download/v0.1/osmborder_lines.csv). The generation/import of a generated file can be found [here](https://github.com/openmaptiles/import-osmborder)
* some [country shapes](http://www.nominatim.org/data/country_grid.sql.gz) from nominatim.

TODO: understand the differences between the country shapes and the borders.

Because of the size of the data, they are downloaded only if not present in the shared `data/` directory.
