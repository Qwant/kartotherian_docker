# kartotherian_docker
docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

They use a mixed architecture of Kartotherian and [openmaptiles](https://github.com/openmaptiles/openmaptiles)


## "Quick" Start for local testing

Use these commmands to download, import data and create tiles jobs for Luxembourg:

(Optional) First, delete all related containers and volumes (from an older import):

```bash
docker-compose -f docker-compose.yml -f local-compose.yml down -v
```

Download, import and start the tiles generation:

```bash
docker-compose -f docker-compose.yml -f local-compose.yml up --build -d
docker-compose -f docker-compose.yml -f local-compose.yml run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf load_db

curl -XPOST "http://localhost:16534/add?generatorId=substbasemap&storageId=basemap&zoom=7&x=66&y=43&fromZoom=0&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"
curl -XPOST "http://localhost:16534/add?generatorId=gen_poi&storageId=poi&zoom=7&x=66&y=43&fromZoom=14&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"
```

Once all tiles are generated, the map is visible on http://localhost:8585 !


## running

To launch kartotherian just do:

`docker-compose up --build -d`

(you might need `sudo` permissions depending on your setup)

### Import in Postgres

to download a pbf and load data in postgres you need:

`docker-compose run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf load_db`

The different way to configure the import can be seen in the [script repository](https://github.com/QwantResearch/kartotherian_config/blob/master/import_data)

Note: the first import might be quite long are some additional data will be downloaded (cf [load_db](https://github.com/QwantResearch/kartotherian_docker/blob/master/load_db/readme.md))

if you want to use already downloaded data (especially usefull for a quicker dev cycle), you can use a mounted docker volume.

The file `local-compose.yml` gives an example of how to bind a named docker volume (the file uses a `./data` directory but you can change it if you want).

To use a locally mounted volume add the `local-compose.yml` with the `-f` docker-compose option.

If you want to use a specific osm file, you can set `INVOKE_OSM_FILE` instead of `INVOKE_OSM_URL`.

For an easier dev experience, you can use the docker-compose additional file `local-compose.yml` that forward ports, use a locally `./data` mounted volume (to avoid some unnecessary download) and run a front end to view the tiles.

For example with this setup you can also provide an already downloaded pbf (it needs to be in the `./data` volume) with `INVOKE_OSM_FILE`:

```bash
docker-compose -f docker-compose.yml -f local-compose.yml up --build -d
docker-compose -f docker-compose.yml -f local-compose.yml run --rm -e INVOKE_OSM_FILE=/data/input/luxembourg-latest.osm.pbf load_db
```

Note: even if the local directoy in `./data` the osm file path is "/data/**input**/ because it's the directory path inside the container.

### Tiles generation

After this you need to generate the tiles. You can do it either by generating all the tiles with:
`docker exec -it kartotheriandocker_tilerator_1 /gen_tiles.sh`

or only a subset using the api. `x` & `y` are based on the [Slippy Map Tile name](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) system and you can use [Geofabrik's tool](http://download.geofabrik.de/europe/luxembourg.html) to generate these for a specific location.
For example to generate the tiles from 7 to 16 zoom level only for Luxembourg:

`curl -XPOST "http://localhost:16534/add?generatorId=substbasemap&storageId=basemap&zoom=7&x=66&y=43&fromZoom=7&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"`

`curl -XPOST "http://localhost:16534/add?generatorId=gen_poi&storageId=poi&zoom=7&x=66&y=43&fromZoom=7&beforeZoom=15&keepJob=true&parts=8&deleteEmpty=true"`

You can check the tile generation at `http://localhost:16534/jobs` and check a vector tile based map on `http://localhost:8585`

## archi

The tile server architecture can be seen at [QwantMaps](https://github.com/QwantResearch/qwantmaps#global-picture)

## configuration files

Most configuration files are imported from [kartotherian_config](https://github.com/QwantResearch/kartotherian_config) repository.
Among them, `generated_*.sql`, imposm `generated_mapping_*.yml` and `data_tm2source_*.xml` files have been generated using [openmaptiles-tools](https://github.com/openmaptiles/openmaptiles-tools).

The SQL and imposm mapping generation is quite straigthforward (cf. `generate-sql` and `generate-imposm3` in the [documentation](https://github.com/openmaptiles/openmaptiles-tools/blob/master/README.md)).

The `data_tm2source_*.xml` generation is a bit more complex. We use `generate-tm2source` to generate a `Carto` project `.yml` file. This file is transformed to a Mapnik `.xml` project using [kosmtik](https://github.com/kosmtik/kosmtik).

See more details on https://github.com/QwantResearch/openmaptiles
