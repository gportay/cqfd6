#!/usr/bin/env bats
#
# validate the behavior of deinit command

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

@test "run cqfd deinit with a .cqfdrc file should pass" {
    run cqfd deinit
    assert_success
}

@test "run cqfd deinit with a nonexistent Dockerfile should fail" {
    sed -e "s/\[build\]/[build]\ndistro='thisshouldfail'/" .cqfdrc.orig >.cqfdrc

    run cqfd deinit
    assert_failure
}

@test "run cqfd deinit with another Dockerfile should pass" {
    sed -e "s/\[build\]/[build]\ndistro='fedora'/" .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success

    run cqfd deinit
    assert_success
}

@test "run cqfd deinit with an already deinit'ed image should fail" {
    run cqfd deinit
    assert_failure
}
