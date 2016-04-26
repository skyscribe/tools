#!/bin/bash

repoDir=~/srcs/cprih/
gitLogAnalyzer=~/bin/analyzeGitLog.awk
workDir=`pwd`
callInfoDB=$workDir/callInfo.db
measureFile=$workDir/measureData.txt

function extractCallInfo(){
    pushd $repoDir > /dev/null
    
    echo "generating and analyzing git logs (last 6 months)..."
    afterWhen=`date --date='-6 month' "+%Y%m"`
    git log --stat=200 | $gitLogAnalyzer | awk -F"," -v afterWhen=$afterWhen '{
        sub("-", "", $4)
        if (($2 ~ /(src|testing|interface)\/.*[_a-zA-Z0-9]+\.(h|hpp|cpp)/) && ($4 >= afterWhen)){
            stats[$2]++;
            totalCnt++;
        }
    }END{
        for (fname in stats){
            printf("%s|%d\n", fname, stats[fname]);
        }
    }
    ' | sort -t "|" -k2 -n -r > $callInfoDB
    popd > /dev/null
}

function categorizeCallInfo(){
    #Categorize by header/src
    echo "Categorizing the change info..."
    cat $callInfoDB | egrep "\.(h|hpp)\|" > $callInfoDB.hdr
    totalHdr=`cat $callInfoDB.hdr | awk -F"|" '{cnt+=$2} END{print cnt}'`
    cat $callInfoDB | egrep "\.cpp\|" > $callInfoDB.src
    totalSrc=`cat $callInfoDB.src | awk -F"|" '{cnt+=$2} END{print cnt}'`
    echo "TotalHdr=$totalHdr, totalSrc=$totalSrc."
}

function randomPickup(){
    dbFile=$1
    maxCnt=`wc -l $dbFile | cut -d " " -f1`

    gotValid=0
    while [ $gotValid -eq 0 ]; do
        idx=$RANDOM
        let "idx %= $maxCnt" 
        selectedLine=`cat $dbFile | sed "${idx}q;d"`
        selectedFile=`echo $selectedLine|cut -d "|" -f1`
        selectedWeight=`echo $selectedLine|cut -d "|" -f2`

        [ -f $repoDir/$selectedFile ] && [ $selectedWeight -gt 4 ] && gotValid=1
    done

    echo "selected: $selectedFile=$selectedWeight"
}

function testCycleTime(){
    outf=$measureFile
    pushd $repoDir > /dev/null
    touch $selectedFile
    TIMEFORMAT="$selectedFile|$selectedWeight|%R seconds"
    time {
        make test
    } > $measureFile
    popd > /dev/null
}

################################################################################
### Main procedure
################################################################################

[ ! -f $callInfoDB ] && extractCallInfo
categorizeCallInfo

for i in `seq 1 100`; do
    echo "Testing cycle $i ... "
    randomPickup $callInfoDB.hdr
    testCycleTime $measureFile
    echo "Test done for touching $selectedFile[weight=$selectedWeight]."
done
