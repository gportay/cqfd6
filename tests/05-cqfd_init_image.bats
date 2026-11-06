#!/usr/bin/env bats
#
# validate the behavior of cqfd image

setup_file() {
    mv .cqfd .cqfd.orig
    cp -f .cqfdrc .cqfdrc.orig

    cp -f cqfdrc-image .cqfdrc
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    mv .cqfd.orig .cqfd

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup

    read -r -a cqfd_docker <<<"${CQFD_DOCKER:-docker}"
    if [ "$CQFD_RUN_WITH_SUDO" = true ]; then
        cqfd_docker=(sudo "${cqfd_docker[@]}")
    fi
}

@test "run cqfd init should pull image set in image from remote registry" {
    image="ubuntu:16.04"
    if "${cqfd_docker[@]}" inspect "$image" &>/dev/null; then
        "${cqfd_docker[@]}" rmi "$image"
    fi

    run cqfd init
    assert_success

    run "${cqfd_docker[@]}" inspect "$image"
    assert_success
}

@test "run cqfd should run pulled image set in image from local registry" {
    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}
