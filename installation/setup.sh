#!/bin/bash
###
 # @Description: 
 # @Date: 2023-03-31 17:35:54
 # @LastEditTime: 2023-12-23 01:24:58
 # @FilePath: \phoenix\installation\setup.sh
### 
WORK_DIR=$(cd "$(dirname "$0")" && pwd)
MODULE_DIR="/opt/astute_phoenix"
MODULE_COMMAND="/usr/bin/ph"

if [ "$(id -u)" -ne 0 ]; then
    echo "Need root."
    exit 1
fi

if [ -d "${MODULE_DIR}" ]; then
    rm -rf "${MODULE_DIR}"
fi

if [ -L "${MODULE_COMMAND}" ] || [ -f "${MODULE_COMMAND}" ]; then
    rm -f "${MODULE_COMMAND}"
fi

mkdir -p "${MODULE_DIR}"
cp -rf scripts utils ./phoenix.sh "${MODULE_DIR}"
chmod -R 755 "${MODULE_DIR}"

ln -s "${MODULE_DIR}/phoenix.sh" "${MODULE_COMMAND}"
