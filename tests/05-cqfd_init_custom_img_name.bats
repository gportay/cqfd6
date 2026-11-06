#!/usr/bin/env bats
#
# validate the behavior of custom_img_name

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig

    cp -f .cqfd/docker/Dockerfile.init_custom_image .cqfd/docker/Dockerfile
    cp -f cqfdrc-custom_image .cqfdrc
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

    read -r -a cqfd_docker <<<"${CQFD_DOCKER:-docker}"
    if [ "$CQFD_RUN_WITH_SUDO" = true ]; then
        cqfd_docker=(sudo "${cqfd_docker[@]}")
    fi
}

# $1: the custom image name to set in custom_img_name (removed if it exists)
set_custom_img_name() {
    sed -e "s!^custom_img_name=.*\$!custom_img_name='$1'!" -i .cqfdrc
    if "${cqfd_docker[@]}" inspect "$1" &>/dev/null; then
        "${cqfd_docker[@]}" rmi "$1"
    fi
}

@test "run cqfd should pull image set in custom_img_name from remote registry" {
    set_custom_img_name "ubuntu:16.04"

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 16.04(.[[:digit:]]+)? LTS\"$"
}

@test "run cqfd should fail to pull inexistent image set in custom_img_name from remote registry" {
    custom_img_name="cqfd_test_custom_image_$RANDOM$RANDOM"
    set_custom_img_name "$custom_img_name"

    run cqfd
    assert_failure

    run "${cqfd_docker[@]}" inspect "$custom_img_name"
    assert_failure
}

@test "run cqfd init should create image set in custom_img_name from Dockerfile" {
    custom_img_name="cqfd_test_custom_image_$RANDOM$RANDOM"
    set_custom_img_name "$custom_img_name"

    run cqfd init
    assert_success

    run "${cqfd_docker[@]}" inspect "$custom_img_name"
    assert_success
}

@test "run cqfd should run created image custom_img_name from local registry" {
    custom_img_name="$(sed -n -e "s!^custom_img_name='\(.*\)'\$!\1!p" .cqfdrc)"

    run cqfd
    assert_success
    assert_line --regexp "^PRETTY_NAME=\"Ubuntu 24.04(.[[:digit:]]+)? LTS\"$"

    # cleanup
    "${cqfd_docker[@]}" rmi "$custom_img_name"
}
