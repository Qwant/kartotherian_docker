# kartotherian_docker
  docker images for the [kartotherian project](https://github.com/kartotherian/kartotherian)

# setup

you should put the osm pbf data in a `data/` directory

# running

To launch kartotherian just do:

`docker-compose up`

(you might need `sudo` permissions depending on your setup)

to load data you need:

`docker exec -it kartotheriandocker_load_db_1 /srv/import_data/import_data.sh && docker exec -it kartotheriandocker_tilerator_1 /gen_tiles.sh`

the first command is to load the osm data in postgresql, the second to generate all the tiles.

If you do not want to generate all the tiles (it might be quite long), you can request only a subset. 
For example to generate the tiles from 7 to 16 zoom level only on Köln:

`curl -XPOST "http://localhost:16534/add?generatorId=gen&storageId=v2&zoom=7&x=66&y=42&fromZoom=7&beforeZoom=16&keepJob=true&parts=8&deleteEmpty=true"`

you can check the tilegeneration at `http://localhost:16534` and check a vector tile based map on `http://localhost:8585/index.html`

# archi

![Tile generation](documentation/tile_gen.png)
![Tile use](documentation/tile_use.png)

