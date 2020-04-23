#!/usr/bin/env python3

import json
import os
from os import path
import subprocess
from datetime import datetime


DESCRIPTION = "OpenStreetMap database update script"
VERSION = "0.3/20191112"


def exec_command(command):
    proc = subprocess.Popen(command)
    proc.wait()
    return proc.poll()


def get_time_now():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(msg):
    print("[{}] {} :INFO: {}".format(get_time_now(), os.getpid(), msg))


def log_error(msg):
    print("[{}] {} :ERROR: {}".format(get_time_now(), os.getpid(), msg))


def format_file_size(size):
    if size > 1000000000:
        return '{}GB'.format(size / 1000000000)
    elif size > 1000000:
        return '{}MB'.format(size / 1000000)
    elif size > 1000:
        return '{}KB'.format(size / 1000)
    return '{}B'.format(size)


def run_imposm_update(settings, entry):
    imposm_config_file = path.join(settings["imposm_config_dir"], entry)
    json_data = json.load(imposm_config_file)
    imposm_folder_name = json_data["tiles_layer_name"]
    mapping_path = path.join(settings["imposm_config_dir"], json_data["mapping_filename"])

    log("apply changes on OSM database")
    log("{} file size is {}".format(
        settings["change_file"],
        format_file_size(os.path.getsize(settings["change_file"]))))

    if exec_command(
        [
            "imposm3", "diff", "-quiet",
            "-config", imposm_config_file,
            "-connection", settings["pg_connection"],
            "-mapping", mapping_path,
            "-cachedir", path.join(settings["imposm_data_dir"], "cache", imposm_folder_name),
            "-diffdir", path.join(settings["imposm_data_dir"], "diff", imposm_folder_name),
            "-expiretiles-dir", path.join(
                settings["osm_update_working_dir"],
                "expiretiles",
                imposm_folder_name),
            settings["change_file"]
        ]
    ) != 0:
        log_error("imposm3 failed")
        return False
    return True


def get_all_files(settings, folder):
    entries = []
    for entry in os.listdir(path):
        full_path = path.join(folder, entry)
        if path.isdir(full_path):
            entries.extend(get_all_files(settings, full_path))
        elif path.isfile(full_path) and path.getmtime(full_path) > settings["start"]:
            entries.append(full_path)
    return entries


def create_tiles_jobs(settings, arg):
    imposm_config_file = path.join(settings["imposm_config_dir"], arg)
    json_data = json.load(imposm_config_file)

    log("Creating tiles jobs for `{}`".format(imposm_config_file))

    # Get all tiles updated since `settings["start"]`
    entries = "|".join(
        get_all_files(
            settings,
            path.join(
                settings["osm_update_working_dir"],
                "expiretiles",
                json_data["tiles_layer_name"])))

    if entries == "":
        log("no expired tiles")
        return True

    log("file with tile to regenerate = {}".format(entries))

    args = ["invoke"]
    if settings["invoke_option"] != "":
        args.append(settings["invoke_option"])
    args.extend([
        "generate-expired-tiles",
        "--tiles-layer", json_data["tiles_layer_name"],
        "--from-zoom", settings["from_zoom"],
        "--before-zoom", settings["before_zoom"],
        "--expired-tiles", entries
    ])
    if exec_command(args) != 0:
        log_error("Failed to run command `{}`".format(args))
        return False
    return True


def check_settings(settings, keys):
    errors = 0
    for key in keys:
        if settings.get(key) is None:
            log_error("Missing `{}` setting".format(key))
    return errors == 0


def run_osm_update(pg_connection, osm_update_working_dir, imposm_data_dir, imposm_config_dir, change_file):
    settings = {
        "pg_connection": pg_connection,
        "osm_update_working_dir": osm_update_working_dir,
        "imposm_data_dir": imposm_data_dir,
        "imposm_config_dir": imposm_config_dir,
        "change_file": change_file,
    }

    invoke_config_file = os.environ.get("INVOKE_CONFIG_FILE", "")
    # Settings
    settings["start"] = int(datetime.now().timestamp())
    settings["exec_time"] = get_time_now()
    settings["invoke_option"] = ""
    if settings["invoke_option"] != "":
        settings["invoke_option"] = "-f {}".format(invoke_config_file)
    # imposm
    if settings.get("imposm_config_dir", "") == "":
        # default value, can be set with the --config option
        settings["imposm_config_dir"] = "/etc/imposm"
    # base tiles
    settings["base_imposm_config_filename"] = "config_base.json"
    # poi tiles
    settings["poi_imposm_config_filename"] = "config_poi.json"
    # tilerator
    settings["from_zoom"] = 11
    settings["before_zoom"] = 15 # exclusive

    if not check_settings(settings, ["osm_update_working_dir", "imposm_data_dir"]):
        return False

    log("new osm_update process started")
    log("working into directory: {}".format(settings["osm_update_working_dir"]))

    if settings.get("change_file") is None:
        log_error("A change file is required as input.")
        return False
    if not path.isfile(settings["change_file"]):
        log_error("Change file `{}` was not found.".format(settings["change_file"]))
        return False

    # Update db and tiles, only if changes file is not empty
    if os.path.getsize(settings["change_file"]) != 0:
        # Imposm update for both tiles sources
        if (not run_imposm_update(settings, settings["base_imposm_config_filename"])
                or not run_imposm_update(settings, settings["poi_imposm_config_filename"])):
            return False

        # Reindex geometries to avoid index bloat
        args = ["invoke", settings["invoke_option"], "reindex-poi-geometries"]
        if exec_command(args) != 0:
            log_error("Failed to run `{}`".format(args))
            return False

        # Create tiles jobs for both tiles sources
        if (not create_tiles_jobs(settings, settings["base_imposm_config_filename"])
                or not create_tiles_jobs(settings, settings["poi_imposm_config_filename"])):
            return False

    log("============")
    log("current location: {}".format(os.getcwd()))
    log("============")
    elapsed = settings["start"] - int(datetime.now().timestamp())
    log("osm_update duration: {}h{:02}m{:02}s".format(
        elapsed / 3600,
        elapsed % 3600 / 60,
        elapsed % 60))
    log("osm_update successfully terminated!")

    return True
