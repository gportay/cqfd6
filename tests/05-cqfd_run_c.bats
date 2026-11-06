#!/usr/bin/env bats
#
# validate the behavior of run -c command

teardown_file() {
    # cleanup
    make clean
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd run -c without argument should fail" {
    run cqfd run -c
    assert_failure
}

@test "run cqfd run -c with argument should concatenate to command string" {
    run cqfd run -c --debug
    assert_success
    assert_line "Successfully remade target file 'build'."
}
