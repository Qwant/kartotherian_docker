import json
import os
from os import path
from datetime import datetime

EXPIRETILES_ZOOM = 14
UPDATE_TILES_FROM_ZOOM = 11
UPDATE_TILES_BEFORE_ZOOM = 15


def get_time_now():
    return datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")


def log(msg):
    print(f"[{get_time_now()}] {os.getpid()} :INFO: {msg}")


def log_error(msg):
    print(f"[{get_time_now()}] {os.getpid()} :ERROR: {msg}")


def format_file_size(size):
    prefixes = ["", "K", "M", "G", "T"]
    i_prefix = 0

    while i_prefix + 1 < len(prefixes) and size >= 1000:
        i_prefix += 1
        size /= 1024

    return f"{size:.2f}{prefixes[i_prefix]}B"


def load_json(file_path):
    try:
        with open(file_path) as json_file:
            return json.load(json_file)
    except Exception as err:
        log_error(f"Couldn't parse JSON from `{file_path}`: {err}")
        raise


def run_imposm_update(ctx, tileset, change_file, pg_connection):
    imposm_folder_name = tileset.name
    mapping_path = path.join(ctx.imposm_config_dir, tileset.mapping_filename)

    log("apply changes on OSM database")
    log(f"{change_file} file size is " + format_file_size(os.path.getsize(change_file)))

    try:
        ctx.run(
            f'imposm3 diff -quiet \
                -connection {pg_connection} \
                -mapping {mapping_path} \
                -cachedir {path.join(ctx.generated_files_dir, "cache", imposm_folder_name)} \
                -diffdir {path.join(ctx.generated_files_dir, "diff", imposm_folder_name)} \
                -expiretiles-dir {path.join(ctx.update_tiles_dir,"expiretiles", imposm_folder_name)} \
                -expiretiles-zoom {EXPIRETILES_ZOOM} \
                {change_file}'
        )
    except Exception:
        log_error("imposm3 failed")
        raise


def get_all_files(folder, from_ts):
    entries = []
    for entry in os.listdir(folder):
        full_path = path.join(folder, entry)
        if path.isdir(full_path):
            entries.extend(get_all_files(full_path, from_ts))
        elif path.isfile(full_path) and path.getmtime(full_path) > from_ts:
            entries.append(full_path)
    return entries


def create_tiles_jobs(ctx, tileset_config, start_ts):
    from .tasks import generate_expired_tiles

    log(f"Creating tiles jobs for `{tileset_config.name}`")

    # Get all tiles updated since start timestamp
    entries = "|".join(
        get_all_files(
            path.join(ctx.update_tiles_dir, "expiretiles", tileset_config.name), start_ts,
        )
    )

    if entries == "":
        log("no expired tiles")
        return

    log(f"file with tile to regenerate = {entries}")

    generate_expired_tiles(
        ctx,
        tileset_name=tileset_config.name,
        from_zoom=UPDATE_TILES_FROM_ZOOM,
        before_zoom=UPDATE_TILES_BEFORE_ZOOM,
        expired_tiles=entries,
    )


def check_settings(settings, keys):
    errors = 0
    for key in keys:
        if settings.get(key) is None:
            log_error(f"Missing `{key}` setting")
            errors += 1
    return errors == 0


def osm_update(ctx, pg_connection, change_file):
    start_timestamp = int(datetime.now().timestamp())

    log("new osm_update process started")
    log(f"working into directory: {ctx.update_tiles_dir}")

    if not path.isfile(change_file):
        raise Exception(f"Change file `{change_file}` was not found.")

    # Update db and tiles, only if changes file is not empty
    if os.path.getsize(change_file) != 0:
        # Imposm update for both tiles sources
        run_imposm_update(
            ctx, ctx.tiles.tilesets.basemap, change_file=change_file, pg_connection=pg_connection
        )
        run_imposm_update(
            ctx, ctx.tiles.tilesets.poi, change_file=change_file, pg_connection=pg_connection
        )

        # We make the import here to prevent a circular dependency if put at the top.
        from .tasks import reindex_poi_geometries

        # Reindex geometries to avoid index bloat
        reindex_poi_geometries(ctx)

        # Create tiles jobs for both tiles sources
        create_tiles_jobs(ctx, ctx.tiles.tilesets.basemap, start_ts=start_timestamp)
        create_tiles_jobs(ctx, ctx.tiles.tilesets.poi, start_ts=start_timestamp)

    log("============")
    log(f"current location: {os.getcwd()}")
    log("============")
    elapsed = int(datetime.now().timestamp()) - start_timestamp
    hh, mm, ss = elapsed // 3600, elapsed % 3600 // 60, elapsed % 60
    log(f"osm_update duration: {hh}h{mm:02}m{ss:02}s")
    log("osm_update successfully terminated!")

    return True
