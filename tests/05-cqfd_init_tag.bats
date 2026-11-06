#!/usr/bin/env bats
#
# validate the behavior of cqfd tag

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc

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

    cp -f cqfdrc-tag .cqfdrc
    random="$RANDOM$RANDOM"
    # shellcheck disable=SC2001
    un="$(sed 's/[^0-9a-zA-Z\-]/_/g' <<<"$USER")"
}

@test "run cqfd init with tag should build templated image" {
    tag="%Un-%Po-%Pn-%Bd-%Dh-$random"
    sed -e "s!^tag=.*\$!tag='$tag'!" -i .cqfdrc
    dh="$(sha256sum .cqfd/docker/Dockerfile | cut -b 1-7)"
    image="cqfd-$un-$un-cqfd-test-docker-$dh-$random"
    if "${cqfd_docker[@]}" inspect "$image:$dh" &>/dev/null; then
        "${cqfd_docker[@]}" rmi "$image:$dh"
    fi

    run cqfd init
    assert_success

    run "${cqfd_docker[@]}" inspect "$image:$dh"
    assert_success

    # cleanup
    "${cqfd_docker[@]}" rmi "$image:$dh"
}

@test "run cqfd init with tag and distro should build templated image" {
    tag="%Un-%Po-%Pn-%Bd-%DH-$random"
    sed -e "s!^tag=.*\$!tag='$tag'!" -i .cqfdrc
    dh="$(sha256sum .cqfd/fedora/Dockerfile | cut -b 1-64)"
    image="cqfd-$un-$un-cqfd-test-fedora-$dh-$random"
    dh="$(sha256sum .cqfd/fedora/Dockerfile | cut -b 1-7)"
    if "${cqfd_docker[@]}" inspect "$image:$dh" &>/dev/null; then
        "${cqfd_docker[@]}" rmi "$image:$dh"
    fi
    sed -e "s/\[build\]/[build]\ndistro='fedora'/" -i .cqfdrc

    run cqfd init
    assert_success

    run "${cqfd_docker[@]}" inspect "$image:$dh"
    assert_success

    # cleanup
    "${cqfd_docker[@]}" rmi "$image:$dh"
}
