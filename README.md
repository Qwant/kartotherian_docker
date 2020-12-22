# kartotherian_docker

docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

They use a mixed architecture of Kartotherian and [openmaptiles](https://github.com/openmaptiles/openmaptiles)
You need a docker version > 18.06

## "Quick" Start for local testing

Use these commmands to download, import data and create tiles jobs for Luxembourg:

(Optional) First, delete all related containers and volumes (from an older import):

**If sudo required, use "-E"!!**

```bash
./exec.py clean
```

Download, import and start the tiles generation (of Luxembourg by default):

```bash
./exec.py load-db # it runs the build command as a dependency on 'load-db'
```

Once all tiles are generated, the map is visible on `http://localhost:8585`! (If not, take a look at `docker ps` and see what the port of the image `qwantresearch/erdapfel` is.)

If you want to see the list of all available commands, use `-h` or `--help` option on `exec.py`.

## Workflow

If you want to update the generation process, you need to edit [Qwant/openmaptiles](https://github.com/Qwant/openmaptiles) then update the openmaptiles submodule.

## running

To launch kartotherian just do:

`./exec.py kartotherian`

(you might need `sudo` permissions depending on your setup)

### Import in Postgres

to download a pbf and load data in postgres and generate tiles you need:

`./exec.py load-db`

Note that you can specify the PBF you want to give by using the `--osm-file` option.

The different way to configure the import can be seen in [this readme](./import_data/README.md).

Note: the first import might be quite long are some additional data will be downloaded (cf [load_db](./load_db/README.md))

If you want to use already downloaded data (especially usefull for a quicker dev cycle), you can use a mounted docker volume.

The file `local-compose.yml` gives an example of how to bind a named docker volume (the file uses a `./data` directory but you can change it if you want).

To use a locally mounted volume add the `local-compose.yml` with the `-f` docker-compose option.

For an easier dev experience, you can use the docker-compose additional file `local-compose.yml` that forward ports, use a locally `./data` mounted volume (to avoid some unnecessary download) and run a front end to view the tiles.

For example with this setup you can also provide an already downloaded pbf (it needs to be in the `./data` volume) with `--osm-file`:

```bash
./exec.py --osm-file /data/input/luxembourg-latest.osm.pbf load-db
```

Note: even if the local directoy in `./data` the osm file path is "/data/**input**/" because it's the directory path inside the container.

You can also specify a download url:

```bash
./exec.py --osm-file https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf load-db
```

### Tiles generation

The tiles generation is also handle by the `load_db` container.

To only generate 1 tile, you can set `--tiles-coords [[x, y, z]]`. x, y, and z are based on the [Slippy Map Tile name](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) system and you can use [Geofabrik's tool](https://tools.geofabrik.de/calc/#6/51.25727/10.45457&type=Mapnik&grid=1) to generate these for a specific location.

The different ways to configure the tiles generation can be seen [in the default configuration file](https://github.com/Qwant/kartotherian_docker/blob/master/import_data/invoke.yaml).

If you have forwarded the port, you can check the tile generation at `http://localhost:16534/jobs` and check a vector tile based map on `http://localhost:8585`


### Updating tiles

During the initial creation of the PG database, state and configuration files is initialized in the `update_tiles_data` volume from the .pbf metadata.
To launch the tiles update, run the `update-tiles` task (defined in load_db tasks):

`./exec.py update-tiles`

During this task:
 * osmosis will fetch latest changes from openstreetmap.org
 * imposm will apply these changes in the pg databse, and write a file with expired tiles
 * tilerator jobs will be created to generate new tiles


## archi

The tile server architecture can be seen at [QwantMaps](https://github.com/QwantResearch/qwantmaps#global-picture)

### sub-folders

Normally you shouldn't need to change anything in the subfolders: everything is handled inside the docker files through `exec.py`. However, if you're interested in what these sub-folders are used for, go take a look to their `README.md` file.

## configuration files

The SQL and imposm mapping generation is quite straigthforward (cf. `generate-sql` and `generate-imposm3` in the [documentation](https://github.com/openmaptiles/openmaptiles-tools/blob/master/README.md)).

The `data_tm2source_*.xml` generation is a bit more complex. We use `generate-tm2source` to generate a `Carto` project `.yml` file. This file is transformed to a Mapnik `.xml` project using [kosmtik](https://github.com/kosmtik/kosmtik).

See more details on https://github.com/Qwant/openmaptiles
