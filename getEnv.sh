#!/bin/bash
source ~/bin/funcs.sh
bldtop=/build/ltesdkroot/
excludeFolder=~/bin/rsync-excludes/

## 1> ECL/ECL >> PS_REL_ -> $bldtop/Platforms/PS_REL/$PS_REL
PS_REL=`cat ECL/ECL| sed -n "s/^ECL_PS_REL=//gp"`
echo "Updating $PS_REL using rsync"
#syncFolder $bldtop/Platforms/PS_REL/$PS_REL ${excludeFolder}/ps.txt
syncFolder $bldtop/Platforms/PS_REL/$PS_REL
[ $? != 0 ] && exit 1

## Step 2> PS_REL >> PS_LFS_REL -> $bldtop/Platforms/LINUX/$PS_LFS_REL
PS_LFS_REL=`cat $bldtop/Platforms/PS_REL/$PS_REL/BTS_PS_versionfile.txt | sed -n  "s/^LFS_REL=//gp"`
echo "Updating $PS_LFS_REL using rsync"
#syncFolder $bldtop/Platforms/LINUX/$PS_LFS_REL ${excludeFolder}/ps_lfs.txt
syncFolder $bldtop/Platforms/LINUX/$PS_LFS_REL
[ $? != 0 ] && exit 1

## Step 3> PS_LFS_REL >> SDK -> $bldtop/SDK/$PS_LFS_SDK
PS_LFS_SDK=`readlink $bldtop/Platforms/LINUX/$PS_LFS_REL/sdk | awk -F "/" '{print $NF}'`
echo "Updating $PS_LFS_SDK using rsync"
#syncFolder $bldtop/SDK/$PS_LFS_SDK ${excludeFolder}/sdk.txt
syncFolder $bldtop/Platforms/SDK/$PS_LFS_SDK 
[ $? != 0 ] && exit 1

## Step 4> $bldtop/Platforms/SDK/$PS_LFS_SDK (just a link)

## Step 5> PS_REL >> OSE_CK -> $bldtop/Platforms/OSE/$OSE_CK
OSE_CK=`cat $bldtop/Platforms/PS_REL/$PS_REL/BTS_PS_versionfile.txt | sed -n  "s/^OSE_CK=//gp"`
echo "Updating $OSE_CK using rsync"
syncFolder $bldtop/Platforms/OSE/$OSE_CK

## Step 6> TOOLSET >> $bldtop/Tools/TOOLSET/$TOOLSET
TOOLSET=`cat ECL/ECL| sed -n "s/^ECL_TOOLSET=//gp"`
echo "Updating $TOOLSET using rsync"
syncFolder $bldtop/Tools/TOOLSET/$TOOLSET

## Step 7> ISAR -- How to generate ISAR_SRC tag id?

## Step 8> SACKS -- How to locate and generate LTEENV tag?
#       APPLENV -> $bldtop/Sacks/COMMON_APPL_ENV/$APPLENV
#       GLOBALENV -> $bldtop/Sacks/GLOBAL_ENV/$GLOBALENV

APPLENV=`cat ECL/ECL | sed -n "s/^ECL_COMMON_APPL_ENV=//gp"`
syncFolder $bldtop/Sacks/COMMON_APPL_ENV/$APPLENV
GLOBALENV=`cat ECL/ECL | sed -n "s/^ECL_GLOBAL_ENV=//gp"`
syncFolder $bldtop/Sacks/GLOBAL_ENV/$GLOBALENV

