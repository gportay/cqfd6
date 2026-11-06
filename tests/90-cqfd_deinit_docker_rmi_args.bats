#!/usr/bin/env bats
#
# validate the behavior of deinit with docker extra rmi arguments

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
}

@test "run cqfd deinit with --force set in CQFD_EXTRA_RMI_ARGS should pass" {
    CQFD_EXTRA_RMI_ARGS="--force" run cqfd deinit
    assert_success
}

@test "run cqfd deinit with --force set in docker_rmi_args should pass" {
    sed -e '/\[build\]/adocker_rmi_args="--force"' .cqfdrc.orig >.cqfdrc

    run cqfd deinit
    assert_success
}
