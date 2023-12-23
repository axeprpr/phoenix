#!/bin/bash
###
 # @Description: 
 # @Date: 2023-12-21 14:21:49
 # @LastEditTime: 2023-12-23 00:12:34
 # @FilePath: \phoenix\installation\phoenix.sh
### 

# Colors
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
SKYBLUE="\033[36m"
WHITE="\033[37m"
PLAIN="\033[0m"
BOLD_TEXT=$(tput bold)
RESET_BOLD=$(tput sgr0)

# 是否支持ansi转义
ANSI=
if [ -t 1 ] && [ "$(tput colors)" -ge 8 ]; then
    ANSI=y
else
    echo "${BOLD_TEXT}当前终端不支持ANSI转义，部分显示可能有问题。${RESET_BOLD}"
fi

CURRENT_DIR=$(dirname $(readlink -f "$0"))

usage() {
    echo -e "${SKYBLUE}Usage: $0 [info|cpu|disk|mem|fast]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo "  fast: 快速测试，包含cpu单核测试；使用当前目录进行1GB磁盘测试；128MB内存测试；"
    echo "  cpu: CPU测试，包括单核和多核；"
    echo "  disk: 磁盘测试，可指定磁盘目录和大小，默认使用当前目录和1GB；"
    echo -e "  mem: 内存测试，可指定内存大小，默认使用128GB;${PLAIN}"
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
            clear
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

