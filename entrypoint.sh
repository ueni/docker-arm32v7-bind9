#!/bin/bash

#
# Script options (exit script on command fail).
#
set -e

#
# Define default Variables.
#

USER="named"
GROUP="bind"
COMMAND_OPTIONS_DEFAULT="-f"
NAMED_UID_DEFAULT="1000"
NAMED_GID_DEFAULT="101"
COMMAND="/usr/sbin/named -u ${USER} -c /etc/bind/named.conf ${COMMAND_OPTIONS:=${COMMAND_OPTIONS_DEFAULT}}"

if [ -z "$(getent group $GROUP)" ]
then
    echo "add missing group ${GROUP}"
    addgroup -gid ${NAMED_GID_DEFAULT} ${GROUP}
fi

if [ -z "$(getent passwd $USER)" ]
then
    echo "add missing user ${USER}"
    adduser --system --uid ${NAMED_UID_DEFAULT} --ingroup ${GROUP} ${USER}
fi

NAMED_UID_ACTUAL=$(id -u ${USER})
NAMED_GID_ACTUAL=$(id -g ${GROUP})

#
# Display Version
#
echo "versions"
echo "=============="
echo "  image:           $VERSION"
echo 

#
# Display settings on standard out.
#
echo "named settings"
echo "=============="
echo
echo "  Username:        ${USER}"
echo "  Groupname:       ${GROUP}"
echo "  UID actual:      ${NAMED_UID_ACTUAL}"
echo "  GID actual:      ${NAMED_GID_ACTUAL}"
echo "  UID prefered:    ${NAMED_UID:=${NAMED_UID_DEFAULT}}"
echo "  GID prefered:    ${NAMED_GID:=${NAMED_GID_DEFAULT}}"
echo "  Command:         ${COMMAND}"
echo

#
# Change UID / GID of named user.
#
echo "Updating UID / GID... "
if [ ${NAMED_GID_ACTUAL} -ne ${NAMED_GID} -o ${NAMED_UID_ACTUAL} -ne ${NAMED_UID} ]
then
    echo "change user / group"
    deluser ${USER}

    if [ -z "$(getent group $GROUP)" ]
    then
        echo "add group ${GROUP}"
        addgroup -gid ${NAMED_GID} ${GROUP}
    fi

    adduser --system --uid ${NAMED_UID} --ingroup ${GROUP} ${USER}
    echo "[DONE]"
    echo "Set owner and permissions for old uid/gid files"
    find / -type f -user  ${NAMED_UID_ACTUAL} -not -path "/proc/*" -exec chown ${USER}  {} \;
    find / -type f -group ${NAMED_GID_ACTUAL} -not -path "/proc/*" -exec chgrp ${GROUP} {} \;
    echo "[DONE]"
else
    echo "[NOTHING DONE]"
fi

#
# Set owner and permissions.
#
echo "Set owner and permissions... "
dirs=( /var/bind /etc/bind /var/run/named /var/log/named /var/cache/bind ) 
mkdir -p                  ${dirs[@]}
chown -R ${USER}:${GROUP} ${dirs[@]}
chmod -R o-rwx            ${dirs[@]}
echo "[DONE]"

#
# Start named.
#
echo "Start named... "
exec ${COMMAND}