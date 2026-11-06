#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd with an empty command argument should fail" {
    CQFD_COMPAT=5 run cqfd ""
    assert_failure
}

@test "run cqfd with an unknown command argument should fail" {
    CQFD_COMPAT=5 run cqfd invalid_arg_should_fail
    assert_failure
}
