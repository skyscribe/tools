#!/bin/bash

function detectAndDefineEnv(){
    if [ $# -ge 1 ];then
        dcsFolder=$1
    else
        dcsFolder="./"
    fi
    detailsFile="$dcsFolder/sct_info.csv"
}

function checkAndGenerateReport(){
    if [ ! -f $detailsFile ]; then
        generateDetailedReport
    else
        echo "generated as $detailsFile!"
    fi
}

function generateDetailedReport(){
    echo "Name,Topology,Type,Topo,Trx,Bandwidth,Boards,Radios,Desc" > $detailsFile
    find $dcsFolder -type f -a -path "*/testcases/*.ttcn3" | sed -n "s/^.*\///gp" | while read fileName; do
        echo "$fileName" | gawk -F"_" '{
            if ($0 ~ /^L/) exit

            gsub(/.ttcn3$/, "", $0)
            topology = ""
            type = ""
            topo_details = ""
            trx = ""
            bandwidth = ""
            boards = ""
            radios = ""
            desc = ""

            for (i = 1; i <= NF; ++i){
                if ($i ~ /^T[0-9xX]+/)
                    topology = topology "_" $i
                else if ($i ~ /^[A-Z]$/)
                    type = $i
                else if ($i ~ /^[0-9]{1,3}$/)
                    topo_details = topo_details "_" $i
                else if ($i ~ /^([0-9]+([TR]X?)+)+$/)
                    trx = trx "_" $i
                else if ($i ~ /^([0-9][xX])?([12]?[05])M([Hh][zZ])?$/)
                    bandwidth = bandwidth "_" $i
                else if ($i ~ /^([0-9]+)?F[A-Z]+$/){
                    if ($i ~ /(FSIH|FSIP|FBIP|FSMF|FBBA|FBIH)/)
                        boards = boards "_" $i
                    else
                        radios = radios "_" $i
                }else
                    desc = desc "_" $i
            }
            output = sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s", $0, topology, type, topo_details, 
                    trx, bandwidth, boards, radios, desc)
            gsub(",_", ",", output)
            gsub(/^_/, "", output)
            print output
        }'
    done  >> $detailsFile
}

#######################################################################################
detectAndDefineEnv "$@"
checkAndGenerateReport
