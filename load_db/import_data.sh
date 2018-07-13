#!/bin/bash
set -e
set -x

optional_invoke_args=$1

# run the python script that loads all the data
invoke $optional_invoke_args

# we tell redis that the import is finished so tilerator can start
if [ "$REDIS_SET_KEY" = "true" ]; then
	redis-cli -h redis set 'data_imported' 'true'
fi
