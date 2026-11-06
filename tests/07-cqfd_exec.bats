#!/usr/bin/env bats
#
# validate the behavior of exec command

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
}

@test "run cqfd exec without argument should fail" {
    run cqfd exec
    assert_failure
}

@test "run cqfd exec with arguments should pass" {
    run cqfd exec true
    assert_success
}

@test "run cqfd exec should return same status" {
    run cqfd exec exit 10
    assert_failure 10
}

@test "run cqfd exec should preserve the arguments" {
    # shellcheck disable=SC2016
    run cqfd exec /bin/sh -c 'printf "0=$0,*=$*,#=$#"' zero one two three
    assert_success
    assert_line "0=zero,*=one two three,#=3"
}

@test "run cqfd exec with option --release should generate cqfd-test.tar.xz tarball archive by default" {
    cat .cqfdrc.orig - <<EOF2 >.cqfdrc
files="exec"
EOF2

    run cqfd --release exec touch exec
    assert_success
    run tar tf cqfd-test.tar.xz
    assert_success
    assert_line "exec"

    # cleanup
    rm cqfd-test.tar.xz exec
}
