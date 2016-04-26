#!/bin/bash

# Project-specific settings and report file naming
projTopDir=~/srcs/cprih/
binaryTreeDir=${projTopDir}/bin/LinuxX86/
scriptDir=~/bin/
workDir=$(pwd)

incReportFile=$workDir/includes-rep.txt
cppStats=$workDir/cpp-stats.txt
srcStats=$workDir/src-stats.txt
hdrStats=$workDir/hdr-stats.txt
hdrNoLimStats=$workDir/hdrNoLim-stats.txt

if [ ! -f "$incReportFile" ]; then
    find $binaryTreeDir -type f -a -name "depend.make" | grep -v "lim" | while read dependFile; do
        gawk -f $scriptDir/parseDependMake.awk "$dependFile"

        #append file specific includes
    done > "$incReportFile"
fi


# Calculate statistics 
function statsByCriteria(){
    bannerType=$1
    annotation=$2
    idx=$3
    topNo=$4
    outf=$5
    echo "@@@ Checking $bannerType statistics ($annotation), printing top $topNo"
    gawk -F "|" -v idx="$idx" '{stats[$idx]++;}END{
        for (var in stats)
            printf("%60s|%6d\n", var, stats[var]) 
    }' "$incReportFile" > "$outf"

    sort -k2 -n -t"|" -r $outf | head -"$topNo" > "$outf-top${topNo}"
}

#statsByCriteria  banner  annotation             idx topNo FileOut
statsByCriteria   "src"   "including   testing"   1   10   "$cppStats"
statsByCriteria   "src"   "pure        src"       1   10   "$srcStats"
statsByCriteria   "hdr"   "inc.        LIM"       2   10   "$hdrStats"
statsByCriteria   "hdr"   "excl.       LIM"       2   10   "$hdrNoLimStats"

