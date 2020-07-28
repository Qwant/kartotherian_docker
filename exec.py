#!/usr/bin/env python3

import subprocess
import sys
import os
import json


COMMANDS = [
    "build",
    "load-db",
    "load-db-france",
    "update-tiles",
    "clean",
    "logs",
    "kartotherian",
    "tileview",
]


def exec_command(command, options):
    if options.get("debug") is True:
        print("==>", " ".join(command))
    p = subprocess.Popen(command)
    p.wait()
    return p.poll()


def get_submodules():
    dirs = []
    try:
        with open(".gitmodules", "r") as f:
            for line in f:
                line = line.strip()
                if not line.startswith("path = "):
                    continue
                dirs.append(line.split("path = ")[1])
    except Exception as err:
        print(f"error happened when trying to get submodules: {err}")
    return dirs


def init_submodule_if_not(options):
    submodules = get_submodules()
    for sub in submodules:
        if len(os.listdir(sub)) == 0:
            if exec_command(["git", "submodule", "update", "--init", sub], options) != 0:
                print(f'Failed to update submodule "{sub}"')


def run_kartotherian(options):
    init_submodule_if_not(options)
    print("> running kartotherian command")
    return exec_command(
        [
            "docker-compose",
            "-p",
            options["namespace"],
            "-f",
            "docker-compose.yml",
            "-f",
            "local-compose.yml",
            "up",
            "--build",
            "-d",
        ],
        options,
    )


def run_build(options):
    init_submodule_if_not(options)
    print("> running build command")
    return exec_command(
        [
            "docker-compose",
            "-p",
            options["namespace"],
            "-f",
            "docker-compose.yml",
            "-f",
            "local-compose.yml",
            "up",
            "--build",
            "-d",
        ],
        options,
    )


def run_load_db(options):
    ret = run_build(options)
    if ret != 0:
        return ret
    print("> running load-db command")
    if options["osm-file"].startswith("https://") or options["osm-file"].startswith("http://"):
        flag = f"INVOKE_OSM_URL={options['osm-file']}"
    else:
        flag = f"INVOKE_OSM_FILE={options['osm-file']}"
    command = [
        "docker-compose",
        "-p",
        options["namespace"],
        "-f",
        "docker-compose.yml",
        "-f",
        "local-compose.yml",
        "run",
        "--rm",
        "-e",
        flag,
        "-e",
        f"INVOKE_TILES_COORDS={options['tiles-coords']}",
        "load_db",
    ]
    return exec_command(command, options)


def run_load_db_france(options):
    options["osm-file"] = "https://download.geofabrik.de/europe/france-latest.osm.pbf"
    # got tiles from http://tools.geofabrik.de/calc/?grid=1
    options["tiles-coords"] = "[[15, 10, 5], [16, 10, 5], [15, 11, 5], [16, 11, 5]]"
    run_load_db(options)


def run_update_tiles(options):
    # needs to be run after load-db, adding a check for it would be nice.
    print("> running update-tiles command")
    return exec_command(
        [
            "docker-compose",
            "-p",
            options["namespace"],
            "-f",
            "docker-compose.yml",
            "-f",
            "local-compose.yml",
            "run",
            "--rm",
            "load_db",
            "run-osm-update",
        ],
        options,
    )


def run_clean(options):
    print("> running clean command")
    return exec_command(
        [
            "docker-compose",
            "-p",
            options["namespace"],
            "-f",
            "docker-compose.yml",
            "-f",
            "local-compose.yml",
            "down",
            "-v",
        ],
        options,
    )


def run_logs(options):
    print("> running logs command")
    command = [
        "docker-compose",
        "-p",
        options["namespace"],
        "-f",
        "docker-compose.yml",
        "-f",
        "local-compose.yml",
        "logs",
    ]
    for f in options["filter"]:
        command.append(f)
    return exec_command(command, options)


def run_tileview(options):
    print("> running tileview command")
    ret = run_load_db(options)
    if ret != 0:
        return ret
    return exec_command(
        [
            "docker-compose",
            "-p",
            options["namespace"],
            "-f",
            "docker-compose.yml",
            "-f",
            "local-compose.yml",
            "up",
            "-d",
            "tileview",
        ],
        options,
    )


def run_help():
    print("== kartotherian_docker options ==")
    print("")
    print("Generally, it runs in this order: build > load-db(-france) > kartotherian (> logs)")
    print("To update, it runs in this order: build > load-db(-france) > update-tiles (> logs)")
    print("To debug, it runs in this order:  build > load-db(-france) > tileview (> logs)")
    print("")
    print("  build         : build basics")
    print("  kartotherian  : launch (and build) kartotherian")
    print("  load-db       : load data from the given `--osm-file` (luxembourg by default)")
    print("  load-db-france: load data (tiles too) for the french country")
    print("  tileview      : run a map server which allows to get detailed tiles information")
    print("  update-tiles  : update the tiles data")
    print("  clean         : stop and remove running docker instances")
    print("  logs          : show docker logs (can be filtered with `--filter` option)")
    print("  --debug       : show more information on the run")
    print("  --filter      : container to show on `logs` command")
    print(
        "  --osm-file    : file or URL to be used for pbf file in `load-db`, luxembourg by default"
    )
    print(
        "  --tiles-coords: needs to be an array of arrays (each of len 3). Defaults to [[66, 43, 7]]."
    )
    print("                  You can find coords by using http://tools.geofabrik.de/calc/?grid=1")
    print("                  Used in load-db(-france) command.")
    print(
        "  --namespace   : set the --project option of docker-compose, allowing to change name prefix "
    )
    print("                  of all used docker images")
    print("  -h | --help   : show this help")
    sys.exit(0)


def parse_args(args):
    if len(args) == 0:
        run_help()
        sys.exit(0)
    available_options = ["--no-dependency-run", "--debug"]
    available_options.extend(COMMANDS)
    enabled_options = {
        "osm-file": "https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf",
        "filter": [],
        "tiles-coords": "[[66, 43, 7]]",
        "namespace": "kartotherian_docker",
    }
    i = 0
    while i < len(args):
        if args[i] in available_options:
            if args[i].startswith("--"):
                args[i] = args[i][2:]
            enabled_options[args[i]] = True
        elif args[i] == "--filter":
            if i + 1 >= len(args):
                print("`--filter` option expects an argument!")
                sys.exit(1)
            i += 1
            enabled_options[args[i - 1][2:]].append(args[i])
        elif args[i] == "--osm-file":
            if i + 1 >= len(args):
                print("`--osm-file` option expects an argument!")
                sys.exit(1)
            i += 1
            enabled_options[args[i - 1][2:]] = args[i]
        elif args[i] == "--tiles-coords":
            if i + 1 >= len(args):
                print(f"`{args[i]}` option expects an argument!")
                sys.exit(1)
            i += 1
            try:
                d = json.loads(args[i])
                if not isinstance(d, list):
                    print(f"`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]")
                    sys.exit(1)
                for x in d:
                    if not isinstance(x, list) or len(x) != 3:
                        print(
                            f"`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]"
                        )
                        sys.exit(1)
            except Exception as e:
                print(f"`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]")
                sys.exit(1)
            enabled_options[args[i - 1][2:]] = args[i]
        elif args[i] == "--namespace":
            if i + 1 >= len(args):
                print("`--namespace` option expects an argument!")
                sys.exit(1)
            i += 1
            enabled_options[args[i - 1][2:]] = args[i]
        elif args[i] == "-h" or args[i] == "--help":
            run_help()
            sys.exit(0)
        else:
            print(
                f"Unknown option `{args[i]}`, run with with `-h` or `--help` to see the list of commands"
            )
            sys.exit(1)
        i += 1
    return enabled_options


def main():
    definitions = globals()
    options = parse_args(sys.argv[1:])
    for key in options:
        if key in COMMANDS and options[key] is True:
            func_name = "run_" + key.replace("-", "_")
            ret = definitions[func_name](options)
            if ret != 0:
                print(f"{key} command failed")
                sys.exit(ret)


if __name__ == "__main__":
    main()
