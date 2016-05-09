#!/bin/bash
source ~/bin/funcs.sh
bldtop=/build/ltesdkroot/
excludeFolder=~/bin/rsync-excludes/

function syncForPart(){
    comp=$1
    fullDir=$2
    if [ ! -z "$comp" ];then
        echo "Updating $PS_REL using rsync"
        syncFolder "$fullDir"
        [ $? != 0 ] && exit 1
    else
        echo "Invalid component=$comp"
        exit 101
    fi
}

## 1> ECL/ECL >> PS_REL_ -> $bldtop/Platforms/PS_REL/$PS_REL
PS_REL=$(sed -n "s/^ECL_PS_REL=//gp" ECL/ECL)
syncForPart "$PS_REL" "$bldtop/Platforms/PS_REL/$PS_REL"

## Step 2> PS_REL >> PS_LFS_REL -> $bldtop/Platforms/LINUX/$PS_LFS_REL
PS_LFS_REL=$(sed -n "s/^LFS_REL=//gp" "$bldtop/Platforms/PS_REL/$PS_REL/BTS_PS_versionfile.txt")
syncForPart "$PS_LFS_REL" "$bldtop/Platforms/LINUX/$PS_LFS_REL"

## Step 3> PS_LFS_REL >> SDK -> $bldtop/SDK/$PS_LFS_SDK
PS_LFS_SDK=$(readlink "$bldtop/Platforms/LINUX/$PS_LFS_REL/sdk" | awk -F "/" '{print $NF}')
syncForPart "$PS_LFS_SDK" "$bldtop/Platforms/SDK/$PS_LFS_SDK"

## Step 4> $bldtop/Platforms/SDK/$PS_LFS_SDK (just a link)

## Step 5> PS_REL >> OSE_CK -> $bldtop/Platforms/OSE/$OSE_CK
OSE_CK=$(sed -n "s/^OSE_CK=//gp" "$bldtop/Platforms/PS_REL/$PS_REL/BTS_PS_versionfile.txt")
syncForPart "$OSE_CK" "$bldtop/Platforms/OSE/$OSE_CK"

## Step 6> TOOLSET >> $bldtop/Tools/TOOLSET/$TOOLSET
TOOLSET=$(sed -n "s/^ECL_TOOLSET=//gp" ECL/ECL)
syncForPart "$TOOLSET" "$bldtop/Tools/TOOLSET/$TOOLSET"

## Step 7> ISAR -- How to generate ISAR_SRC tag id?

## Step 8> SACKS -- How to locate and generate LTEENV tag?
#       APPLENV -> $bldtop/Sacks/COMMON_APPL_ENV/$APPLENV
#       GLOBALENV -> $bldtop/Sacks/GLOBAL_ENV/$GLOBALENV

APPLENV=$(sed -n "s/^ECL_COMMON_APPL_ENV=//gp" ECL/ECL)
syncForPart "$APPLENV" "$bldtop/Sacks/COMMON_APPL_ENV/$APPLENV"

GLOBALENV=$(sed -n "s/^ECL_GLOBAL_ENV=//gp" ECL/ECL)
syncForPart "$GLOBALENV" "$bldtop/Sacks/GLOBAL_ENV/$GLOBALENV"

