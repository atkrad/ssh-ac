#!/bin/bash

SCRIPT_DIR=`dirname $(readlink -f $0)`
SERVERS_DIR=${SCRIPT_DIR}/servers
USERS_DIR=${SCRIPT_DIR}/users

SSH_COMMAND=$(which ssh)
IDENTITY_FILE=${HOME}/.ssh/id_rsa.pub

# Load all functions
source ${SCRIPT_DIR}/functions.sh

while getopts ":i:h" OPT; do
    case ${OPT} in
    i)
        IDENTITY_FILE=$OPTARG >&2
        ;;
    h)
        echo "Usage: grant [-i [identity_file]]" >&2
        exit 0
        ;;
    \?)
        colorizePrint "Invalid option: -$OPTARG, Please use help option -h\n" RED
        exit 1
        ;;
    :)
        colorizePrint "Option -$OPTARG requires an argument.\n" RED
        exit 1
        ;;
    esac
done

if [ ! -r "$IDENTITY_FILE" ]; then
    colorizePrint "Identity file '$IDENTITY_FILE' does not exist or readable.\n" RED
    exit 1
fi

PUB_KEYS=`cat ${IDENTITY_FILE}`\\\\n

SERVERS=`getServers` || colorizePrint "Server not found.\n" RED; exit 1
for SERVER in ${SERVERS}
do
	source ${SERVER};
	FILENAME=$(basename "$SERVER")

    SERVER_ID="${FILENAME%.*}"
	SERVER_IP=${IP:-}
    SERVER_PORT=${PORT:-22}
    SERVER_USER=${USER:-root}
    SERVER_TITLE=${TITLE:-$SERVER_ID}

    # Show error when server ip not defined
    if [ -z "${SERVER_IP}" ]; then
        colorizePrint "Please define IP for '$SERVER_TITLE' server.\n" RED
        exit 1
    fi

    if [ "$SERVER_USER" == "root" ]; then
        SERVER_HOME=/root
        else
        SERVER_HOME=/home/${SERVER_USER}
    fi

    for USER in `ls -A ${USERS_DIR}/*.usr`
    do
        source ${USER};
        GRANT_SERVERS_ID=${GRANT_SERVERS_ID[@]:-$('')}
        PUBLIC_KEYS=${PUBLIC_KEYS[@]:-$('')}

        # If access to this server
        if inArray GRANT_SERVERS_ID ${SERVER_ID}; then
            for PUB_KEY in ${PUBLIC_KEYS}
            do
                PUB_KEYS+=${PUB_KEY}\\\\n
            done
        fi
    done

    colorizePrint "Connecting to '$SERVER_TITLE' ...\n"
    ${SSH_COMMAND} ${SERVER_USER}@${SERVER_IP} -p${SERVER_PORT} "cp $SERVER_HOME/.ssh/authorized_keys $SERVER_HOME/.ssh/authorized_keys.bak && echo -e $PUB_KEYS > $SERVER_HOME/.ssh/authorized_keys"
done
