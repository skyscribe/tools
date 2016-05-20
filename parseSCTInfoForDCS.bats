#!/usr/bin/env bats
testWd="$(pwd)/test-files/parseSCTInfoForDCS"
repFile="$testWd/sct_info.csv"

setup(){
    cd $testWd
    rm -f $repFile
}

teradown(){
    rm -f $repFile
}

@test "should parse successfully for clean parsing" {
    run parseSCTInfoForDCS.sh
    [ "$status" -eq 0 ]
    [ -f $repFile ]
}

@test "should not generate report if legacy one exists" {
    echo "dummytest" > $repFile
    run parseSCTInfoForDCS.sh
    [ "$status" -eq 0 ]
    lines=$(head -1 $repFile)
    [ "$lines" = "dummytest" ]
}

@test "should take passed directory as working directory" {
    run parseSCTInfoForDCS.sh $testWd
    [ "$status" -eq 0 ]
    [ -f $repFile ]
}

@test "should have one single header for generated report" {
    run parseSCTInfoForDCS.sh
    headerCnt=$(grep -c "topology,type" $repFile) || echo "-"
    [ $headerCnt -eq 1 ] 
}
