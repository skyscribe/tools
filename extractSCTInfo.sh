#!/bin/bash
find . -type f -a -name "*.ttcn3" | grep -v include | while read fileName; do
    tags=$(sed -n "s/^.*tags//gp" "$fileName" | tr -d "[]")
    if [ ! -z "$tags" ];then
        disabled=$(echo "$tags" | grep -c "DISABLED")
        rel4=$(echo "$tags" | grep -c "REL4")
        dev=$(echo "$tags" | grep -c "DEVELOPMENT")
        if [ $disabled -eq 0 ]; then
            echo "$fileName|$rel4|$dev"
        fi
    fi
done | gawk -F"|" 'BEGIN{
    printf("%s,%s,%s,%s\n", "Function", "Name", "REL", "STATUS")
}
{
    split($1, arr, "/")
    category=arr[2]
    name=arr[3]
    if ($2)
        rel = "REL4"
    else
        rel = "REL3"

    if ($3)
        status = "Dev."
    else
        status = "Ready"

    printf("%s,%s,%s,%s\n", category, name, rel, status)
}'
