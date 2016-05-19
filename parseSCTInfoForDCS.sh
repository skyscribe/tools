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
    find $dcsFolder -type f -a -path "*/testcases/*.ttcn3" | sed -n "s/^.*\///gp" | while read fileName; do
        echo "$fileName" | gawk -F"_" '{
            if ($0 ~ /^L/) exit
            for (i = 1; i <= NF; ++i){
                if ($i ~ /^T[0-9xX]+/)
                    topology = topology "_" $i
                else if ($i ~ /^[A-Z]$/)
                    type = $i
                else if ($i ~ /^[0-9]{1,3}$/)
                    topo_details = topo_details "_" $i
                else if ($i ~ /^[0-9](TX|RX)+$/)
                    trx = trx "_" $i
                else if ($i ~ /^([0-9]X)?(5|10|15|20)M(Hz)?$/)
                    bandwidth = bandwidth "_" $i
                else if ($i ~ /^([0-9]+)?F[A-Z]+$/){
                    if ($i ~ /(FSIH|FSIP|FSMF|FBBA|FBIH)/)
                        boards = boards "_" $i
                    else
                        radios = radios "_" $i
                }else
                    desc = desc "_" $i
            }
            output = sprintf("%s,%s,%s,%s,%s,%s,%s,%s", topology, type, topo_details, trx, bandwidth, boards, radios, desc)
            gsub(",_", ",", output)
            gsub(/^_/, "", output)
            print output
        }'
    done  > $detailsFile
}

#######################################################################################
detectAndDefineEnv "$@"
checkAndGenerateReport
