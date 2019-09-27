load-db:
	docker-compose -f docker-compose.yml -f update-compose.yml run --rm load_db

update-tiles:	load-db
	docker-compose -f docker-compose.yml -f local-compose.yml run --rm run-osm-update

start:	load-db
	docker-compose -f docker-compose.yml -f local-compose.yml run --rm -e INVOKE_OSM_URL=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf -e INVOKE_TILES_X=66 -e INVOKE_TILES_Y=43 -e INVOKE_TILES_Z=7 load_db

shutdown:
	docker-compose -f docker-compose.yml -f local-compose.yml down -v

logs:
	docker-compose -f docker-compose.yml -f local-compose.yml logs $(args)
