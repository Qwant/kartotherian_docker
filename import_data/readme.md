# Python script to import all the data into postgres

The script is based on [invoke](https://github.com/pyinvoke/)

## install

You need [pipenv](https://github.com/pypa/pipenv)

`pipenv install`

## run

To import all data:

`INVOKE_OSM_URL=url_to_an_osm_file pipenv run invoke`

or to use an already downloaded file:

`INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke`

By default, generated data will be stored in a `/data` folder so you
should make sure this folder exists and is writable prior to running
the import.

Note:
the osm file can also be put in the `invoke.yaml` file.

To only run one task:

`INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke <one_task>`
eg.

`INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke load-poi`

Note: be careful to replace `_` with `-` in the function name

Note: the `pipenv` command should be ran from the `import_data` folder.
