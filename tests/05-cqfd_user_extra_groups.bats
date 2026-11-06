#!/usr/bin/env bats
#
# validate the behavior of cqfd with user_extra_groups

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='groups'," .cqfdrc.orig >.cqfdrc
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd with groups in user_extra_groups should execute as groups" {
    # shellcheck disable=SC2154
    if [ "$USER" = "runner" ] || [ "${cqfd_docker##* }" = "podman" ]; then
        skip "unsupported with GitHub runner or podman"
    fi

    sed -e '/\[build\]/auser_extra_groups="docker newgroup:12345"' -i .cqfdrc

    run cqfd
    assert_success
    assert_line --regexp "(docker.*newgroup|newgroup.*docker)"
}
