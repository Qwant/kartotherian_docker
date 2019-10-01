build:
	docker-compose -f docker-compose.yml -f local-compose.yml up --build -d

load-db:	build
	sleep 5 # add into the script a function to check if postgresql is up
	docker-compose -f docker-compose.yml -f local-compose.yml run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf -e INVOKE_TILES_X=66 -e INVOKE_TILES_Y=43 -e INVOKE_TILES_Z=7 load_db

update-tiles:	load-db
	docker-compose -f docker-compose.yml -f local-compose.yml run --rm load_db run-osm-update

shutdown:
	docker-compose -f docker-compose.yml -f local-compose.yml down -v

logs:
	docker-compose -f docker-compose.yml -f local-compose.yml logs $(args)
