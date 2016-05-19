#!/bin/bash
find . -type f -a -path "*/testcases/*.ttcn3" | sed -n "s/^.*\///gp" | while read fileName; do
    echo $fileName | gawk -F"_" '{
        if ($0 ~ /^L/) exit
        printf("%s\n", $0)
    }'
done
