#!/bin/bash
set -e
set -x

optional_invoke_args=$@

# run the python script that loads all the data
if [[ -z "${INVOKE_CONFIG_FILE}" ]]; then
  invoke $optional_invoke_args
else
  invoke -f $INVOKE_CONFIG_FILE $optional_invoke_args
fi
