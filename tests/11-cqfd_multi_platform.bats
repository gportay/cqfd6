#!/usr/bin/env bats
#
# validate the behavior of running docker multi-platform image

native_machine=x86_64
cross_machine=aarch64
native_platform=linux/amd64
cross_platform=linux/arm64
if [ "$(uname -m)" = "aarch64" ]; then
    native_machine=aarch64
    cross_machine=x86_64
    native_platform=linux/arm64
    cross_platform=linux/amd64
fi

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
    cp -f .cqfd/docker/Dockerfile.multi_platform .cqfd/docker/Dockerfile
    cp -f cqfdrc-multi_platform .cqfdrc
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

@test "run cqfd without environment CQFD_PLATFORM and option --platform should run native docker platform ($native_platform = $native_machine)" {
    run cqfd init
    assert_success

    run cqfd
    assert_success
    assert_line "$native_machine"
}

@test "run cqfd with environment CQFD_PLATFORM should run native docker platform ($native_platform = $native_machine)" {
    CQFD_PLATFORM="$native_platform" run cqfd init
    assert_success

    CQFD_PLATFORM="$native_platform" run cqfd
    assert_success
    assert_line "$native_machine"
}

@test "run cqfd with option --platform should run native docker platform ($native_platform = $native_machine)" {
    run cqfd --platform "$native_platform" init
    assert_success

    run cqfd --platform "$native_platform"
    assert_success
    assert_line "$native_machine"
}

@test "run cqfd with environment CQFD_PLATFORM should run cross docker platform ($cross_platform = $cross_machine)" {
    CQFD_PLATFORM="$cross_platform" run cqfd init
    assert_success

    CQFD_PLATFORM="$cross_platform" run cqfd
    assert_success
    assert_line "$cross_machine"
}

@test "run cqfd with option --platform should run cross docker platform ($cross_platform = $cross_machine)" {
    run cqfd --platform "$cross_platform" init
    assert_success

    run cqfd --platform "$cross_platform"
    assert_success
    assert_line "$cross_machine"
}

@test "run cqfd docker platform helpers should run associated docker platform (linux/amd64, linux/aarch64)" {
    run linux-amd64-cqfd
    assert_success
    assert_line "x86_64"

    run linux-arm64-cqfd
    assert_success
    assert_line "aarch64"
}
