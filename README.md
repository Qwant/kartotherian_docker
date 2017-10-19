# kartotherian_docker
docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

They use a mixed architecture of Kartotherian and [openmaptiles](https://github.com/openmaptiles/openmaptiles)

# setup

you should put the osm pbf data in a `data/` directory

# running

To launch kartotherian just do:

`docker-compose up`

(you might need `sudo` permissions depending on your setup)

to load data in postgres you need:

`docker exec -it kartotheriandocker_load_db_1 /srv/import_data/import_data.sh`

After this you need to generate the tiles. You can do it either by generating all the tiles with:
`docker exec -it kartotheriandocker_tilerator_1 /gen_tiles.sh`

or only a subset using the api.
For example to generate the tiles from 7 to 16 zoom level only on Köln:

`curl -XPOST "http://localhost:16534/add?generatorId=gen&storageId=v2&zoom=7&x=66&y=42&fromZoom=7&beforeZoom=16&keepJob=true&parts=8&deleteEmpty=true"`

You can check the tilegeneration at http://localhost:16534

And you can check the vector tiles at:

`http://localhost:8585/index.html`

# archi

![Tile generation](documentation/tile_gen.png)
![Tile use](documentation/tile_use.png)

# configuration files

The `load_db/generated_sql.sql` and `load_db/imposm3_mapping.yml` and `tilerator/data_tm2source.xml` files have been generated using [openmaptiles-tools](https://github.com/openmaptiles/openmaptiles-tools).

The SQL and imposm mapping generation is quite straigthforward (cf. `generate-sql` and `generate-imposm3` in the [documentation](https://github.com/openmaptiles/openmaptiles-tools/blob/master/README.md)).

The `data_tm2source.xml` generation is a bit more complex.

we use `generate-tm2source` to generate a `Carto` project `.yml` file.
This file is transformed manually to a Mapnik `.xml` project using [kosmtik](https://github.com/kosmtik/kosmtik).
