#!/bin/bash

repoDir=~/srcs/cprih/
gitLogAnalyzer=~/bin/analyzeGitLog.awk
workDir=$(pwd)
callInfoDB=$workDir/callInfo.db
measureFile=$workDir/measureData.txt

function extractCallInfo(){
    pushd $repoDir > /dev/null
    
    echo "generating and analyzing git logs (last 6 months)..."
    afterWhen=$(date --date='-6 month' "+%Y%m")
    git log --stat=200 | $gitLogAnalyzer | awk -F"," -v afterWhen="$afterWhen" '{
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
    ' | sort -t "|" -k2 -n -r | while read line; do
        # Some changed files (per history) may no longer be available in current repo.
        fpath=$(echo "$line" | cut -d "|" -f1)
        if [ ! -f "$repoDir/$fpath" ]; then
            continue
        else
            echo "$line"
        fi
    done >  "$callInfoDB"

    popd > /dev/null
}

function categorizeCallInfo(){
    #Categorize by header/src
    echo "Categorizing the change info..."
    egrep "\.(h|hpp)\|" "$callInfoDB" > "$callInfoDB.hdr"
    totalHdr=$(awk -F"|" '{cnt+=$2} END{print cnt}' "$callInfoDB.hdr")
    egrep "\.cpp\|" "$callInfoDB" > "$callInfoDB.src"
    totalSrc=$(awk -F"|" '{cnt+=$2} END{print cnt}' "$callInfoDB.src")
    echo "TotalHdr=$totalHdr, totalSrc=$totalSrc."
}

function testCycleTime(){
    pushd $repoDir > /dev/null
    touch "$selectedFile"
    TIMEFORMAT="$selectedFile|$selectedWeight|$selectedScope|%R seconds"
    time {
        make test &> /dev/null
        #echo "make test" > /dev/null
    } 
    popd > /dev/null
}

function profileHeaderChange(){
    cnt=$1
    fileIdMax=$(wc -l $hdrNoLimStats | cut -d " " -f1)
    i=1
    while [ "$i" -lt "$cnt" ]; do
        indices=($(shuf -i 1-$fileIdMax -n $cnt))
        for idx in $indices; do
            selectedLine=$(sed "${idx}q;d" "$hdrNoLimStats")
            selectedFile=$(echo "$selectedLine"|cut -d "|" -f1 | tr -d " ")
            selectedScope=$(echo "$selectedLine"|cut -d "|" -f2 | tr -d " ")
            selectedWeight=$(grep "$selectedFile" "$callInfoDB.hdr" | cut -d "|" -f2)
            if [ -z "$selectedWeight" ];then
                echo -n "F"
                continue;
            fi

            echo "selected: $selectedFile=<changes:$selectedWeight|impacts:$selectedScope>"
            testCycleTime >> "$measureFile" 2>&1
            i=$(echo "$i + 1" | bc)
            echo "[$i/$cnt] - Test done for touching $selectedFile[weight=$selectedWeight,scope=$selectedScope]."
        done
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
    }' "$measureFile"
}

################################################################################
### Main procedure
################################################################################
source ~/bin/analyzeIncludes.sh

[ ! -f "$callInfoDB" ] && extractCallInfo
categorizeCallInfo
[ ! -f "$measureFile" ] && profileHeaderChange 100
consolidateData
