#!/bin/bash

DIR="${1:-.}"
LOG="monitor.log"

cnt_create=0
cnt_delete=0
cnt_modify=0
cnt_move=0

last_print=$SECONDS

echo -e "\e[1;36mRozpoczynam monitorowanie katalogu: $DIR\e[0m"
echo -e "Logi będą zapisywane do pliku: \e[1m$LOG\e[0m\n"

inotifywait -m -q --exclude "$LOG" -e create,delete,modify,move "$DIR" --format "%w %e %f" |
while read -t 1 -r directory events filename || (( $? > 128 )); do
    
    if [[ -n "$events" ]]; then
        
        now=$(date '+%Y-%m-%d %H:%M:%S')
        color="\e[0m"
        action=""
        
        if [[ "$events" == *"CREATE"* ]]; then
            color="\e[32m" # Zielony
            action="UTWORZONO"
            ((cnt_create++))
            
        elif [[ "$events" == *"DELETE"* ]]; then
            color="\e[31m" # Czerwony
            action="USUNIĘTO"
            ((cnt_delete++))
            
        elif [[ "$events" == *"MODIFY"* ]]; then
            color="\e[33m" # Żółty
            action="ZMODYFIKOWANO"
            ((cnt_modify++))
            
        elif [[ "$events" == *"MOVE"* ]]; then
            color="\e[36m" # Niebieski
            action="PRZENIESIONO/ZMIENIONO NAZWĘ"
            ((cnt_move++))
        fi

        msg="[$now] $action: ${directory}${filename} (zdarzenie: $events)"
        
        echo -e "${color}${msg}\e[0m"
        
        echo "$msg" >> "$LOG"
    fi

    if (( SECONDS - last_print >= 10 )); then
        echo -e "\n\e[1;35m--- STATYSTYKI ZDARZEŃ (aktualizacja co 10s) ---"
        echo -e "Dodano: $cnt_create | Usunięto: $cnt_delete | Zmodyfikowano: $cnt_modify | Zmiana nazwy: $cnt_move"
        echo -e "------------------------------------------------\e[0m\n"
        last_print=$SECONDS
    fi

done