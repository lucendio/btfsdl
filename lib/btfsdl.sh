#!/usr/bin/env /bin/sh

SCRIPT_PATH=$(dirname ${0})



PAUSE_DURATION=10   # sec

BTFSDL_ROOT_PATH=/usr/local/btfsdl
BTFSDL_MOUNT_POINT=${BTFSDL_ROOT_PATH}/mnt
PATH_TO_WATCH=${BTFSDL_ROOT_PATH}/share/
MAGNETS_FILE_PATH=${PATH_TO_WATCH}/magnet-links





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
    find ${PATH_TO_WATCH} -name '*.torrent' -print | while read filePath
    do
        local originDir=$(dirname ${filePath})
        btfsdl ${filePath} ${originDir}
        rm -rf ${filePath}
    done
}


checkForMagnets(){
    if [ -s ${MAGNETS_FILE_PATH} ]; then
        local magnetLink=$(head -1 ${MAGNETS_FILE_PATH})
        local originDir=${BTFSDL_ROOT_PATH}/share
        btfsdl ${magnetLink} ${originDir}
        sed -i '1d' ${MAGNETS_FILE_PATH}
        checkForMagnets
    fi
}



btfsdl(){
    local torrent=$1
    local targetPath=$2
    . ${SCRIPT_PATH}/../conf/params
    echo ${torrent}
    btfs \
        --min-port=${PORT_MIN} \
        --max-port=${PORT_MAX} \
        ${torrent} \
        ${BTFSDL_MOUNT_POINT}
    ls ${BTFSDL_MOUNT_POINT} > /dev/null 2>&1
    sleep 10
    ls ${BTFSDL_MOUNT_POINT} > /dev/null 2>&1
    cp -a ${BTFSDL_MOUNT_POINT}/. ${targetPath}/
    fusermount -u ${BTFSDL_MOUNT_POINT}
}



mkdir -p ${BTFSDL_MOUNT_POINT}/

watch ${PAUSE_DURATION}
