#!/usr/bin/env bats
#
# validate the behavior of init with docker extra pull arguments

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig

    cp -f cqfdrc-image .cqfdrc
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd init with CQFD_EXTRA_PULL_ARGS should pass" {
    CQFD_EXTRA_BUILD_ARGS="--disable-content-trust=false" run cqfd init
    assert_success
}

@test "run cqfd with docker_pull_args should pass" {
    sed -e '/\[build\]/adocker_build_args="--disable-content-trust=false"' -i .cqfdrc

    run cqfd init
    assert_success
}
