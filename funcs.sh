#!/bin/bash
function syncFolder(){
	if [ ! -d $1 ];then
		mkdir -p $1
	fi
    if [ $# -gt 1 ]; then
        excludeOpt="--exclude-from=$2"
    fi
    set -x
	rsync -arlc --progress $rsyncRemote:$1/ $1/ --exclude='.svn*' $excludeOpt
    set +x
}
