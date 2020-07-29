#!/usr/bin/env python3

import argparse
import subprocess
import re
import sys
import os
from itertools import chain

# Commands that will require a load db
LOAD_DB_COMMANDS = ["load-db", "load-db-france", "tileview"]

# Commands that will require a build
BUILD_COMMANDS = ["build", "kartotherian", "test"] + LOAD_DB_COMMANDS


def exec_command(command, debug=False):
    if debug:
        print("===>", " ".join(command), file=sys.stderr)

    p = subprocess.Popen(command)
    p.wait()
    return p.poll()


def docker_exec(docker_cmd, namespace, debug=False):
    init_submodule_if_not(debug)
    res_code = exec_command(
        ["docker-compose", "-p", namespace, "-f", "docker-compose.yml", "-f", "local-compose.yml"]
        + docker_cmd,
        debug,
    )

    if res_code != 0:
        print("Docker command failed")
        sys.exit(res_code)


def docker_run(params, namespace, debug=False, env={}):
    env_params = list(chain.from_iterable(["-e", f"{key}={val}"] for key, val in env.items()))
    command = ["run", "--rm"] + env_params + params
    docker_exec(command, namespace, debug)


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


def init_submodule_if_not(debug=False):
    submodules = get_submodules()

    for sub in submodules:
        if len(os.listdir(sub)) == 0:
            if exec_command(["git", "submodule", "update", "--init", sub], debug) != 0:
                print(f'Failed to update submodule "{sub}"')


def build_argparser():
    parser = argparse.ArgumentParser(
        prog="kartotherian_docker",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="""
            Generally, it runs in this order: build > load-db(-france) > kartotherian (> logs)
            To update, it runs in this order: build > load-db(-france) > update-tiles (> logs)
            To debug, it runs in this order:  build > load-db(-france) > tileview (> logs)
        """,
    )

    parser.add_argument("--debug", action="store_true", help="show more information on the run")
    parser.add_argument(
        "--namespace",
        default="kartotherian_docker",
        help="set the --project option of docker-compose, allowing to change name prefix",
    )

    subparsers = parser.add_subparsers(dest="command")
    subcommands = {
        cmd: subparsers.add_parser(cmd, help=cmd_help)
        for cmd, cmd_help in [
            ("build", "build basics"),
            ("kartotherian", "launch (and build) kartotherian"),
            ("load-db", "load data from the given `--osm-file` (luxembourg by default)"),
            ("load-db-france", "load data (tiles too) for the french country"),
            ("tileview", "run a map server which allows to get detailed tiles information"),
            ("update-tiles", "update the tiles data"),
            ("clean", "stop and remove running docker instances"),
            ("logs", "show docker logs (can be filtered with `--filter` option)"),
            ("test", "run tests on generated tiles and db"),
        ]
    }

    # DB loading specific parameters

    for cmd in LOAD_DB_COMMANDS:
        def_file = "europe/luxembourg" if cmd != "load-db-france" else "europe/france"
        def_coords = (
            "[[66, 43, 7]]"
            if cmd != "load-db-france"
            else "[[15, 10, 5], [16, 10, 5], [15, 11, 5], [16, 11, 5]]"
        )

        subcommands[cmd].add_argument(
            "--osm-file",
            default=f"https://download.geofabrik.de/{def_file}-latest.osm.pbf",
            help="file or URL to be used for pbf file, luxembourg by default",
        )

        subcommands[cmd].add_argument(
            "--tiles-coords",
            default=def_coords,
            help="""
                Needs to be an array of arrays (each of len 3).
                You can find coords by using http://tools.geofabrik.de/calc/?grid=1
            """,
        )

        subcommands[cmd].add_argument(
            "--env",
            "-e",
            action="append",
            default=[],
            help="Set environement variable during docker run.",
        )

    # `logs` specific parameters

    subcommands["logs"].add_argument(
        "--filter", action="append", default=[], help="container to show"
    )

    return parser


def main():
    parser = build_argparser()
    args = parser.parse_args()

    if args.command in BUILD_COMMANDS:
        docker_exec(["up", "--build", "-d"], args.namespace, args.debug)

    if args.command in LOAD_DB_COMMANDS:
        is_url = re.match("https?://.*", args.osm_file)
        file_key = "INVOKE_OSM_URL" if is_url else "INVOKE_OSM_FILE"

        env = {arg.split("=")[0]: arg.split("=")[1] for arg in args.env}
        env["INVOKE_TILES_COORDS"] = args.tiles_coords
        env[file_key] = args.osm_file

        docker_run(["load_db"], args.namespace, args.debug, env=env)

    if args.command == "tileview":
        docker_exec(["up", "-d", "tileview"], args.namespace, args.debug)

    if args.command == "update-tiles":
        docker_run(["load_db", "run-osm-update"], args.namespace, args.debug)

    if args.command == "clean":
        docker_exec(["down", "-v"], args.namespace, args.debug)

    if args.command == "logs":
        docker_exec(["logs"], args.namespace, args.debug)

    if args.command == "test":
        docker_run(["load_db", "test"], args.namespace, args.debug)


if __name__ == "__main__":
    main()
