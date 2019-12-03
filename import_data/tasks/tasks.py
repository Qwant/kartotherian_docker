import concurrent.futures
import csv
import sys
import logging
import json
import gzip
import psycopg2
import psycopg2.extras
import os
import os.path
import time
from datetime import timedelta
import requests
from invoke import task
from invoke.exceptions import Failure
import osmium

from .lock import FileLock
from .download import needs_to_download, download_file
from .format_stdout import format_stdout

cc_exec = concurrent.futures.ThreadPoolExecutor()

logging.basicConfig(level=logging.INFO)


class TilesLayer:
    BASEMAP = 'basemap'
    POI = 'poi'


def _open_sql_connection(ctx, db):
    connection = psycopg2.connect(
        user=ctx.pg.user,
        dbname=db,
        host=ctx.pg.host,
        password=ctx.pg.password,
        port=ctx.pg.port
    )
    psycopg2.extras.register_hstore(connection, globally=True)
    return connection


def _execute_sql(ctx, sql, db=None, additional_options=""):
    query = f'psql -Xq -h {ctx.pg.host} -p {ctx.pg.port} -U {ctx.pg.user} -c "{sql}" {additional_options}'
    if db is not None:
        query += f" -d {db}"
    return ctx.run(
        query,
        env={"PGPASSWORD": ctx.pg.password}
    )


def _db_exists(ctx, db_name):
    has_db = _execute_sql(
        ctx,
        f"SELECT 1 FROM pg_database WHERE datname='{db_name}';",
        additional_options="-tA",
    )
    return has_db.stdout == "1\n"


def _wait_until_postgresql_is_ready(ctx):
    logging.info(f'Trying to connect to postgres...')
    query = f'pg_isready -h {ctx.pg.host} -p {ctx.pg.port} -U {ctx.pg.user}'
    x = 0
    while x < 30:
        try:
            ctx.run(query, env={"PGPASSWORD": ctx.pg.password})
            logging.info(f'Success!')
            return
        except:
            logging.info(f'Connection to postgres failed, remaining {30 - x} attempts...')
        time.sleep(1)
        x += 1
    raise Exception("PostgreSQL doesn't seem to ready, aborting...")


@task
def prepare_db(ctx):
    _wait_until_postgresql_is_ready(ctx)
    """
    create the import database and remove the old backup one
    """
    _execute_sql(ctx, f"DROP DATABASE IF EXISTS {ctx.pg.import_database};")

    logging.info(f"creating {ctx.pg.import_database} database")
    _execute_sql(ctx, f"CREATE DATABASE {ctx.pg.import_database};")
    _execute_sql(
        ctx,
        db=ctx.pg.import_database,
        sql="""
CREATE EXTENSION postgis;
CREATE EXTENSION hstore;
CREATE EXTENSION unaccent;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION osml10n;""",
    )

    _execute_sql(ctx, f"DROP DATABASE IF EXISTS {ctx.pg.backup_database};")


def _get_osmupdate_options(ctx, box=None):
    bbox_filter = ""
    if box is not None:
        bot_left = box.bottom_left
        top_right = box.top_right
        bbox_filter = f"-b={bot_left.lon},{bot_left.lat},{top_right.lon},{top_right.lat}"
    return f"-v --day --hour --base-url={ctx.osm_update.replication_url} {bbox_filter}"


@task
def get_osm_data(ctx):
    """
    download the osm file and store it in the input_data directory
    """
    logging.info("downloading osm file from %s", ctx.osm.url)
    file_name = os.path.basename(ctx.osm.url)

    new_osm_file = os.path.join(ctx.data_dir, file_name)
    if ctx.osm.file is not None and ctx.osm.file != new_osm_file:
        logging.warning(
            f"the osm variable has been configured to {ctx.osm_file}, "
            f"but this will not be taken into account as we will use a newly downloaded file: {new_osm_file}"
        )
    ctx.osm.file = new_osm_file
    download_file(ctx, new_osm_file, ctx.osm.url, max_age=timedelta(days=3))

    if ctx.osm.update_pbf:
        pbf_reader = osmium.io.Reader(new_osm_file)
        pbf_bbox = pbf_reader.header().box()
        if pbf_bbox is not None and pbf_bbox.size() > 60000:
            # This looks like a planet file: bbox filter is unnecessary
            pbf_bbox = None
        osmupdate_opts = _get_osmupdate_options(ctx, pbf_bbox)
        updated_pbf = f"{new_osm_file}.updated.pbf"
        try:
            ctx.run(f'osmupdate {osmupdate_opts} {new_osm_file} {updated_pbf}')
        except Failure as exc:
            if exc.result.return_code == 21:
                logging.info('OSM pbf file is up to date')
                return
            raise
        os.replace(updated_pbf, new_osm_file)


# imposm import
################

def _run_imposm_import(ctx, mapping_filename, tileset_name):
    ctx.run(
        f'time imposm3 \
  import \
  -write --connection "postgis://{ctx.pg.user}:{ctx.pg.password}@{ctx.pg.host}:{ctx.pg.port}/{ctx.pg.import_database}" \
  -read {ctx.osm.file} \
  -diff \
  -mapping {os.path.join(ctx.imposm_config_dir, mapping_filename)} \
  -deployproduction -overwritecache \
  -optimize \
  -quiet \
  -diffdir {ctx.generated_files_dir}/diff/{tileset_name} -cachedir {ctx.generated_files_dir}/cache/{tileset_name} \
  -dbschema-import {tileset_name}'
    )


@task
def load_basemap(ctx):
    _run_imposm_import(ctx, 'generated_mapping_base.yaml', TilesLayer.BASEMAP)


@task
def load_poi(ctx):
    _run_imposm_import(ctx, 'generated_mapping_poi.yaml', TilesLayer.POI)


def _run_sql_script(ctx, script_name):
    script_path = os.path.join(ctx.imposm_config_dir, script_name)
    ctx.run(
        f"psql -Xq -h {ctx.pg.host} -U {ctx.pg.user} -d {ctx.pg.import_database} -p {ctx.pg.port} --set ON_ERROR_STOP='1' -f {script_path}",
        env={"PGPASSWORD": ctx.pg.password},
    )


@task
def run_sql_script(ctx):
    # load several psql functions
    _run_sql_script(ctx, "import-sql/language.sql")
    _run_sql_script(ctx, "postgis-vt-util/postgis-vt-util.sql")


# non-OSM data import
#######################
def _get_pg_conn(ctx):
    return f"dbname={ctx.pg.import_database} " \
        f"user={ctx.pg.user} " \
        f"password={ctx.pg.password} " \
        f"host={ctx.pg.host} " \
        f"port={ctx.pg.port}"


@task
@format_stdout
def import_natural_earth(ctx):
    logging.info("importing natural earth shapes in postgres")
    target_file = f"{ctx.data_dir}/natural_earth_vector.sqlite"

    if needs_to_download(ctx, target_file, max_age=timedelta(days=30)):
        ctx.run(
            f"wget --progress=dot:giga http://naciscdn.org/naturalearth/packages/natural_earth_vector.sqlite.zip \
        && unzip -oj natural_earth_vector.sqlite.zip -d {ctx.data_dir} \
        && rm natural_earth_vector.sqlite.zip"
        )

    pg_conn = _get_pg_conn(ctx)
    ctx.run(
        f'PGCLIENTENCODING=LATIN1 ogr2ogr \
    -progress \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    -clipsrc -180.1 -85.0511 180.1 85.0511 \
    PG:"{pg_conn}" \
    -lco GEOMETRY_NAME=geometry \
    -lco DIM=2 \
    -nlt GEOMETRY \
    -overwrite \
    {ctx.data_dir}/natural_earth_vector.sqlite'
    )


@task
@format_stdout
def import_water_polygon(ctx):
    logging.info("importing water polygon shapes in postgres")

    target_file = f"{ctx.data_dir}/water_polygons.shp"
    if needs_to_download(ctx, target_file, max_age=timedelta(days=30)):
        ctx.run(
            f"wget --progress=dot:giga {ctx.water.polygons_url} \
    && unzip -oj water-polygons-split-3857.zip -d {ctx.data_dir} \
    && rm water-polygons-split-3857.zip"
        )

    ctx.run(
        f"POSTGRES_PASSWORD={ctx.pg.password} POSTGRES_PORT={ctx.pg.port} IMPORT_DATA_DIR={ctx.data_dir} \
  POSTGRES_HOST={ctx.pg.host} POSTGRES_DB={ctx.pg.import_database} POSTGRES_USER={ctx.pg.user} \
  {ctx.imposm_config_dir}/import-water/import-water.sh"
    )


@task
@format_stdout
def import_lake(ctx):
    logging.info("importing the lakes borders in postgres")
    target_file = f"{ctx.data_dir}/lake_centerline.geojson"
    download_file(ctx, target_file, ctx.water.lakelines_url, max_age=timedelta(days=30))

    pg_conn = _get_pg_conn(ctx)
    ctx.run(
        f'PGCLIENTENCODING=UTF8 ogr2ogr \
    -f Postgresql \
    -s_srs EPSG:4326 \
    -t_srs EPSG:3857 \
    PG:"{pg_conn}" \
    {ctx.data_dir}/lake_centerline.geojson \
    -overwrite \
    -nln "lake_centerline"'
    )


@task
@format_stdout
def import_border(ctx):
    logging.info("importing the borders in postgres")

    target_file = f"{ctx.data_dir}/osmborder_lines.csv"
    gz_file = f"{target_file}.gz"
    if needs_to_download(ctx, target_file, max_age=timedelta(days=30)):
        ctx.run(
            f"wget --progress=dot:giga -O {gz_file} {ctx.border.osmborder_lines_url} \
    && gzip -fd {gz_file}"
        )

    ctx.run(
        f"POSTGRES_PASSWORD={ctx.pg.password} POSTGRES_PORT={ctx.pg.port} IMPORT_DIR={ctx.data_dir} \
  POSTGRES_HOST={ctx.pg.host} POSTGRES_DB={ctx.pg.import_database} POSTGRES_USER={ctx.pg.user} \
  {ctx.imposm_config_dir}/import-osmborder/import/import_osmborder_lines.sh"
    )


# Wikimedia sites
###################
@task
@format_stdout
def import_wikimedia_stats(ctx):
    """
    import wikimedia stats (for POI ranking through Wikipedia page views)
    """
    target_file = os.path.join(ctx.data_dir, ctx.wikidata.stats.file)
    download_file(ctx, target_file, ctx.wikidata.stats.url)

    connection = _open_sql_connection(ctx, ctx.pg.import_database)
    cursor = connection.cursor()

    with gzip.open(target_file, 'rt') as istream:
        cursor.execute(f'TRUNCATE TABLE {ctx.wikidata.stats.table};')
        cursor.copy_expert(
            f'COPY {ctx.wikidata.stats.table} '
            f'FROM STDIN DELIMITER \',\' CSV HEADER;',
            istream
        )

    connection.commit()
    connection.close()


@task
@format_stdout
def import_wikidata_sitelinks(ctx):
    """
    import Wikipedia pages links for Wikidata items
    """
    target_file = os.path.join(ctx.data_dir, ctx.wikidata.sitelinks.file)
    download_file(ctx, target_file, ctx.wikidata.sitelinks.url)

    connection = _open_sql_connection(ctx, ctx.pg.import_database)
    cursor = connection.cursor()

    with gzip.open(target_file, 'rt') as istream:
        cursor.execute(f'TRUNCATE TABLE {ctx.wikidata.sitelinks.table};')
        cursor.copy_expert(
            f'COPY {ctx.wikidata.sitelinks.table} '
            f'FROM STDIN DELIMITER \',\' CSV HEADER;',
            istream
        )

    connection.commit()
    connection.close()


@task
@format_stdout
def import_wikidata_labels(ctx):
    """
    import labels from Wikidata (for some translations)
    """
    target_file = os.path.join(ctx.data_dir, ctx.wikidata.labels.file)
    download_file(ctx, target_file, ctx.wikidata.labels.url)

    with gzip.open(target_file, 'rt') as istream:
        reader = csv.DictReader(istream)
        connection = _open_sql_connection(ctx, ctx.pg.import_database)
        cursor = connection.cursor()

        cursor.executemany(
            f'''
            INSERT INTO {ctx.wikidata.labels.table} (id, labels)
            VALUES (%s, %s)
            ON CONFLICT (id) DO
                UPDATE SET labels = (wd_names.labels || EXCLUDED.labels)
            ''',
            map(
                lambda row: (
                    row['title'],
                    {'name:' + row['language']: row['value']}
                ), reader
            )
        )

        connection.commit()
        connection.close()


@task
@format_stdout
def override_wikidata_weight_functions(ctx):
    """
    update sql weight functions to make use of wikidata stats
    """
    _run_sql_script(ctx, "import-wikidata/wikidata_functions.sql")


# import pipeline
###################
@task
def run_post_sql_scripts(ctx):
    """
    load the sql file with all the functions to generate the layers
    this file has been generated using https://github.com/QwantResearch/openmaptiles
    """
    logging.info("running postsql scripts")
    _run_sql_script(ctx, "generated_base.sql")
    _run_sql_script(ctx, "generated_poi.sql")


@task
@format_stdout
def load_osm(ctx):
    if ctx.osm.url:
        get_osm_data(ctx)

    concurrent.futures.wait([
        cc_exec.submit(load_basemap, ctx),
        cc_exec.submit(load_poi, ctx)
    ])

    run_sql_script(ctx)


@task
@format_stdout
def load_additional_data(ctx):
    tasks = [
        cc_exec.submit(import_natural_earth, ctx),
        cc_exec.submit(import_water_polygon, ctx),
        cc_exec.submit(import_lake, ctx),
        cc_exec.submit(import_border, ctx),
    ]

    if ctx.wikidata.stats.enabled:
        _run_sql_script(ctx, "import-wikidata/stats_tables.sql")
        tasks += [
            cc_exec.submit(import_wikimedia_stats, ctx),
            cc_exec.submit(import_wikidata_sitelinks, ctx),
        ]

    if ctx.wikidata.labels.enabled:
        _run_sql_script(ctx, "import-wikidata/labels_tables.sql")
        tasks.append(cc_exec.submit(import_wikidata_labels, ctx))

    concurrent.futures.wait(tasks)


@task
@format_stdout
def kill_all_access_to_main_db(ctx):
    """
    close all connections to the main database
    """
    logging.info(f"killing all connections to the main database")
    _execute_sql(
        ctx,
        f"SELECT pid, pg_terminate_backend (pid) FROM pg_stat_activity WHERE datname = '{ctx.pg.database}';",
        db=ctx.pg.import_database,
    )


@task
@format_stdout
def rotate_database(ctx):
    """
    rotate the postgres database

    we first move the production database to a backup database,
    then move the newly created import database to be the new production database
    """
    if not _db_exists(ctx, ctx.pg.import_database):
        return
    kill_all_access_to_main_db(ctx)
    if _db_exists(ctx, ctx.pg.database):
        logging.info(
            f"rotating database, moving {ctx.pg.database} -> {ctx.pg.backup_database}"
        )
        _execute_sql(
            ctx,
            f"ALTER DATABASE {ctx.pg.database} RENAME TO {ctx.pg.backup_database};",
            db=ctx.pg.import_database,
        )
    logging.info(
        f"rotating database, moving {ctx.pg.import_database} -> {ctx.pg.database}"
    )
    _execute_sql(
        ctx,
        f"ALTER DATABASE {ctx.pg.import_database} RENAME TO {ctx.pg.database};",
        db=ctx.pg.backup_database,
    )


# tiles generation
####################
def create_tiles_jobs(
    ctx,
    tiles_layer,
    from_zoom,
    before_zoom,
    z,
    x=None,
    y=None,
    check_previous_layer=False,
    check_base_layer_level=None,
    expired_tiles_filepath=None,
):
    params = {
        "fromZoom": from_zoom,
        "beforeZoom": before_zoom,
        "keepJob": "true",
        "parts": ctx.tiles.parts,
        "deleteEmpty": "true",
        "zoom": z,
    }
    if tiles_layer == TilesLayer.BASEMAP:
        params.update(
            {
                "generatorId": ctx.tiles.base_sources.generator,
                "storageId": ctx.tiles.base_sources.storage,
            }
        )
    elif tiles_layer == TilesLayer.POI:
        params.update(
            {
                "generatorId": ctx.tiles.poi_sources.generator,
                "storageId": ctx.tiles.poi_sources.storage,
            }
        )
    else:
        raise Exception("invalid tiles_layer")

    if x:
        params["x"] = x
    if y:
        params["y"] = y
    if check_previous_layer:
        # this tells tilerator not to generate a tile if there is not tile at the previous zoom
        # this saves a lots of time since we won't generate tiles on oceans
        params["checkZoom"] = -1
    if check_base_layer_level:
        # this tells tilerator not to generate a tile if there is not tile at the previous zoom
        # this saves a lots of time since we won't generate tiles on oceans
        params["checkZoom"] = check_base_layer_level
        params["sourceId"] = ctx.tiles.base_sources.storage
    if expired_tiles_filepath:
        params["filepath"] = expired_tiles_filepath

    url = f"{ctx.tiles.tilerator_url}/add"

    logging.info(f"posting a tilerator job on {url} with params: {params}")
    res = requests.post(url, params=params)

    res.raise_for_status()
    json_res = res.json()
    if "error" in json_res:
        # tilerator can return status 200 but an error inside the response, so we need to check it
        raise Exception(f"impossible to run tilerator job, error: {json_res['error']}")
    logging.info(f"jobs: {res.json()}")


@task
@format_stdout
def generate_tiles(ctx):
    """
    Start the tiles generation

    the Tiles generation process is handle in the background by tilerator
    """
    if ctx.tiles.planet:
        logging.info("generating tiles for the planet")
        # for the planet we tweak the tiles generation a bit to speed it up
        # we first generate all the tiles for the first levels
        create_tiles_jobs(
            ctx,
            tiles_layer=TilesLayer.BASEMAP,
            z=0,
            from_zoom=0,
            before_zoom=10
        )
        # from the zoom 10 we generate only the tiles if there is a parent tiles
        # since tilerator does not generate tiles if the parent tile is composed only of 1 element
        # it speed up greatly the tiles generation by not even trying to generate tiles for oceans (and desert)
        create_tiles_jobs(
            ctx,
            tiles_layer=TilesLayer.BASEMAP,
            z=10,
            from_zoom=10,
            before_zoom=15,
            check_previous_layer=True,
        )
        # for the poi, we generate only tiles if we have a base tile on the level 13
        # Note: we check the level 13 and not 14 because the tilegeneration process is in the background
        # and we might not have finished all basemap 14th zoom level tiles when starting the poi generation
        # it's a bit of a trick but works fine
        create_tiles_jobs(
            ctx,
            tiles_layer=TilesLayer.POI,
            z=14,
            from_zoom=14,
            before_zoom=15,
            check_base_layer_level=13,
        )
    elif ctx.tiles.x and ctx.tiles.y and ctx.tiles.z:
        logging.info(
            f"generating tiles for {ctx.tiles.x} / {ctx.tiles.y}, z = {ctx.tiles.z}"
        )
        logging.warn("/!\\================================/!\\")
        logging.warn("Please not that this way of giving position is DEPRECATED! use `coords` instead");
        logging.warn("/!\\================================/!\\")
        create_tiles_jobs(
            ctx,
            tiles_layer=TilesLayer.BASEMAP,
            x=ctx.tiles.x,
            y=ctx.tiles.y,
            z=ctx.tiles.z,
            from_zoom=ctx.tiles.base_from_zoom,
            before_zoom=ctx.tiles.base_before_zoom,
        )
        create_tiles_jobs(
            ctx,
            tiles_layer=TilesLayer.POI,
            x=ctx.tiles.x,
            y=ctx.tiles.y,
            z=ctx.tiles.z,
            from_zoom=ctx.tiles.poi_from_zoom,
            before_zoom=ctx.tiles.poi_before_zoom,
        )
    elif ctx.tiles.coords:
        try:
            data = json.loads(ctx.tiles.coords)
        except Exception as err:
            logging.error(f"invalid tiles data received, expected JSON: {err}")
            sys.exit(1)
        for entry in data:
            if len(entry) != 3:
                logging.warn(f"Expected entry [longitude, latitude, zoom], got {len(entry)} elements")
                continue
            logging.info(
                f"generating tiles for {entry[0]} / {entry[1]}, z = {entry[2]}"
            )
            create_tiles_jobs(
                ctx,
                tiles_layer=TilesLayer.BASEMAP,
                x=entry[0],
                y=entry[1],
                z=entry[2],
                from_zoom=ctx.tiles.base_from_zoom,
                before_zoom=ctx.tiles.base_before_zoom,
            )
            create_tiles_jobs(
                ctx,
                tiles_layer=TilesLayer.POI,
                x=entry[0],
                y=entry[1],
                z=entry[2],
                from_zoom=ctx.tiles.poi_from_zoom,
                before_zoom=ctx.tiles.poi_before_zoom,
            )
    else:
        logging.info("no parameter given for tile generation, skipping it")


@task
@format_stdout
def generate_expired_tiles(ctx, tiles_layer, from_zoom, before_zoom, expired_tiles):
    logging.info("generating expired tiles from %s", expired_tiles)
    create_tiles_jobs(
        ctx,
        tiles_layer=tiles_layer,
        z=from_zoom,
        from_zoom=from_zoom,
        before_zoom=before_zoom,
        expired_tiles_filepath=expired_tiles,
    )


# osm update
##############

def read_current_state(ctx):
    with open(f'{ctx.update_tiles_dir}/state.txt') as state_file:
        for line in state_file:
            if line.startswith('timestamp='):
                raw_timestamp = line.replace('timestamp=', '').strip()
                # for compatibility with osm replication files
                raw_timestamp = raw_timestamp.replace('\:', ':')
                if raw_timestamp:
                    return raw_timestamp
    raise Exception("Cannot find timestamp in osm state file")


def write_new_state(ctx, new_timestamp):
    with open(f'{ctx.update_tiles_dir}/state.txt', 'w') as state_file:
        state_file.write(f'timestamp={new_timestamp}\n')


def read_osm_timestamp(ctx, osm_file_path):
    return ctx.run(f'osmconvert {osm_file_path} --out-timestamp').stdout


@task
@format_stdout
def init_osm_update(ctx):
    """
    Init osmosis folder with configuration files and
    latest state.txt file before .pbf timestamp
    """
    logging.info("initializing osm update from osm file timestamp:")
    ctx.run(f'mkdir -p {ctx.update_tiles_dir}')
    raw_osm_datetime = read_osm_timestamp(ctx, ctx.osm.file)
    write_new_state(ctx, raw_osm_datetime)


def check_if_folder_has_folders(folder, folders):
    for f in os.listdir(folder):
        full = os.path.join(folder, f)
        if os.path.isdir(full) and f in folders:
            folders.remove(f)
    if len(folders) > 0:
        for f in folders:
            logging.error("'{}' should be present in {}".format(f, folder))
        return False
    return True


def check_generated_cache(folder):
    if not os.path.isdir(folder):
        logging.error(f"{folder} should be a directory")
        return False
    errors = 0
    checks = 0
    for f in os.listdir(folder):
        full = os.path.join(folder, f)
        if os.path.isdir(full):
            checks += 1
            if not check_if_folder_has_folders(full, [TilesLayer.POI, TilesLayer.BASEMAP]):
                errors += 1
    if checks == 0:
        logging.error(f"{folder} should not be empty")
    return checks > 0 and errors == 0


def get_import_lock_path(ctx):
    return f'{ctx.update_tiles_dir}/osm_update.lock'


@task
@format_stdout
def run_osm_update(ctx):
    update_env = {
        "PG_CONNECTION_STRING": f"postgis://{ctx.pg.user}:{ctx.pg.password}@{ctx.pg.host}:{ctx.pg.port}/{ctx.pg.database}",
        "OSM_UPDATE_WORKING_DIR": ctx.update_tiles_dir,
        "IMPOSM_DATA_DIR": ctx.generated_files_dir,
    }

    if not check_generated_cache(ctx.generated_files_dir):
        sys.exit(1)

    change_file_path = f"{ctx.update_tiles_dir}/changes.osc.gz"
    lock_path = get_import_lock_path(ctx)
    with FileLock(lock_path) as lock:
        current_osm_timestamp = read_current_state(ctx)
        try:
            osmupdate_opts = _get_osmupdate_options(ctx)
            ctx.run(
                f'osmupdate {osmupdate_opts} {current_osm_timestamp} {change_file_path}'
            )
        except Failure as exc:
            if exc.result.return_code == 21:
                logging.info('OSM state is up to date, no change to apply')
                return
            raise

        new_osm_timestamp = read_osm_timestamp(ctx, change_file_path)
        ctx.run(
            f"{os.path.join(os.getcwd(), 'osm_update.sh')} --config {ctx.imposm_config_dir} --input {change_file_path}",
            env=update_env,
        )
        write_new_state(ctx, new_osm_timestamp)
        os.remove(change_file_path)


# default task
##############
@task(default=True)
@format_stdout
def load_all(ctx):
    """
    default task called if `invoke` is run without args

    This is the main tasks that import all the datas into postgres and start the tiles generation process
    """
    if not ctx.osm.file and not ctx.osm.url:
        raise Exception("you should provide a osm.file variable or osm.url variable")

    lock_path = get_import_lock_path(ctx)
    with FileLock(lock_path) as lock:
        prepare_db(ctx)
        load_osm(ctx)
        load_additional_data(ctx)
        run_post_sql_scripts(ctx)

        if ctx.wikidata.stats.enabled:
            override_wikidata_weight_functions(ctx)

        rotate_database(ctx)
        generate_tiles(ctx)
        init_osm_update(ctx)
