#!/usr/bin/env bats
#
# validate the behavior of cqfd with build flavors

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    sed -e "/\[foo\]/,/^$/s,^command=.*$,command='grep ^NAME /etc/os-release'," -i .cqfdrc
    sed -e "s/\[foo\]/[foo]\ndistro='fedora'/" -i .cqfdrc
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

@test "run cqfd with build flavor should pass" {
    run cqfd -b foo
    assert_success
}

@test "run cqfd with build flavor should pass and use the flavor distro" {
    run cqfd -b foo
    assert_success
    assert_line "NAME=\"Fedora Linux\""
}

@test "run cqfdwith nonexistent build flavor should fail" {
    run cqfd -b foobar
    assert_failure
}

@test "run cqfd with nonexistent build flavor should fail" {
    run cqfd -b foobar
    assert_failure
}
