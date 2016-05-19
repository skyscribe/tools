#!/usr/bin/env bats

@test "A dummy bats to bootstrap travis-ci" {
    run echo "ok"
    [ $status -eq 0 ]
}
