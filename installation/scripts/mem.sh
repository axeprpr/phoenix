#!/bin/bash

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

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

new_echo() {
    text=$(printf "%-15s :  %s\n" "$1" "$2")
    echo -e "${YELLOW}${text}${PLAIN}"
}

usage() {
    echo -e "${SKYBLUE}Usage: $0 [-s]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo -e "  -s: 测试内存大小，默认是64MB。${PLAIN}"
    exit 1
}

size=64
# 解析命令行参数
while getopts ":s:" opt; do
    case $opt in
        s)
            size=$OPTARG
            if [[ $size =~ ^[0-9]+$ ]]; then
                mem_free=$(awk '/MemFree/{print int($2/1024)}' /proc/meminfo | head -n1)
                if [ "$size" -gt "$mem_free" ]; then
                    echo -e "${RED}无效的size值:${OPTARG}，size值超过实际剩余内存大小。${PLAIN}"
                    usage
                    exit 1
                fi
            else
                echo -e "${RED}无效的size值:${OPTARG}${PLAIN}"
                usage
                exit 1
            fi
            ;;
        \?)
            usage
            ;;
        :)
    esac
done
next
echo -e "${SKYBLUE}内存基本信息：${PLAIN}"
next
echo -e "${YELLOW}"
free -h
echo -e "${PLAIN}"
next
echo -e "${SKYBLUE}内存设备信息：${PLAIN}"
next
echo -e "${YELLOW}"
dmidecode --type 17 | awk '
    /Size:/ {size=$2$3} 
    /Type:/ {type=$2} 
    /Speed:/ {speed=$2$3} 
    /Manufacturer/ && !/NO DIMM/ {
        manufacturer=$2; 
        i++; 
        print "Memory Device", i ":", manufacturer, size, type, speed
    }
'
echo -e "${PLAIN}"
next
echo -e "${SKYBLUE}开始进行内存性能测试；测试内存大小为${size}MB${PLAIN}"
echo -e "${YELLOW}"
${CURRENT_DIR}/../utils/memtester $size 1
echo -e "${PLAIN}"
next