#!/usr/bin/env python3

import subprocess
import time
import sys
import os
import json


COMMANDS = ["build", "load-db", "load-db-france", "update-tiles", "clean", "logs", "kartotherian"]


def exec_command(command, options):
    if options.get('debug') is True:
        print('==> {}'.format(' '.join(command)))
    p = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    while True:
        output = p.stdout.read1(100)
        if len(output) == 0:
            rc = p.poll()
            if rc is not None:
                return rc
        if len(output) > 0:
            sys.stdout.buffer.write(output)
            sys.stdout.buffer.flush()


def get_submodules():
    dirs = []
    try:
        with open('.gitmodules', 'r') as f:
            for line in f:
                line = line.strip()
                if not line.startswith('path = '):
                    continue
                dirs.append(line.split('path = ')[1])
    except Exception as err:
        print(f'error happened when trying to get submodules: {err}')
    return dirs


def init_submodule_if_not(options):
    submodules = get_submodules()
    for sub in submodules:
        if len(os.listdir(sub)) == 0:
            if exec_command(['git', 'submodule', 'update', '--init', sub], options) != 0:
                print(f'Failed to update submodule "{sub}"')


def run_kartotherian(options):
    init_submodule_if_not(options)
    print('> running kartotherian command')
    return exec_command([
        'docker-compose',
        'up',
        '--build',
        '-d',
    ], options)


def run_build(options):
    init_submodule_if_not(options)
    print('> running build command')
    return exec_command([
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'up',
        '--build',
        '-d',
    ], options)


def run_load_db(options):
    ret = run_build(options)
    if ret != 0:
        return ret
    time.sleep(10) # add into the script a function to check if postgresql is up
    print('> running load-db command')
    if options['osm-file'].startswith('https://') or options['osm-file'].startswith('http://'):
        flag = 'INVOKE_OSM_URL={}'.format(options['osm-file'])
    else:
        flag = 'INVOKE_OSM_FILE={}'.format(options['osm-file'])
    command = [
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'run', '--rm',
        '-e', flag,
        '-e', 'INVOKE_TILES_COORDS={}'.format(options['tiles-coords']),
    ]
    command.append('load_db')
    return exec_command(command, options)


def run_load_db_france(options):
    options['osm-file'] = "https://download.geofabrik.de/europe/france-latest.osm.pbf"
    # got tiles from http://tools.geofabrik.de/calc/?grid=1
    options['tiles-coords'] = '[[15, 10, 5], [16, 10, 5], [15, 11, 5], [16, 11, 5]]'
    run_load_db(options)


def run_update_tiles(options):
    # needs to be run after load-db, adding a check for it would be nice.
    print('> running update-tiles command')
    return exec_command([
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'run', '--rm',
        'load_db',
        'run-osm-update',
    ], options)


def run_clean(options):
    print('> running clean command')
    return exec_command([
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'down',
        '-v',
    ], options)


def run_logs(options):
    print('> running logs command')
    command = [
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'logs',
    ]
    for f in options['filter']:
        command.append(f)
    return exec_command(command, options)


def run_help():
    print('== katotherian_docker options ==')
    print('  build         : build basics')
    print('  kartotherian  : launch (and build) kartotherian')
    print('  load-db       : load data from the given `--osm-file-url` (luxembourg by default)')
    print('  load-db-france: load data (tiles too) for the french country')
    print('  update-tiles  : update the tiles data')
    print('  clean         : stop and remove running docker instances')
    print('  logs          : show docker logs (can be filtered with `--filter` option)')
    print('  --debug       : show more information on the run')
    print('  --filter      : container to show on `logs` command')
    print('  --osm-file    : file or URL to be used for pbf file in `load-db`, luxembourg by default')
    print('  --tiles-coords: needs to be an array of arrays (each of len 3). Defaults to [[66, 43, 7]]')
    print('  -h | --help   : show this help')
    sys.exit(0)


def parse_args(args):
    available_options = ['--no-dependency-run', '--debug']
    available_options.extend(COMMANDS)
    enabled_options = {
        'osm-file': 'https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf',
        'filter': [],
        'tiles-coords': '[[66, 43, 7]]',
    }
    i = 0
    while i < len(args):
        if args[i] in available_options:
            if args[i].startswith('--'):
                args[i] = args[i][2:]
            enabled_options[args[i]] = True
        elif args[i] == '--filter':
            if i + 1 >= len(args):
                print('`--filter` option expects an argument!')
                sys.exit(1)
            i += 1
            enabled_options[args[i - 1][2:]].append(args[i])
        elif args[i] == '--osm-file':
            if i + 1 >= len(args):
                print('`--osm-file` option expects an argument!')
                sys.exit(1)
            i += 1
            enabled_options[args[i - 1][2:]] = args[i]
        elif args[i] == '--tiles-coords':
            if i + 1 >= len(args):
                print('`{}` option expects an argument!'.format(args[i]))
                sys.exit(1)
            i += 1
            try:
                d = json.loads(args[i])
                if not isinstance(d, list):
                    print(f'`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]')
                    sys.exit(1)
                for x in d:
                    if not isinstance(x, list) or len(x) != 3:
                        print(f'`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]')
                        sys.exit(1)
            except Exception as e:
                print(f'`{args[i - 1]}` option expects an array of [longitude, latitude, zoom]')
                sys.exit(1)
            enabled_options[args[i - 1][2:]] = args[i]
        elif args[i] == '-h' or args[i] == '--help':
            run_help()
        else:
            print('Unknown option `{}`, run with with `-h` or `--help` to see the list of commands'
                .format(args[i]))
            sys.exit(1)
        i += 1
    return enabled_options


def main():
    definitions = globals()
    options = parse_args(sys.argv[1:])
    for key in options:
        if key in COMMANDS and options[key] is True:
            func_name = 'run_{}'.format(key.replace('-', '_'))
            ret = definitions[func_name](options)
            if ret != 0:
                print('{} command failed'.format(key))
                sys.exit(ret)


if __name__ == '__main__':
    main()
