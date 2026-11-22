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
tput clear

cols=$(tput cols)
lines=$(tput lines)
rows=$((lines - 3))

board=()
alive_count=0
history_buffer=()
MAX_HISTORY=10

for ((i=0; i<rows*cols; i++)); do
    board[i]=0
done


# Inicjalizacja planszy z pliku o ile podano
if [[ -n "$1" && -f "$1" ]]; then
    mapfile -t pattern < "$1"

    p_height=${#pattern[@]}
    p_width=${#pattern[0]}

    offset_x=$(( (cols - p_width) / 2 ))
    offset_y=$(( (rows - p_height) / 2 ))

    for ((y=0; y<p_height; y++)); do
        line="${pattern[y]}"
        for ((x=0; x<${#line}; x++)); do
            char="${line:x:1}"
            if (( offset_y + y >= 0 && offset_y + y < rows && offset_x + x >= 0 && offset_x + x < cols )); then
                idx=$(((offset_y + y) * cols + (offset_x + x)))
                if [[ "$char" == "o" ]]; then
                    board[idx]=1
                    ((alive_count++))
                fi
            fi
        done
    done
else
    # Losowa inicjalizacja planszy
    for ((i=0; i<rows*cols; i++)); do
        if (( RANDOM % 5 == 0 )); then
            board[i]=1
            ((alive_count++))
        else
            board[i]=0
        fi
    done
fi

draw() {
    local out="\e[H"

    out+="\e[1;36mGeneration: $gen \t Life cells: $alive_count \t Speed: $delay_ms ms\e[0m\e[K\n"
    out+="\e[1;33m[q] Quit \t [p] Pause/Resume \t [+/-] Adjust Speed \t [u] Undo \e[0m\e[K\n"

    for ((y=0; y<rows; y++)); do
        for ((x=0; x<cols; x++)); do
            local idx=$((y * cols + x))
            
            if (( board[idx] == 1 )); then
                out+="\e[1;92mO\e[0m"
            elif (( board[idx] == 2 )); then
                out+="\e[32mo\e[0m"
            else
                out+=" "
            fi
        done
        out+="\e[K\n"
    done 

    printf "%b" "$out"
}

next_gen() {

    local state_snapshot="${board[*]}"
    
    if (( ${#history_buffer[@]} >= MAX_HISTORY )); then
        history_buffer=("${history_buffer[@]:1}")
    fi
    history_buffer+=("$state_snapshot")

    local new_board=()
    alive_count=0

    for ((y=0; y<rows; y++)); do
        for ((x=0; x<cols; x++)); do
            local idx=$((y * cols + x))
            local neighbors=0

            for dy in -1 0 1; do
                for dx in -1 0 1; do
                    (( dy == 0 && dx == 0 )) && continue

                    local nx=$((x + dx))
                    local ny=$((y + dy))

                    if (( nx >= 0 && nx < cols && ny >= 0 && ny < rows )); then
                        local n_idx=$((ny * cols + nx))
                        (( board[n_idx] > 0 )) && (( neighbors++ ))
                    fi
                done
            done



            if (( board[idx] > 0 )); then
                if (( neighbors == 2 || neighbors == 3 )); then
                    new_board[idx]=2
                    ((alive_count++))
                else
                    new_board[idx]=0
                fi
            else
                if (( neighbors == 3 )); then
                    new_board[idx]=1
                    ((alive_count++))
                else
                    new_board[idx]=0
                fi
            fi
        done
    done

    board=("${new_board[@]}")
}

undo() {
    local hist_len=${#history_buffer[@]}

    if (( hist_len > 0 )); then
        local last_idx=$(( hist_len - 1 ))
        read -a board <<< "${history_buffer[last_idx]}"

        unset 'history_buffer[last_idx]'
        ((alive_count=0))
        for state in "${board[@]}"; do
            (( state > 0 )) && ((alive_count++))
        done
        ((gen > 0)) && ((gen--))
    fi
}

gen=0
paused=0
delay_ms=100

while true; do
    draw

    sec=$((delay_ms / 1000))
    frac=$((delay_ms % 1000))

    printf -v delay_sec "%d.%03d" "$sec" "$frac"

    read -t "$delay_sec" -n 1 key
    case "$key" in
        q|Q) cleanup ;;
        p|P) paused=$((1 - paused)) ;;
        u|U) 
            paused=1
            undo
            ;;
        +) 
            (( delay_ms -= 50 ))
            (( delay_ms < 50 )) && delay_ms=50
            ;;
        -)
            (( delay_ms += 50 ))
            (( delay_ms > 2000 )) && delay_ms=2000
            ;;
    esac

    if (( paused == 0 )); then
        next_gen
        ((gen++))
    fi
done