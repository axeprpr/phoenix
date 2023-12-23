#!/usr/bin/env bash
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

get_opsy() {
    [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
    [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
    [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

hostname=$(hostname)
system_name=$(get_opsy)
kernel=$(uname -r)
current_time=$(date "+%Y-%m-%d %H:%M")
bootime=$(who -b | awk '{print $(NF-1),$NF}')
manufacturer=$(dmidecode|grep "System Information" -A9|egrep  "Manufacturer|Product Name" | awk 'BEGIN{FS=":";ORS="";}{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_model=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_num=$(cat /proc/cpuinfo |grep "physical id"|sort|uniq|wc -l)
cpu_cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
cpu_vmmtype=$(/usr/bin/systemd-detect-virt 2>/dev/null)
cpu_vmx=$(awk -F ': ' '/flags/{print $2}' /proc/cpuinfo | sort -u | awk 'BEGIN{cpuvmx="unknown"} /vmx/{cpuvmx="Intel VT-x"} /svm/{cpuvmx="AMD-V"} END{print cpuvmx}')
load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
mem_info=$(free -h | awk '/Mem/ {printf("Used: %s Total: %s\n",$3,$2)}')
disk_info=$(lsblk -d --output NAME,SIZE | awk '!/NAME/{printf("%s %s/",$1,$2)} END{printf("\n")}')


clear
next
echo -e "${SKYBLUE}系统信息${PLAIN}"
next
new_echo "Hostname" "$hostname"
new_echo "System Name" "$system_name"
new_echo "System Kernel" "$kernel"
new_echo "Current Time" "$current_time"
new_echo "Boot Time" "$bootime"
new_echo "Manufacturer" "$manufacturer"
new_echo "CPU Model" "$cpu_model"
new_echo "CPU Number" "$cpu_num"
new_echo "CPU Threads" "$cpu_cores"
new_echo "CPU Frequency" "$freq"
new_echo "CPU VMM Type" "$cpu_vmmtype"
new_echo "CPU VMX" "$cpu_vmx"
new_echo "Load" "$load"
new_echo "Memory Info" "$mem_info"
new_echo "Disk Info" "$disk_info"
next