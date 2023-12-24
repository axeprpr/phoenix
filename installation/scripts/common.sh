#!/usr/bin/env bash

if [ -n "${PHOENIX_COMMON_SH:-}" ]; then
    return 0
fi
PHOENIX_COMMON_SH=1

if [ -n "${TERM:-}" ] && [ -t 1 ] && command -v tput >/dev/null 2>&1; then
    color_count=$(tput colors 2>/dev/null || printf '0')
else
    color_count=0
fi

if [ -t 1 ] && [ "${color_count}" -ge 8 ]; then
    BLACK="\033[30m"
    RED="\033[31m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
    PURPLE="\033[35m"
    SKYBLUE="\033[36m"
    WHITE="\033[37m"
    PLAIN="\033[0m"
    BOLD_TEXT=$(tput bold 2>/dev/null || true)
    RESET_BOLD=$(tput sgr0 2>/dev/null || true)
    ANSI=y
else
    BLACK=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    PURPLE=""
    SKYBLUE=""
    WHITE=""
    PLAIN=""
    BOLD_TEXT=""
    RESET_BOLD=""
    ANSI=
fi

next() {
    printf "%-70s\n" "-" | sed 's/\s/-/g'
}

new_echo() {
    local text
    text=$(printf "%-15s :  %s\n" "$1" "$2")
    echo -e "${YELLOW}${text}${PLAIN}"
}

progress_bar() {
    [ -n "${2:-}" ] && echo -e "${SKYBLUE}$2${PLAIN}"
    local spinner='-\|/' i=0
    while kill -0 "$1" >/dev/null 2>&1; do
        i=$(((i + 1) % 4))
        printf "\r%s" "${spinner:$i:1}"
        sleep 0.1
    done
    [ -n "${3:-}" ] && echo -e "\n${SKYBLUE}$3${PLAIN}"
}

clear_screen() {
    if [ -t 1 ] && command -v clear >/dev/null 2>&1; then
        clear
    fi
}
