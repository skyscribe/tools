#!/usr/bin/env bats

@test "Couting a src folder shall list its sub domain statistics" {
    run clocSrc.sh ~/srcs/cprih/src
    [ $status -eq 0 ]
    records=${#lines[@]}
    [ $records -eq 12 ]
}
