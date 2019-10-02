#!/usr/bin/env python3

import subprocess
import time
import sys


def exec_command(command, options):
    if options.get('debug') is True:
        print('==> {}'.format(' '.join(command)))
    p = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    while True:
        output = p.stdout.read1(100)
        # print('hello! {}'.format(len(output)))
        if len(output) == 0:
            rc = p.poll()
            if rc is not None:
                return rc
        if len(output) > 0:
            sys.stdout.buffer.write(output)
            sys.stdout.buffer.flush()


def run_build(options):
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
    run_build(options)
    time.sleep(5) # add into the script a function to check if postgresql is up
    print('> running load-db command')
    return exec_command([
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'run', '--rm',
        '-e', 'INVOKE_OSM_URL={}'.format(options['osm-file-url']),
        '-e', 'INVOKE_TILES_X=66',
        '-e', 'INVOKE_TILES_Y=43',
        '-e', 'INVOKE_TILES_Z=7',
        'load_db',
    ], options)


def run_update_tiles(options):
    run_load_db(options)
    print('> running update-tiles command')
    return exec_command([
        'docker-compose',
        '-f', 'docker-compose.yml',
        '-f', 'local-compose.yml',
        'run', '--rm',
        'load_db',
        'run-osm-update',
    ], options)


def run_shutdown(options):
    print('> running shutdown command')
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
    print('  load-db       : load data from the given `--osm-file-url` (luxembourg by default)')
    print('  update-tiles  : update the tiles data')
    print('  shutdown      : shutdown running docker instances')
    print('  logs          : show docker logs (can be filtered with `--filter` option)')
    print('  --debug       : show more information on the run')
    print('  --filter      : container to show on `logs` command')
    print('  --osm-file-url: URL to be used for pbf file in `load-db`, luxembourg by default')
    print('  -h | --help   : show this help')
    sys.exit(0)


def parse_args(args):
    available_options = ["build", "load-db", "update-tiles", "shutdown", "logs", '--no-dependency-run', '--debug']
    enabled_options = {
        'osm-file-url': 'https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf',
        'filter': [],
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
            enabled_options['filter'].append(args[i])
        elif args[i] == '--osm-file-url':
            if i + 1 >= len(args):
                print('`--osm-file-url` option expects an argument!')
                sys.exit(1)
            i += 1
            enabled_options['osm-file-url'] = args[i]
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
        if key in ["build", "load-db", "update-tiles", "shutdown", "logs"] and options[key] is True:
            func_name = 'run_{}'.format(key.replace('-', '_'))
            definitions[func_name](options)


if __name__ == '__main__':
    main()
