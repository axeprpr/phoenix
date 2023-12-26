#!/bin/bash

CURRENT_DIR=$(dirname "$(readlink -f "$0")")
. "${CURRENT_DIR}/common.sh"

usage() {
    echo -e "${SKYBLUE}Usage: $0 [-d|-s]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo "  -d: 测试路径。默认是当前目录。"
    echo -e "  -s: 测试文件大小。默认是256MB。${PLAIN}"
    exit 1
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
tempfile=

cleanup() {
    rm -f "${target}/.fio-diskmark"
    [ -n "${tempfile}" ] && rm -f "${tempfile}"
}

trap cleanup EXIT INT TERM

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

if [ ! -d "${target}" ]; then
    echo -e "${RED}无效的测试路径:${target}${PLAIN}"
    exit 1
fi

if [ ! -w "${target}" ]; then
    echo -e "${RED}测试路径不可写:${target}${PLAIN}"
    exit 1
fi

tempfile=$(mktemp)
cat <<EOF | "${CURRENT_DIR}/../utils/fio" - | fio2cdm > "${tempfile}" &
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

path=$(readlink -f "${target}")
next
echo -e "${SKYBLUE}磁盘基本信息：${PLAIN}"
next
echo -e "${YELLOW}"
lsblk
echo -e "${PLAIN}"
next
progress_bar "$!" "开始在${path}进行磁盘性能测试；测试文件大小为${size}" "测试结果参考："
echo -e "${YELLOW}"
cat "${tempfile}"
echo -e "${PLAIN}"
next
