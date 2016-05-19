#!/usr/bin/env bats

testWd=~/srcs/mfo/dcs
repFile="$testWd/sct_info.csv"

@test "should parse successfully for clean parsing" {
    cd $testWd
    rm -f $repFile
    run parseSCTInfoForDCS.sh
    [ "$status" -eq 0 ]
    [ -f $repFile ]
}

@test "should not generate report if legacy one exists" {
    cd $testWd
    echo "dummytest" > $repFile
    run parseSCTInfoForDCS.sh
    [ "$status" -eq 0 ]
    lines=$(head -1 $repFile)
    [ "$lines" = "dummytest" ]
    rm $repFile
}

@test "should take passed directory as working directory" {
    run parseSCTInfoForDCS.sh $testWd
    [ "$status" -eq 0 ]
    [ -f $repFile ]
}
