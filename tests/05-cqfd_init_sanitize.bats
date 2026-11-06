#!/usr/bin/env bats
#
# validate the sanitization of image name

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup

    read -r -a cqfd_docker <<<"${CQFD_DOCKER:-docker}"
    if [ "$CQFD_RUN_WITH_SUDO" = true ]; then
        cqfd_docker=(sudo "${cqfd_docker[@]}")
    fi
}

@test "run cqfd init with invalid character in USER should create image" {
    dh="$(sha256sum .cqfd/docker/Dockerfile | cut -b 1-7)"
    image="cqfd-user_invalid-cqfd-test-linux_amd64-docker"
    if uname -m | grep -q "^aarch64$"; then
        image="cqfd-user_invalid-cqfd-test-linux_arm64-docker"
    fi
    if "${cqfd_docker[@]}" inspect "$image:$dh" &>/dev/null; then
        "${cqfd_docker[@]}" rmi "$image:$dh"
    fi

    USER="user@invalid" run cqfd init
    assert_success

    run "${cqfd_docker[@]}" inspect "$image:$dh"
    assert_success

    # cleanup
    "${cqfd_docker[@]}" rmi "$image:$dh"
}

@test "run cqfd init with invalid character in org should create image" {
    sed -e "s!^org=.*\$!org='savoirfairelinux@invalid'!" .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
}

@test "run cqfd init with invalid character in name should create image" {
    sed -e "s!^name=.*\$!name='test@invalid'!" .cqfdrc.orig >.cqfdrc

    run cqfd init
    assert_success
}
