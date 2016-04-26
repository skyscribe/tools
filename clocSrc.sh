#!/bin/bash
srcDir=$1
for dirs in `find $srcDir -maxdepth 1 -mindepth 1 -type d`; do
    echo -n $dirs; 
    cloc $dirs | grep "SUM:" | tr -d "SUM:" 
done | awk '
    BEGIN{
        printf("%32s|%5s|%8s|%8s|%8s\n", "domain", "files", "blank", "comment", "code");
    } 
    {
        printf("%32s|%5d|%8d|%8d|%8d\n", $1, $2, $3, $4, $5);
    }
'
