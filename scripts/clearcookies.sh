#!/bin/bash

# firefox
for site in $(find "/home/aluno/.mozilla/firefox" -maxdepth 1 -type d); do 
    cd "$site";
    rm -f cookies.sqlite;
done

# chrome