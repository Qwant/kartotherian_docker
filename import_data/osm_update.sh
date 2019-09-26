#!/bin/bash

set -x

description="OpenStreetMap database update script"
version="0.2/20180716"

# OSMOSIS
#
# Osmosis is the tool used to get change files from OSM repository
# Osmosis working directory contains 3 files:
#   * download.lock
#   * configuration.txt: osmosis configuration. maxInterval setting is used to
#     know how far osmosis is going into a single run. Deactivate that feature
#     by setting 0 (required for initial update run when planet file is old).
#   * state.txt: used to know which change files to download. That file is
#     updated at the end of processing for the next run.
#
# Warning! Osmosis is working into /tmp and downloaded files disk usage can be
# big if working on an old timestamp.
#
# Imposm
#
# Imposm is used to apply changes.osc compiled by Osmosis on the
# OpenStreetMap database.
#


# ----------------------------------------------------------------------------
# Settings
OSMOSIS_WORKING_DIR=${OSMOSIS_WORKING_DIR:-/data/osmosis}

# Internal
CHANGE_FILE=changes.osc.gz
EXEC_TIME=$(date '+%Y%m%d-%H%M%S')
LOG_DIR=$OSMOSIS_WORKING_DIR/log
LOG_FILE=$LOG_DIR/${EXEC_TIME}.$(basename $0 .sh).log
LOG_MAXDAYS=7  # Log files are kept $LOG_MAXDAYS days
LOCK_FILE=$OSMOSIS_WORKING_DIR/$(basename $0 .sh).lock
OSMOSIS=/usr/bin/osmosis
STOP_FILE=${OSMOSIS_WORKING_DIR}/stop
INVOKE_CONFIG_FILE="${INVOKE_CONFIG_FILE:-}"

# imposm
IMPOSM_CONFIG_DIR="/etc/imposm" # default value, can be set with the --config option
IMPOSM_DATA_DIR="${IMPOSM_DATA_DIR:-/data/imposm}" # contains ./cache and ./diff

# base tiles
BASE_IMPOSM_CONFIG_FILENAME="config_base.json"

# poi tiles
POI_IMPOSM_CONFIG_FILENAME="config_poi.json"

#tilerator
FROM_ZOOM=11
BEFORE_ZOOM=15 # exclusive

START=$(date +%s)

# ----------------------------------------------------------------------------

usage () {
    echo "This is `basename $0` v$version"
    echo
    echo "    $description"
    echo
    echo "OPTIONS:"
    echo
    echo "    --config, -c     <path to imposm config dir> [default: /etc/imposm]"
    echo
    echo "    --help, -h"
    echo "        display help and version"
    echo
    echo "    Create a file named $(basename $STOP_FILE) into $OSMOSIS_WORKING_DIR directory"
    echo "        to put process on hold."
    echo
    echo "    Dependencies: osmosis, imposm3, jq"
    echo
    exit 0
}

log () {
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :INFO: $1" >> $LOG_FILE
}

log_error () {
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :ERROR: $1" >> $LOG_FILE

    rm $LOCK_FILE
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :ERROR: restore initial state file" >> $LOG_FILE
    mv ${OSMOSIS_WORKING_DIR}/.state.txt ${OSMOSIS_WORKING_DIR}/state.txt &>/dev/null
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :ERROR: $(basename $0) terminated in error!" >> $LOG_FILE

    # Message in stdout for console and cron
    echo "$(basename $0) (PID=$$) terminated in error!"
    echo "$1"
    echo "see $LOG_FILE for more details"

    exit 1
}

get_lock () {
    if [ -s $LOCK_FILE ]; then
        if ps -p `cat $LOCK_FILE` > /dev/null ; then
            return 1
        fi
    fi
    echo $$ > $LOCK_FILE
    return 0
}

free_lock () {
    rm $LOCK_FILE
}


run_imposm_update() {
    local IMPOSM_CONFIG_FILE="${IMPOSM_CONFIG_DIR}/$1"
    local IMPOSM_FOLDER_NAME=$(jq -r .tiles_layer_name $IMPOSM_CONFIG_FILE)
    local MAPPING_FILENAME=$(jq -r .mapping_filename $IMPOSM_CONFIG_FILE)
    local MAPPING_PATH="${IMPOSM_CONFIG_DIR}/${MAPPING_FILENAME}"

    log "apply changes on OSM database"
    log "${CHANGE_FILE} file size is $(ls -sh ${TMP_DIR}/${CHANGE_FILE} | cut -d' ' -f 1)"

    if ! imposm3 diff -quiet -config $IMPOSM_CONFIG_FILE -connection $PG_CONNECTION_STRING \
        -mapping ${MAPPING_PATH} \
        -cachedir ${IMPOSM_DATA_DIR}/cache/${IMPOSM_FOLDER_NAME} \
        -diffdir ${IMPOSM_DATA_DIR}/diff/${IMPOSM_FOLDER_NAME} \
        -expiretiles-dir ${OSMOSIS_WORKING_DIR}/expiretiles/${IMPOSM_FOLDER_NAME} \
        ${TMP_DIR}/${CHANGE_FILE} | tee -a $LOG_FILE ; then
            log_error "imposm3 failed"
    fi
}


create_tiles_jobs() {
    local IMPOSM_CONFIG_FILE="${IMPOSM_CONFIG_DIR}/$1"
    local TILES_LAYER_NAME=$(jq -r .tiles_layer_name $IMPOSM_CONFIG_FILE)

    log "Creating tiles jobs for $IMPOSM_CONFIG_FILE"

    # tilerator takes a list a file separated by a pipe
    function concat_with_pipe { local IFS="|"; echo "$*";}

    # we load all the tiles generated this day
    local EXPIRE_TILES_DIRECTORY=${OSMOSIS_WORKING_DIR}/expiretiles/${TILES_LAYER_NAME}
    EXPIRE_TILES_FILE=$(concat_with_pipe $(find $EXPIRE_TILES_DIRECTORY -type f -newerct `date -d @$START -u -Iseconds`))

    if [ -z "$EXPIRE_TILES_FILE" ]; then
        log "no expired tiles"
        return 0
    fi

    log "file with tile to regenerate = $EXPIRE_TILES_FILE"

    local INVOKE_OPTION=""
    if [ ! -z "$INVOKE_CONFIG_FILE" ]; then
        INVOKE_OPTION="-f $INVOKE_CONFIG_FILE"
    fi

    invoke $INVOKE_OPTION generate-expired-tiles \
        --tiles-layer $TILES_LAYER_NAME \
        --from-zoom $FROM_ZOOM \
        --before-zoom $BEFORE_ZOOM \
        --expired-tiles $EXPIRE_TILES_FILE | tee -a $LOG_FILE
}

# ----------------------------------------------------------------------------

TMP_DIR=${OSMOSIS_WORKING_DIR}/.$(basename $0).${EXEC_TIME}
trap 'rm -rf ${TMP_DIR} &>/dev/null' EXIT
mkdir -p ${TMP_DIR}
mkdir -p ${LOG_DIR}
touch $LOG_FILE $LOCK_FILE

# Remove old log files
find ${LOG_DIR} -name "*.log" -mtime +$LOG_MAXDAYS -delete


OPTIONS=ctho
LONGOPTIONS=config:,tilerator:,help

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    log_error "impossible to parse the arguments"
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -c|--config)
            IMPOSM_CONFIG_DIR="$2"
            shift 2
            ;;
        -h|--help)
            HELP=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            log_error "argument parsing errors"
            ;;
    esac
done

# Help and configuration checks
[ "$HELP" == true ] && usage
[ ! -f "$OSMOSIS" ] && log_error "$OSMOSIS not found"


log "new $(basename $0) process started"
log "working into directory: ${OSMOSIS_WORKING_DIR}"


if [ -e $STOP_FILE ]; then
    log "$(basename $0) process held!"
    exit 1
fi

if ! get_lock ; then
    log "$(basename $0) process still running: PID=$(cat ${LOCK_FILE})"
    exit 1
fi

if [ ! -f $PGPASS ]; then
    log "ERROR: PostgreSQL user $PGUSER password file $PGPASS not found!"
    exit 1
fi


if [ ! -f ${OSMOSIS_WORKING_DIR}/configuration.txt -o ! -f ${OSMOSIS_WORKING_DIR}/state.txt ]; then
    log_error "osmosis working directory ${OSMOSIS_WORKING_DIR} is not initialized."
fi

log "generate changes file into ${TMP_DIR}/${CHANGE_FILE}"
log "backup of state file"
cp ${OSMOSIS_WORKING_DIR}/state.txt ${OSMOSIS_WORKING_DIR}/.state.txt


if ! $OSMOSIS --read-replication-interval workingDirectory=${OSMOSIS_WORKING_DIR} \
    --simplify-change --write-xml-change \
    ${TMP_DIR}/${CHANGE_FILE} &>> $LOG_FILE ; then

    log_error "osmosis failed"
fi

# Update db and tiles, only if changes file is not empty
if [ -s ${TMP_DIR}/${CHANGE_FILE} ]; then
    # Imposm update for both tiles sources
    run_imposm_update $BASE_IMPOSM_CONFIG_FILENAME
    run_imposm_update $POI_IMPOSM_CONFIG_FILENAME

    # Create tiles jobs for both tiles sources
    create_tiles_jobs $BASE_IMPOSM_CONFIG_FILENAME $BASE_TILERATOR_GENERATOR $BASE_TILERATOR_STORAGE
    create_tiles_jobs $POI_IMPOSM_CONFIG_FILENAME $POI_TILERATOR_GENERATOR $POI_TILERATOR_STORAGE

    # Uncomment next line to enable lite tiles generation, using base database :
    # create_tiles_jobs $BASE_IMPOSM_CONFIG_FILENAME "ozgen-lite" "v2-lite"
else
    log "Changes file is empty. Nothing to update."
fi

free_lock

log "${CHANGE_FILE} file size is $(ls -sh ${TMP_DIR}/${CHANGE_FILE} | cut -d' ' -f 1)"
END=$(date +%s)
DURATION=$(($END-$START))
DURATION_STR=$(printf '%dh%02dm%02ds' $(($DURATION/3600)) $(($DURATION%3600/60)) $(($DURATION%60)))
log "$(basename $0) duration: $DURATION_STR"

log "$(basename $0) successfully terminated!"

exit 0
