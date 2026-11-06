#!/usr/bin/env bats
#
# validate the behavior of version command

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd version should exit success" {
    run cqfd version
    assert_success
}

@test "run cqfd version should produce a version output" {
    run cqfd version
    assert_line --regexp "^[0-9.]+(-[a-z]+)?\$"
}
