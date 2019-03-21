# kartotherian_docker

docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

They use a mixed architecture of Kartotherian and [openmaptiles](https://github.com/openmaptiles/openmaptiles)
You need a docker version > 18.06

## "Quick" Start for local testing

Use these commmands to download, import data and create tiles jobs for Luxembourg:

(Optional) First, delete all related containers and volumes (from an older import):

**If sudo required, use "-E"!!**

```bash
docker-compose -f docker-compose.yml -f local-compose.yml down -v
```

Download, import and start the tiles generation:

```bash
docker-compose -f docker-compose.yml -f local-compose.yml up --build -d
docker-compose -f docker-compose.yml -f local-compose.yml run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf -e INVOKE_TILES_X=66 -e INVOKE_TILES_Y=43 -e INVOKE_TILES_Z=7 load_db
```

Once all tiles are generated, the map is visible on http://localhost:8585 !

## running

To launch kartotherian just do:

`docker-compose up --build -d`

(you might need `sudo` permissions depending on your setup)

### Import in Postgres

to download a pbf and load data in postgres and generate tiles you need:

`docker-compose run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf -e INVOKE_TILES_X=66 -e INVOKE_TILES_Y=43 -e INVOKE_TILES_Z=7 load_db`

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

Note: even if the local directoy in `./data` the osm file path is "/data/**input**/" because it's the directory path inside the container.

### Tiles generation

The tiles generation is also handle by the `load_db` container.

To only generate 1 tile, you can set `INVOKE_TILES_X`, `INVOKE_TILES_Y`, `INVOKE_TILES_Z`. x, y, and z are based on the [Slippy Map Tile name](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) system and you can use [Geofabrik's tool](https://tools.geofabrik.de/calc/#6/51.25727/10.45457&type=Mapnik&grid=1) to generate these for a specific location.

The different ways to configure the tiles generation can be seen [in the default configuration file](https://github.com/QwantResearch/kartotherian_config/blob/master/import_data/invoke.yaml).

If you have forwarded the port, you can check the tile generation at `http://localhost:16534/jobs` and check a vector tile based map on `http://localhost:8585`


### Updating tiles

During the initial creation of the PG database, state and configuration files is initialized in the `update_tiles_data` volume from the .pbf metadata.
To launch the tiles update, run the `run_osm_update` task (defined in load_db tasks):

`docker-compose -f docker-compose.yml -f update-compose.yml run --rm load_db run-osm-update`

During this task:
 * osmosis will fetch latest changes from openstreetmap.org
 * imposm will apply these changes in the pg databse, and write a file with expired tiles
 * tilerator jobs will be created to generate new tiles


## archi

The tile server architecture can be seen at [QwantMaps](https://github.com/QwantResearch/qwantmaps#global-picture)

## configuration files

Most configuration files are imported from [kartotherian_config](https://github.com/QwantResearch/kartotherian_config) repository.
Among them, `generated_*.sql`, imposm `generated_mapping_*.yml` and `data_tm2source_*.xml` files have been generated using [openmaptiles-tools](https://github.com/openmaptiles/openmaptiles-tools).

The SQL and imposm mapping generation is quite straigthforward (cf. `generate-sql` and `generate-imposm3` in the [documentation](https://github.com/openmaptiles/openmaptiles-tools/blob/master/README.md)).

The `data_tm2source_*.xml` generation is a bit more complex. We use `generate-tm2source` to generate a `Carto` project `.yml` file. This file is transformed to a Mapnik `.xml` project using [kosmtik](https://github.com/kosmtik/kosmtik).

See more details on https://github.com/QwantResearch/openmaptiles
