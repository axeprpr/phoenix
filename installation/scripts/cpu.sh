#!/bin/bash
###
 # @Description: 
 # @Date: 2023-12-21 14:21:49
 # @LastEditTime: 2023-12-23 01:21:52
 # @FilePath: \phoenix\installation\scripts\cpu.sh
### 
CURRENT_DIR=$(dirname "$(readlink -f "$0")")
. "${CURRENT_DIR}/common.sh"

usage() {
    echo -e "${SKYBLUE}Usage: $0 [-s|-m]${PLAIN}"
    echo -e "${YELLOW}Options:"
    echo "  -s: Single core stress test"
    echo -e "  -m: Multi-core stress test${PLAIN}"
    exit 1
}

single_core_stress_test() {
    tempfile=$(mktemp /tmp/cpu_stress_XXXXXX)
    "${CURRENT_DIR}/../utils/7za" b -mmt1 > "${tempfile}" &
    progress_bar "$!" "开始进行CPU单线程测试 .." "测试结果参考："
    compress_mips=$(awk '/Avr/' "${tempfile}" | awk -F '|' '{match($1, /[0-9]+[^0-9]*$/); print substr($1, RSTART, RLENGTH)}')
    decompress_mips=$(awk '/Avr/{print $NF}' "${tempfile}")
    res=$(printf "%-20s| %-5s%-10s| %-12s| %-12s\n" "Your CPU" "1" "Threads" "${compress_mips}" "${decompress_mips}")
    next
    (cat "${CURRENT_DIR}/7-cpu.com_single_core"; echo -e "\n$res") | awk 'NF' | awk '{print $(NF-2), $0}' | sort -n | cut -d ' ' -f 2- | \
    awk -v color1="$YELLOW" -v color2="$SKYBLUE" -v plain="$PLAIN" '{if ($0 ~ /Your CPU/) print color2 $0 plain; else print color1 $0 plain}'
    next
}

multi_core_stress_test() {
    tempfile=$(mktemp /tmp/cpu_stress_XXXXXX)
    thread_count=$(nproc)
    # 取2/3；有些机器满核压测会直接重启。
    thread_count_to_stress=$(echo "${thread_count} 0.66"|awk '{print int($1*$2)}')
    if [ "${thread_count_to_stress}" -lt 1 ]; then
        thread_count_to_stress=1
    fi
    "${CURRENT_DIR}/../utils/7za" b "-mmt${thread_count_to_stress}" > "${tempfile}" &
    progress_bar "$!" "开始进行CPU多线程测试..\n当前环境线程数：${thread_count}，使用${thread_count_to_stress}个线程进行多线程测试 .." "测试结果参考："
    compress_mips=$(awk '/Avr/' "${tempfile}" | awk -F '|' '{match($1, /[0-9]+[^0-9]*$/); print substr($1, RSTART, RLENGTH)}')
    decompress_mips=$(awk '/Avr/{print $NF}' "${tempfile}")
    res=$(printf "%-20s| %-5s%-10s| %-12s| %-12s\n" "Your CPU" "${thread_count_to_stress}" "Threads" "${compress_mips}" "${decompress_mips}")
    next
    (cat "${CURRENT_DIR}/7-cpu.com_multi_core"; echo -e "\n$res") | awk 'NF' | awk '{print $(NF-2), $0}' | sort -n | cut -d ' ' -f 2- | \
    awk -v color1="$YELLOW" -v color2="$SKYBLUE" -v plain="$PLAIN" '{if ($0 ~ /Your CPU/) print color2 $0 plain; else print color1 $0 plain}'
    next
}

# main
cpu_model=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_num=$(cat /proc/cpuinfo |grep "physical id"|sort|uniq|wc -l)
cpu_cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
next
echo -e "${SKYBLUE}CPU基本信息${PLAIN}"
next
new_echo "CPU Model" "$cpu_model"
new_echo "CPU Number" "$cpu_num"
new_echo "CPU Threads" "$cpu_cores"
new_echo "CPU Frequency" "$freq"
next

# 解析命令行参数
while getopts ":sm" opt; do
    case $opt in
        s)
            mode="single"
            ;;
        m)
            mode="multi"
            ;;
        \?)
            usage
            ;;
        :)
    esac
done
shift $((OPTIND - 1))

if [ -z "${mode:-}" ] || [ "$#" -ne 0 ]; then
    usage
    exit -1
fi

# 根据模式选择压测方法
if [[ $mode == "single" ]]; then
    single_core_stress_test
elif [[ $mode == "multi" ]]; then
    multi_core_stress_test
fi
