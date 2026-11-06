#!/usr/bin/env bats
#
# validate the behavior of init with docker extra build arguments

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig

    cp -f .cqfd/docker/Dockerfile.init_extra_env .cqfd/docker/Dockerfile
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

@test "run cqfd init with ARG in Dockerfile and without --build-arg in CQFD_EXTRA_BUILD_ARGS and docker_build_args should fail" {
    run cqfd init
    assert_failure
}

@test "run cqfd init with ARG in Dockerfile and with --build-arg in CQFD_EXTRA_BUILD_ARGS should pass" {
    CQFD_EXTRA_BUILD_ARGS="--build-arg FOO=foo --no-cache" run cqfd init
    assert_success
}

@test "run cqfd init with ARG in Dockerfile and with --build-arg in docker_build_args should pass" {
    sed -e '/\[build\]/adocker_build_args="--build-arg FOO=foo --no-cache"' .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
}
