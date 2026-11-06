#!/usr/bin/env bats
#
# validate the behavior of help command

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd help should exit success" {
    run cqfd help
    assert_success
}

@test "run cqfd help should produce an usage output" {
    run cqfd help
    assert_line --regexp "^Usage:"
    assert_line --regexp "^Options:"
    assert_line --regexp "^Commands:"
}
