#!/usr/bin/env bash


CWD=$( pwd )
DIR="$( cd "$(dirname "$0")" ; pwd -P )"



PAUSE_DURATION=10       # sec
RETRIES_AFTER_MOUNT=5
INTERVAL_FOR_RETRY=5    # sec

BTFSDL_MOUNT_POINT=${DIR}/mnt
PATH_TO_WATCH=${DIR}/share
MAGNETS_FILE_PATH=${PATH_TO_WATCH}/magnet-links
BTFS_TEMP_DIR=$(mktemp -d)




trap unmountAndCleanup INT TERM

mkdir -p ${PATH_TO_WATCH}



watch(){
    local pauseDuration=${1:-60}
    local runInfinite=true

    while [ ${runInfinite} ]; do
        checkForTorrents
        checkForMagnets
        sleep ${PAUSE_DURATION}
    done
}



checkForTorrents(){
    find "${PATH_TO_WATCH}/" -name '*.torrent' -print | while read filePath
    do
        local originDir=$(dirname ${filePath})
        btfsdl ${filePath} ${originDir}
        rm -rf ${filePath}
    done
}


checkForMagnets(){
    if [ -s ${MAGNETS_FILE_PATH} ]; then
        local magnetLink=$(head -1 ${MAGNETS_FILE_PATH})
        local originDir=${PATH_TO_WATCH}
        btfsdl ${magnetLink} ${originDir}
        sed -i '1d' ${MAGNETS_FILE_PATH}
        checkForMagnets
    fi
}


checkIfEmpty(){
    local dirPath="${1}"

    if [ -z "$(ls -A ${dirPath})" ]; then
        echo >&2 "Not empty (${dirPath})"
        exitStatus=1
    else
        echo >&2 "Empty (${dirPath})"
        exitStatus=0
    fi

    return "${exitStatus}"
}


unmountAndCleanup(){
    fusermount -u ${BTFSDL_MOUNT_POINT}
    rm -rf $(BTFS_TEMP_DIR)
}



btfsdl(){
    local torrent=$1
    local targetPath=$2

    echo "Mounting ${torrent}"
    btfs \
        --min-port=${PORT_MIN} \
        --max-port=${PORT_MAX} \
        --max-download-rate=${DOWNLOAD_MAX_RATE} \
        --max-upload-rate=${UPLOAD_MAX_RATE} \
        --data-directory=${BTFS_TEMP_DIR} \
        ${torrent} \
        ${BTFSDL_MOUNT_POINT}

    retryCounter=0
    while [ $(checkIfEmpty ${BTFSDL_MOUNT_POINT}) ]; do
        sleep ${INTERVAL_FOR_RETRY}

        if [ "${retryCounter}" -gt "${RETRIES_AFTER_MOUNT}" ]; then
            break
        fi

        retryCount=$((${retryCounter} + 1))
    done

    if [ $(checkIfEmpty ${BTFSDL_MOUNT_POINT}) ]; then
        echo "Not able to extract contents from ${torrent}"
    else
        cp -a ${BTFSDL_MOUNT_POINT}/. ${targetPath}/
    fi

    unmountAndCleanup
}



mkdir -p ${BTFSDL_MOUNT_POINT}/ > /dev/null 2>&1

watch ${PAUSE_DURATION}
