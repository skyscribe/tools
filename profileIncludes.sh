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
        selectedScope=`cat $hdrNoLimStats | grep $selectedFile | cut -d "|" -f2 | tr -d " "`
        if [ -z "$selectedScope" ];then
            continue
        fi

        [ -f $repoDir/$selectedFile ] && [ $selectedWeight -gt 4 ] && gotValid=1
    done

    echo "selected: $selectedFile=<changes:$selectedWeight|impacts:$selectedScope>"
}

function testCycleTime(){
    pushd $repoDir > /dev/null
    touch $selectedFile
    TIMEFORMAT="$selectedFile|$selectedWeight|$selectedScope|%R seconds"
    time {
        make test &> /dev/null
        #echo "make test" > /dev/null
    } 
    popd > /dev/null
}

function profileHeaderChange(){
    cnt=$1
    for i in `seq 1 $cnt`; do
        echo "Testing cycle $i ... "
        randomPickup $callInfoDB.hdr
        testCycleTime >> $measureFile 2>&1
        echo "Test done for touching $selectedFile[weight=$selectedWeight,scope=$selectedScope]."
    done
}

function consolidateData(){
    echo "consolidating..."
    awk -F"|" '{
        fname = $1
        weight = $2
        scope = $3
        split($4, tmpArr, " ")
        time = tmpArr[1]
        raw_tm += time * weight * scope
        factor += weight * scope
        stats[fname] = weight * score * time
        printf("%60s|%8d\n", fname, raw_tm)
    }END{
        printf("Computed time normalized = %.3f\n", raw_tm/factor);
    }' $measureFile
}

################################################################################
### Main procedure
################################################################################
source ~/bin/analyzeIncludes.sh

[ ! -f $callInfoDB ] && extractCallInfo

categorizeCallInfo

[ ! -f $measureFile ] && profileHeaderChange 5

consolidateData
