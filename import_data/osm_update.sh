#!/bin/bash

set -o pipefail

description="OpenStreetMap database update script"
version="0.3/20191112"

# ----------------------------------------------------------------------------
# Settings
OSM_UPDATE_WORKING_DIR=${OSM_UPDATE_WORKING_DIR:-/data/osmosis}

# Internal
EXEC_TIME=$(date '+%Y%m%d-%H%M%S')
LOG_DIR=$OSM_UPDATE_WORKING_DIR/log
LOG_FILE=$LOG_DIR/${EXEC_TIME}.$(basename $0 .sh).log
LOG_MAXDAYS=7  # Log files are kept $LOG_MAXDAYS days
INVOKE_CONFIG_FILE="${INVOKE_CONFIG_FILE:-}"
INVOKE_OPTION=""
if [ ! -z "$INVOKE_CONFIG_FILE" ]; then
    INVOKE_OPTION="-f $INVOKE_CONFIG_FILE"
fi


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
    echo "    --input, -i     <path to osm change file (.osc.gz)>"
    echo
    echo "    --help, -h"
    echo "        display help and version"
    echo
    echo "    Dependencies: imposm3, jq"
    echo
    exit 0
}

log () {
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :INFO: $1" | tee -a $LOG_FILE
}

log_error () {
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :ERROR: $1" | tee -a $LOG_FILE
    echo "[`date +"%Y-%m-%d %H:%M:%S"`] $$ :ERROR: $(basename $0) terminated in error!" | tee -a $LOG_FILE

    # Message in stdout for console and cron
    echo "$(basename $0) (PID=$$) terminated in error!"
    echo "$1"
    echo "see $LOG_FILE for more details"

    exit 1
}

run_imposm_update() {
    local IMPOSM_CONFIG_FILE="${IMPOSM_CONFIG_DIR}/$1"
    local IMPOSM_FOLDER_NAME=$(jq -r .tiles_layer_name $IMPOSM_CONFIG_FILE)
    local MAPPING_FILENAME=$(jq -r .mapping_filename $IMPOSM_CONFIG_FILE)
    local MAPPING_PATH="${IMPOSM_CONFIG_DIR}/${MAPPING_FILENAME}"

    log "apply changes on OSM database"
    log "${CHANGE_FILE} file size is $(ls -sh ${CHANGE_FILE} | cut -d' ' -f 1)"

    if ! imposm3 diff -quiet -config $IMPOSM_CONFIG_FILE -connection $PG_CONNECTION_STRING \
        -mapping ${MAPPING_PATH} \
        -cachedir ${IMPOSM_DATA_DIR}/cache/${IMPOSM_FOLDER_NAME} \
        -diffdir ${IMPOSM_DATA_DIR}/diff/${IMPOSM_FOLDER_NAME} \
        -expiretiles-dir ${OSM_UPDATE_WORKING_DIR}/expiretiles/${IMPOSM_FOLDER_NAME} \
        ${CHANGE_FILE} | tee -a $LOG_FILE ; then
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
    local EXPIRE_TILES_DIRECTORY=${OSM_UPDATE_WORKING_DIR}/expiretiles/${TILES_LAYER_NAME}
    EXPIRE_TILES_FILE=$(concat_with_pipe $(find $EXPIRE_TILES_DIRECTORY -type f -newerct `date -d @$START -u -Iseconds`))

    if [ -z "$EXPIRE_TILES_FILE" ]; then
        log "no expired tiles"
        return 0
    fi

    log "file with tile to regenerate = $EXPIRE_TILES_FILE"

    invoke $INVOKE_OPTION generate-expired-tiles \
        --tiles-layer $TILES_LAYER_NAME \
        --from-zoom $FROM_ZOOM \
        --before-zoom $BEFORE_ZOOM \
        --expired-tiles $EXPIRE_TILES_FILE | tee -a $LOG_FILE
}

# ----------------------------------------------------------------------------

mkdir -p ${LOG_DIR}
touch $LOG_FILE

# Remove old log files
find ${LOG_DIR} -name "*.log" -mtime +$LOG_MAXDAYS -delete


OPTIONS=cih
LONGOPTIONS=config:,input:,help

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
        -i|--input)
            CHANGE_FILE="$2"
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

log "new $(basename $0) process started"
log "working into directory: ${OSM_UPDATE_WORKING_DIR}"

if [ ! -f $PGPASS ]; then
    log "ERROR: PostgreSQL user $PGUSER password file $PGPASS not found!"
    exit 1
fi

if [ -z "${CHANGE_FILE}" ]; then
    log_error "a change file is required as input."
fi

if [ ! -f "${CHANGE_FILE}" ]; then
    log_error "Change file ${CHANGE_FILE} is not found."
fi

# Update db and tiles, only if changes file is not empty
if [ -s ${CHANGE_FILE} ]; then
    # Imposm update for both tiles sources
    run_imposm_update $BASE_IMPOSM_CONFIG_FILENAME
    run_imposm_update $POI_IMPOSM_CONFIG_FILENAME

    # Reindex geometries to avoid index bloat
    invoke $INVOKE_OPTION reindex-poi-geometries

    # Create tiles jobs for both tiles sources
    create_tiles_jobs $BASE_IMPOSM_CONFIG_FILENAME $BASE_TILERATOR_GENERATOR $BASE_TILERATOR_STORAGE
    create_tiles_jobs $POI_IMPOSM_CONFIG_FILENAME $POI_TILERATOR_GENERATOR $POI_TILERATOR_STORAGE

    # Uncomment next line to enable lite tiles generation, using base database :
    # create_tiles_jobs $BASE_IMPOSM_CONFIG_FILENAME "ozgen-lite" "v2-lite"
else
    log "Changes file is empty. Nothing to update."
fi

log "============"
log "current location: $(pwd)"
log "============"

END=$(date +%s)
DURATION=$(($END-$START))
DURATION_STR=$(printf '%dh%02dm%02ds' $(($DURATION/3600)) $(($DURATION%3600/60)) $(($DURATION%60)))
log "$(basename $0) duration: $DURATION_STR"

log "$(basename $0) successfully terminated!"

exit 0
