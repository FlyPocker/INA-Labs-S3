#!/bin/bash

echo -e "\e[36mŁączenie z serwerami The Cat API oraz Chuck Norris API...\e[0m"

cat_json=$(curl -s "https://api.thecatapi.com/v1/images/search")

chuck_json=$(curl -s "https://api.chucknorris.io/jokes/random")


cat_url=$(echo "$cat_json" | jq -r '.[0].url')

chuck_quote=$(echo "$chuck_json" | jq -r '.value')

lines=$(tput lines)
img_height=$((lines*2 - 10))

tmp_file="/tmp/random_cat.jpg"
curl -s "$cat_url" -o "$tmp_file"
tput clear
catimg -H $img_height "$tmp_file"

echo -e "\e[1;33m=== Cytat Dnia ===\e[0m"
echo -e "\e[1m$chuck_quote\e[0m\n"

rm -f "$tmp_file"