#!/bin/bash

cleanup() { 
    tput cnorm;
    stty sane;
    tput clear;
    exit 0;
}
trap cleanup SIGINT SIGTERM
tput civis
stty -echo -icanon time 0 min 0

format_speed() {
    local bytes=$1
    if (( bytes < 1024 )); then
        printf "%4d B/s " "$bytes"
    elif (( bytes < 1048576 )); then
        printf "%4d KB/s" "$((bytes / 1024))"
    else
        printf "%4d MB/s" "$((bytes / 1048576))"
    fi
}

draw_bar() {
    local val=$1 max=$2 width=15
    (( max == 0 )) && max=1 
    local bars=$(( val * width / max ))
    (( bars > width )) && bars=$width
    
    local bar_str=""
    for ((i=0; i<bars; i++)); do bar_str="${bar_str}█"; done
    for ((i=bars; i<width; i++)); do bar_str="${bar_str}░"; done
    printf "[%s]" "$bar_str"
}

draw_sparkline() {
    local max=1
    local vals=("$@")
    
    for val in "${vals[@]}"; do
        (( val > max )) && max=$val
    done
    
    local blocks=("_" "▂" "▃" "▄" "▅" "▆" "▇" "█")
    local out=""
    for val in "${vals[@]}"; do
        local idx=$(( val * 7 / max ))
        out="${out}${blocks[$idx]}"
    done
    printf "%s" "$out"
}

SECONDS=0

# Wybór interfejsu (z argumentu skryptu, domyślnie wlo1)
iface="${1:-wlo1}"

while read -a net_line; do
    if [[ "${net_line[0]}" == "${iface}:" ]]; then
        init_rx=${net_line[1]}; prev_rx=$init_rx
        init_tx=${net_line[9]}; prev_tx=$init_tx
        break
    fi
done < /proc/net/dev

rx_hist=(); tx_hist=()
for ((i=0; i<20; i++)); do 
    rx_hist+=(0)
    tx_hist+=(0)
done

prev_idle=()
prev_total=()
c=0
while read core user nice system idle iowait irq softirq rest; do
    if [[ "$core" == cpu[0-9]* ]]; then
        prev_idle[$c]=$idle
        prev_total[$c]=$((user + nice + system + idle + iowait + irq + softirq))
        ((c++))
    fi
done < /proc/stat


while true; do
    tput cup 0 0
    echo -e "\e[1;36m=== MONITOR ZASOBÓW ===\e[0m\e[K"
    
    read uptime_sec rest < /proc/uptime
    read load1 load5 load15 rest < /proc/loadavg
    
    up_d=$(( ${uptime_sec%%.*} / 86400 ))
    up_h=$(( (${uptime_sec%%.*} % 86400) / 3600 ))
    up_m=$(( (${uptime_sec%%.*} % 3600) / 60 ))
    up_s=$(( ${uptime_sec%%.*} % 60 ))
    printf "Uptime:   %d dni, %02d:%02d:%02d\e[K\n" "$up_d" "$up_h" "$up_m" "$up_s"
    printf "Load Avg: %s (1m) %s (5m) %s (15m)\e[K\n\n" "$load1" "$load5" "$load15"


    c=0
    while read core user nice system idle iowait irq softirq rest; do
        if [[ "$core" == cpu[0-9]* ]]; then
            curr_idle=$idle
            curr_total=$((user + nice + system + idle + iowait + irq + softirq))
            
            diff_idle=$((curr_idle - prev_idle[$c]))
            diff_total=$((curr_total - prev_total[$c]))
            
            (( diff_total == 0 )) && diff_total=1
            cpu_usage=$(( 100 * (diff_total - diff_idle) / diff_total ))
            
            prev_idle[$c]=$curr_idle
            prev_total[$c]=$curr_total
            ((c++))
            
            freq_file="/sys/devices/system/cpu/$core/cpufreq/scaling_cur_freq"
            freq_mhz=0
            if [ -r "$freq_file" ]; then
                read freq_khz < "$freq_file"
                freq_mhz=$((freq_khz / 1000))
            fi
            
            printf "%-5s: %3d%% %s @ %4d MHz\e[K\n" "$core" "$cpu_usage" "$(draw_bar $cpu_usage 100)" "$freq_mhz"
        fi
    done < /proc/stat
    echo -e "\e[K"


    while read key val rest; do
        case "$key" in
            MemTotal:) mem_tot=$val ;;
            MemAvailable:) mem_avail=$val ;;
        esac
    done < /proc/meminfo
    (( mem_used = mem_tot - mem_avail ))
    printf "RAM: %6d MB / %6d MB %s\e[K\n\n" "$((mem_used/1024))" "$((mem_tot/1024))" "$(draw_bar $mem_used $mem_tot)"

    
    if [ -n "$iface" ]; then
        while read -a net_line; do
            if [[ "${net_line[0]}" == "${iface}:" ]]; then
                rx="${net_line[1]}"
                tx="${net_line[9]}"
                
                rx_diff=$(( rx - prev_rx ))
                prev_rx=$rx
                tx_diff=$(( tx - prev_tx ))
                prev_tx=$tx
                
                (( SECONDS == 0 )) && div=1 || div=$SECONDS
                rx_avg=$(( (rx - init_rx) / div ))
                tx_avg=$(( (tx - init_tx) / div ))
                
                rx_hist=("${rx_hist[@]:1}" "$rx_diff")
                tx_hist=("${tx_hist[@]:1}" "$tx_diff")
                
                printf "Net %-6s  RX: %s (Średnio: %s)\e[K\n" "$iface" "$(format_speed $rx_diff)" "$(format_speed $rx_avg)"
                printf "\e[32mHist RX:  |%s|\e[0m\e[K\n" "$(draw_sparkline "${rx_hist[@]}")"
                printf "            TX: %s (Średnio: %s)\e[K\n" "$(format_speed $tx_diff)" "$(format_speed $tx_avg)"
                printf "\e[31mHist TX:  |%s|\e[0m\e[K\n" "$(draw_sparkline "${tx_hist[@]}")"
                break
            fi
        done < /proc/net/dev
    fi
    echo -e "\e[K"

    
    bat_file="/sys/class/power_supply/BAT0/uevent"
    if [ -r "$bat_file" ]; then
        while IFS="=" read key val; do
            [[ "$key" == "POWER_SUPPLY_CAPACITY" ]] && bat_cap="$val"
            [[ "$key" == "POWER_SUPPLY_STATUS" ]] && bat_status="$val"
        done < "$bat_file"
        printf "Battery: %s%% (%s) %s\e[K\n" "$bat_cap" "$bat_status" "$(draw_bar $bat_cap 100)"
    fi

    tput ed
    read -t 0.2 -n 1 key
    [[ "$key" == "q" ]] && cleanup
done