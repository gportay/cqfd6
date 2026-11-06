#!/usr/bin/env bats
#
# validate the behavior of running docker multi-platform image

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
    cp -f .cqfd/docker/Dockerfile.platform .cqfd/docker/Dockerfile
    cp -f cqfdrc-platform .cqfdrc
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd with FROM --platform=linux/arm64 in Dockerfile should run linux/arm64 docker platform" {
    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line "aarch64"
}
