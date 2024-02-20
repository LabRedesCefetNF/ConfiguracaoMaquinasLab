#!/bin/bash

# firefox
echo "Removing cookies from last session..."

for cookie in $(find "/home/aluno/.mozilla/firefox" -maxdepth 1 -name cookies.sqlite 2> /dev/null); do 
    rm -f ${cookie};
done

# chrome