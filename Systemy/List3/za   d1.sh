#!/bin/bash

cleanup() {
    tput cnorm
    stty sane
    tput clear
    exit 0
}
trap cleanup SIGINT SIGTERM

tput civis
stty -echo -icanon time 0 min 0

lines=$(tput lines)
rows=$((lines - 11))
hud_row=$((lines - 9))

MY_UID=$(id -u)
testiteration=0
offset=0

while true; do
    tput cup 0 0
    printf "%-7s %-7s %-20s %-5s %-7s %-8s %-7s %-7s %-5s [%s]\n" "PID" "PPID" "COMMAND" "STATE" "TTY" "RSS[KB]" "PGID" "SID" "FDs" "$testiteration"
    ((testiteration++))
    printf "%74s\n" " " | tr ' ' '-'
    for pid_dir in /proc/[1-9]*/; do
        [ -O "$pid_dir" ] || continue
        [ ! -r "${pid_dir}stat" ] && continue
        { read -a stat_arr < "${pid_dir}stat"; } 2>/dev/null
        [ ${#stat_arr[@]} -eq 0 ] && continue
        pid="${stat_arr[0]}"
        comm="${stat_arr[1]}"
        state="${stat_arr[2]}"
        ppid="${stat_arr[3]}"
        pgrp="${stat_arr[4]}"
        session="${stat_arr[5]}"
        tty_nr="${stat_arr[6]}"
        rss_pages="${stat_arr[23]}"
        (( rss_kb = rss_pages * 4 ))

        fd_count=0
        if [ -r "${pid_dir}fd" ]; then
            for fd in "${pid_dir}fd/"*; do
                [ -e "$fd" ] && (( fd_count++ ))
            done
        fi



        printf "%-7s %-7s %-20s %-5s %-7s %-8s %-7s %-7s %-5s\n" "$pid" "$ppid" "$comm" "$state" "$tty_nr" "$rss_kb" "$pgrp" "$session" "$fd_count"
    done | tail -n +$((offset + 1)) | head -n $rows
    tput ed

    read -t 1 -n 1 key
    case "$key" in
        q|Q) cleanup ;;
        k|K)
            stty echo icanon
            tput cup ${hud_row} 0
            read -p "Podaj PID do zatrzymania: " k_pid
            kill -TERM "$k_pid" 2>/dev/null
            stty -echo -icanon time 0 min 0
            ;;
        w|W)
            ((offset > 0)) && ((offset--))
            ;;
        s|S)
            ((offset++))
            ;;
        r|R)
            stty echo icanon
            tput cup ${hud_row} 0
            read -p "Podaj PID: " r_pid
            read -p "Podaj nowy Nice (-20 do 19): " r_nice
            renice "$r_nice" -p "$r_pid" 2>/dev/null
            stty -echo -icanon time 0 min 0
            ;;
        p|P)
            stty echo icanon
            tput cup ${hud_row} 0
            read -p "Podaj PID do pauzy: " s_pid
            kill -STOP "$s_pid" 2>/dev/null
            stty -echo -icanon time 0 min 0
            ;;
        c|C)
            stty echo icanon
            tput cup ${hud_row} 0
            read -p "Podaj PID do wznowienia: " c_pid
            kill -CONT "$c_pid" 2>/dev/null
            stty -echo -icanon time 0 min 0
            ;;
        h|H)
            stty echo icanon
            tput cup ${hud_row} 0
            echo "Dostępne polecenia:"
            echo "q - wyjście"
            echo "k - zakończenie procesu"
            echo "r - zmiana priorytetu procesu (renice)"
            echo "p - wstrzymanie procesu (STOP)"
            echo "c - wznowienie procesu (CONT)"
            echo "w/s - przewijanie listy w górę/dół"
            echo "h - pomoc"
            read -n 1 -s -r -p "Naciśnij dowolny klawisz, aby kontynuować..."
            stty -echo -icanon time 0 min 0
            ;;
    esac
done