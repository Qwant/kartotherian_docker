# Python script to import all the data into postgres

The script is based on [invoke](https://github.com/pyinvoke/).

## install

You need [pipenv](https://github.com/pypa/pipenv). Once you have it, just run:

```bash
pipenv install
```

## run

To import all data, run:

```bash
INVOKE_OSM_URL=url_to_an_osm_file pipenv run invoke
```

or if you want to use an already downloaded file:

```bash
INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke
```

By default, generated data will be stored in a `/data` folder, so you
should make sure this folder exists and is writable prior to running
the import.

Note: the osm file can also be put in the `invoke.yaml` file.

To only run one task, the syntax looks like this:

```bash
INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke <one_task>
```

So if you want to run the `load-poi` task, you need to run:

```bash
INVOKE_OSM_FILE=path_to_an_osm_file pipenv run invoke load-poi
```

By default, above commands won't import Wikidata tables, if you wish to import
this data you can either change the `invoke.yaml` file or set
`INVOKE_IMPORT_WIKIDATA=1` while importing other data.

Note: be careful to replace `_` with `-` in the function name

Note: the `pipenv` command should be ran from the `import_data` folder.
