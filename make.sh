#!/bin/bash
curDir=`pwd`
if echo $curDir | grep "cpri"; then
    cpri_proj=1
else
    cpri_proj=0
fi
if [ $# -gt 0 ];then
    domain=$1
    shift
fi

if [ $# -gt 0 ];then
    category=$1
    shift
fi

if [ $cpri_proj -eq 1 ]; then
    #Detect relative folder
    if ls $curDir/ECL/ECL &> /dev/null; then
        topDir=$curDir
    else
        topDir=`echo $curDir | sed -n "s|\(.*cprih\)/.*$|\1|gp"`
    fi

    if [ -z "$domain" ];then
        #Detect if we're in a certain domain
        testDm=`echo $curDir | sed -n "s|.*cprih/testing/\([^/]\+\)/\([^/]\+\)/.*$|\1-\2|gp"`
        if [ ! -z $testDm ];then
            domain=`echo $testDm | cut -d "-" -f2`
            category=`echo $testDm | cut -d "-" -f1`
        else
            domain=`echo $curDir | sed -n "s|.*cprih/src/\([^/]\+\).*$|\1|gp"`
        fi
    fi

    if [ -z $domain ]; then
        echo "invalid domain from $curDir, building all"
    else
        domainOption="domain=$domain"
    fi

    pushd $topDir &> /dev/null 
    echo "Executing: make ${category:-ut mt} ${domainOption} $@"
    make ${category:-ut mt} ${domainOption} $@
    popd &> /dev/null
else
    #free test ground, domain shall be the exename
    exeName=`echo $domain|cut -d "." -f1`
    g++ -std=c++1y -pthread -o $exeName $domain && ./$exeName
fi
