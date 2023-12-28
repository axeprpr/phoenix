#!/bin/bash

CURRENT_DIR=$(dirname "$(readlink -f "$0")")
. "${CURRENT_DIR}/common.sh"

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
                mem_available=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo | head -n1)
                if [ -z "${mem_available}" ] || [ "${size}" -gt "${mem_available}" ]; then
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

shift $((OPTIND - 1))
if [ "$#" -ne 0 ]; then
    usage
    exit 1
fi

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
if command -v dmidecode >/dev/null 2>&1; then
    dmidecode --type 17 2>/dev/null | awk '
        /Size:/ {size=$2$3}
        /Type:/ {type=$2}
        /Speed:/ {speed=$2$3}
        /Manufacturer/ && !/NO DIMM/ {
            manufacturer=$2;
            i++;
            print "Memory Device", i ":", manufacturer, size, type, speed
        }
    '
else
    echo "dmidecode is not installed"
fi
echo -e "${PLAIN}"
next
echo -e "${SKYBLUE}开始进行内存性能测试；测试内存大小为${size}MB${PLAIN}"
echo -e "${YELLOW}"
"${CURRENT_DIR}/../utils/memtester" "${size}" 1
echo -e "${PLAIN}"
next
