#!/bin/bash
###
 # @Description: 
 # @Date: 2023-12-21 14:21:49
 # @LastEditTime: 2023-12-23 00:12:34
 # @FilePath: \phoenix\installation\phoenix.sh
### 
CURRENT_DIR=$(dirname "$(readlink -f "$0")")
. "${CURRENT_DIR}/scripts/common.sh"

usage() {
    echo -e "${SKYBLUE}Usage: $0 [info|cpu|disk|mem|fast]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo "  fast: 快速测试，包含cpu单核测试；使用当前目录进行1GB磁盘测试；128MB内存测试；"
    echo "  cpu: CPU测试，包括单核和多核；"
    echo "  disk: 磁盘测试，可指定磁盘目录和大小，默认使用当前目录和1GB；"
    echo -e "  mem: 内存测试，可指定内存大小，默认使用64MB;${PLAIN}"
    exit 1
}

case "$1" in
    "info")
        ${CURRENT_DIR}/scripts/info.sh
        ;;
    "cpu")
        shift 1
        ${CURRENT_DIR}/scripts/cpu.sh "$@"
        ;;
    "disk")
        shift 1
        ${CURRENT_DIR}/scripts/disk.sh "$@"
        ;;
    "mem")
        shift 1
        ${CURRENT_DIR}/scripts/mem.sh "$@"
        ;;
    "fast")
        echo -ne "${SKYBLUE}快速测试同时包含CPU单核测试；磁盘测试；内存测试。是否继续？(y/n): ${PLAIN}"
        read choice
        if [ "$choice" == "y" ]; then
            clear_screen
            ${CURRENT_DIR}/scripts/info.sh
            echo -e "${SKYBLUE}开始快速测试 .. ${PLAIN}"
            ${CURRENT_DIR}/scripts/cpu.sh -s
            ${CURRENT_DIR}/scripts/disk.sh
            ${CURRENT_DIR}/scripts/mem.sh
        else
            echo "bye"
            exit 0
        fi
        ;;
    *)
        usage
        ;;
esac
