#!/bin/bash
set -e
set -x

optional_invoke_args=$@

export AIRFLOW_HOME=/data/update_tiles_data/airflow

invoke -f $INVOKE_CONFIG_FILE init-airflow

airflow scheduler &

airflow webserver -p 8080

# run the python script that loads all the data
# invoke -f $INVOKE_CONFIG_FILE $optional_invoke_args
