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
    echo -e "${SKYBLUE}Usage: $0 [-d|-s]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo "  -d: 测试路径。默认是当前目录。"
    echo -e "  -s: 测试文件大小。默认是256MB。${PLAIN}"
    exit 1
}

# 显示一个进度状态。前后两行各支持一个字符串描述。
progress_bar() {
    [ -n "$2" ] && echo -e "${SKYBLUE}$2${PLAIN}"
    s='-\|/'; i=0; while kill -0 $1 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${s:$i:1}"; sleep .1; done
    [ -n "$3" ] && echo -e "\n${SKYBLUE}$3${PLAIN}"
}

fio2cdm() {
    awk '
    /^Seq-Read:/          {getline;if($1~/^read/) {seqread=$4}}
    /^Seq-Write:/         {getline;if($1~/^write/){seqwrite=$4}}
    /^Rand-Read-512K:/    {getline;if($1~/^read/) {rread512=$4}}
    /^Rand-Write-512K:/   {getline;if($1~/^write/){rwrite512=$4}}
    /^Rand-Read-4K:/      {getline;if($1~/^read/) {rread4=$4}}
    /^Rand-Write-4K:/     {getline;if($1~/^write/){rwrite4=$4}}
    /^Rand-Read-4K-QD32:/ {getline;if($1~/^read/) {rread4qd32=$4}}
    /^Rand-Write-4K-QD32:/{getline;if($1~/^write/){rwrite4qd32=$4}}
    function n(i) {
    	split(gensub(/\(([0-9.]+)(([kM]?)B\/s)\)?/,"\\1 \\3 ", "g", i), a);
	    s = a[1]; u = a[2];
	    if(u == "K") {s /= 1024}
	    if(u == "")  {s /= 1024 * 1024}
	    return s;
    }
    END {
    	print ("|      | Read(MB/s)|Write(MB/s)|");
	    print ("|------|-----------|-----------|");
        printf("|  Seq |%11.3f|%11.3f|\n", n(seqread),   n(seqwrite));
        printf("| 512K |%11.3f|%11.3f|\n", n(rread512),  n(rwrite512));
        printf("|   4K |%11.3f|%11.3f|\n", n(rread4),    n(rwrite4));
        printf("|4KQD32|%11.3f|%11.3f|\n", n(rread4qd32),n(rwrite4qd32));
    }
    '
}

target=.
size=256m
trap "rm -f ${target}/.fio-diskmark" 0 1 2 3 9 15

# 解析命令行参数
while getopts ":d:s:" opt; do
    case $opt in
        d)
            target=$OPTARG
            
            ;;
        s)
            size=$OPTARG
            if [[ $size =~ ^[0-9]+$ ]]; then
                size="${OPTARG}g"
            else
                size=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
                if ! [[ $size =~ ^[0-9]+[mg]?$ ]]; then
                    echo -e "${RED}无效的size值:${OPTARG}${PLAIN}"
                    exit 1
                fi
            fi
            ;;
        \?)
            usage
            ;;
        :)
    esac
done

tempfile=$(mktemp)
cat <<EOF | ${CURRENT_DIR}/../utils/fio - | fio2cdm > $tempfile &
[global]
ioengine=libaio
iodepth=1
size=${size}
direct=1
runtime=60
directory=${target}
filename=.fio-diskmark

[Seq-Read]
bs=1m
rw=read
stonewall

[Seq-Write]
bs=1m
rw=write
stonewall

[Rand-Read-512K]
bs=512k
rw=randread
stonewall

[Rand-Write-512K]
bs=512k
rw=randwrite
stonewall

[Rand-Read-4K]
bs=4k
rw=randread
stonewall

[Rand-Write-4K]
bs=4k
rw=randwrite
stonewall

[Rand-Read-4K-QD32]
iodepth=32
bs=4k
rw=randread
stonewall

[Rand-Write-4K-QD32]
iodepth=32
bs=4k
rw=randwrite
stonewall
EOF

path=$(readlink -f $target)
next
echo -e "${SKYBLUE}磁盘基本信息：${PLAIN}"
next
echo -e "${YELLOW}"
lsblk
echo -e "${PLAIN}"
next
progress_bar $! "开始在${path}进行磁盘性能测试；测试文件大小为${size}" "测试结果参考："
echo -e "${YELLOW}"
cat $tempfile
echo -e "${PLAIN}"
next