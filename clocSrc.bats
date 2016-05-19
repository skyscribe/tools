#!/usr/bin/env bats

@test "Couting a src folder shall list its sub domain statistics" {
    run ./clocSrc.sh test-files/clocSrc/src/
    [ $status -eq 0 ]
    cnt=0
    for ln in "${lines[@]}";do
        if echo $ln | grep "|"; then
            cnt=$(echo $cnt + 1 | bc)
        fi
    done
    [ $cnt -eq 2 ]
}
