#!/bin/bash

inArray() {
    local haystack=${1}[@]
    local needle=${2}
    for i in ${!haystack}; do
        if [[ ${i} == ${needle} ]]; then
            return 0
        fi
    done
    return 1
}

getServers() {
    ls -A ${SERVERS_DIR}/*.srv 2>&1 /dev/null
    if [ "$?" == "0" ]; then
        return `ls -A ${SERVERS_DIR}/*.srv 2>/dev/null`
    else
        exit 1
    fi
}

colorizePrint() {
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local CYAN="\033[0;36m"
    local GRAY="\033[0;37m"
    local BLUE="\033[0;34m"
    local YELLOW="\033[0;33m"
    local NORMAL="\033[m"

    local TEXT=${1:-}
    local COLOR=\$${2:-NORMAL}

    echo -e "`eval echo ${COLOR}`$TEXT"
}
