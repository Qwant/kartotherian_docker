# kartotherian_docker
docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

They use a mixed architecture of Kartotherian and [openmaptiles](https://github.com/openmaptiles/openmaptiles)

# setup

You should put the osm pbf data in a `data/` directory. If you're trying this for the first time, we recommend that you import a small country such as Luxembourg first. You can download the OSM extract from [Geofabrik](http://download.geofabrik.de/europe/luxembourg.html).

# running

To launch kartotherian just do:

`docker-compose up`

(you might need `sudo` permissions depending on your setup)

to load data in postgres you need:

`docker exec -it kartotheriandocker_load_db_1 /srv/import_data/import_data.sh`

Note: the first import might be quite long are some additional data will be downloaded (cf [load_db](https://github.com/QwantResearch/kartotherian_docker/blob/master/load_db/readme.md))

After this you need to generate the tiles. You can do it either by generating all the tiles with:
`docker exec -it kartotheriandocker_tilerator_1 /gen_tiles.sh`

or only a subset using the api. `x` & `y` are based on the [Slippy Map Tile name](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) system and you can use [Geofabrik's tool](http://download.geofabrik.de/europe/luxembourg.html) to generate these for a specific location.
For example to generate the tiles from 7 to 16 zoom level only for Luxembourg:

`curl -XPOST "http://localhost:16534/add?generatorId=substbasemap&storageId=basemap&zoom=7&x=66&y=43&fromZoom=7&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"
`
`curl -XPOST "http://localhost:16534/add?generatorId=gen_poi&storageId=poi&zoom=7&x=66&y=43&fromZoom=7&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"`

You can check the tilegeneration at `http://localhost:16534/jobs` and check a vector tile based map on `http://localhost:8585/index.html`


# archi

![Tile generation](documentation/tile_gen.png)
![Tile use](documentation/tile_use.png)

# configuration files

The `load_db/generated_sql.sql` and `load_db/imposm3_mapping.yml` and `tilerator/data_tm2source.xml` files have been generated using [openmaptiles-tools](https://github.com/openmaptiles/openmaptiles-tools).

The SQL and imposm mapping generation is quite straigthforward (cf. `generate-sql` and `generate-imposm3` in the [documentation](https://github.com/openmaptiles/openmaptiles-tools/blob/master/README.md)).

The `data_tm2source.xml` generation is a bit more complex.

we use `generate-tm2source` to generate a `Carto` project `.yml` file.
This file is transformed manually to a Mapnik `.xml` project using [kosmtik](https://github.com/kosmtik/kosmtik).

