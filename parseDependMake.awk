#!/usr/bin/awk -f
BEGIN{
    pathCntCur = split($curFile, pathsForCur, "/")
    FS = ":"
}

function join(array, start, end, sep,    result, i)
{
    if (sep == "")
        sep = " "
    else if (sep == SUBSEP) # magic value
        sep = ""
    result = array[start]
    for (i = start + 1; i <= end; i++)
        result = result sep array[i]
    return result
}

{
    if (($0 ~ /^#.*$/) || (NF != 2)){
        next
    }

    #filter out common stable headers
    if ($2 ~ /\/build\/ltesdkroot\//)
        next
    if ($2 ~ /\/3rdparty\//)
        next

    # Target file may have extra cmake path that are too verbose
    #we don't want the .o suffix, so special handling is made to remove last suffix
    gsub(/\.o/, "", $1)
    pathsCntTarget = split($1, pathsForTarget, "/")

    #CMakeFiles path is the begining of binary tree
    for (i = 1; i < pathsCntTarget; ++i){
        if (pathsForTarget[i] == "CMakeFiles")
            break;
    }
    if (i == pathsCntTarget){
        next
    }
    pathInfo = join(pathsForTarget, 1, i - 1, "/")

    for (; i < pathsCntTarget; ++i){
        if (pathsForTarget[i] ~ /\.dir/)
            break;
    }
    if (i == pathsCntTarget)
        next;
    pathInfo = pathInfo "/" join(pathsForTarget, i + 1, pathsCntTarget, "/")

    gsub(/ /, "", $2)
    pathsCntForHdr = split($2, pathsForHdr, "/")
    for (i = 1; i < pathsCntForHdr; ++i){
        if (pathsForHdr[i] != "..")
            break;
    }
    hdrInfo = join(pathsForHdr, i, pathsCntForHdr, "/")

    printf("%-80s|%-60s\n", pathInfo, hdrInfo)
}

