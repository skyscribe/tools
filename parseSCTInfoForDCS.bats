#!/usr/bin/env bats
testWd="$(pwd)/test-files/parseSCTInfoForDCS"
repFile="$testWd/sct_info.csv"

setup(){
    cd $testWd
    rm -f $repFile
}

teradown(){
    echo "do teardown now..."
    rm -f $repFile
}

@test "should parse successfully for clean parsing" {
    run parseSCTInfoForDCS.sh
    [ "$status" -eq 0 ]

    [ -f $repFile ]
    invalidCnt=$(grep -c "L11," $repFile)  || echo "-"
    [ $invalidCnt -eq 0 ]

    #for T222_L_3X20MHz_FSIH_FBIH_3FZFI.ttcn3
    match=$(grep -c "T222,L,,,3X20Mhz,FSIH_FBIH,3FZFI" $repFile) || cp $repFile $repFile.bk
    [ $match -eq 1 ]

    # check pattern T111_20MHz_8TX8RX_FSIP_FBIP_3FZHM.ttcn3
    match=$(grep -c "T111,,,8TX8RX,20MHz,FSIP_FBIP,3FZHM" $repFile) || cp $repFile $repFile.bk
    [ $match -eq 1 ]

    # check T11_20MHz_12TXRX_CPRI_FSIH_10FZND_SuperCell_DualMode.ttcn3
    match=$(grep -c "T11,,,12TXRX,20MHz,FSIH,10FZND" $repFile) || cp $repFile $repFile.bk
    [ $match -eq 1 ]

    # check T333_20MHz_8T8R_FSIH_3FZHM_9G_IQC_Configuration.ttcn3 
    match=$(grep -c "T333,,,8T8R,20MHz,FSIH,3FZHM" $repFile) || cp $repFile $repFile.bk
    [ $match -eq 1 ]
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
    headerCnt=$(grep -c "Topology,Type" $repFile) || echo "-"
    [ $headerCnt -eq 1 ] 
}
