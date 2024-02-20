#!/bin/bash

# firefox
echo "Removing cookies from last session..."

for site in $(find "/home/aluno/.mozilla/firefox" -maxdepth 1 -type d); do 
    cd "$site";
    rm -f cookies.sqlite;
done

# chrome