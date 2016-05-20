#!/usr/bin/env bats

@test "dummy bootstrap suites" {
    run bats "dummy.bats"
    [ $status -eq 0 ]
}

@test "check parse sct info for dcs test cases" {
    run bats "parseSCTInfoForDCS.bats"
    [ $status -eq 0 ]
}

@test "check clocSrc for sub domains" {
    run bats "clocSrc.bats"
    [ $status -eq 0 ]
}
