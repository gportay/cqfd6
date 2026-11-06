#!/usr/bin/env bats
#
# validate the behavior with skelton bring up

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd init without an .cqfd directory should fail" {
    run cqfd init
    assert_failure
}

@test "run cqfd ls without a .cqfdrc file should fail" {
    mv cqfd .cqfd

    run cqfd ls
    assert_failure
}

@test "run cqfd gc without a .cqfdrc file should fail" {
    run cqfd gc
    assert_failure
}

@test "run cqfd init without a .cqfdrc file should fail" {
    run cqfd init
    assert_failure

    cp cqfdrc-test .cqfdrc
}
