#!/usr/bin/env bats
#
# validate the behavior of cqfd with alternate file and directory, from a subdirectory

setup_file() {
    export extdir="external/dir"

    sed -e "/\[build\]/,/^$/s,^command=.*$,command='pwd'," .cqfdrc >.cqfdrc.new
    mkdir -p "$extdir"

    # move .cqfd and .cqfdrc
    mv .cqfd "$extdir/cqfd"
    mv .cqfdrc "$extdir/cqfdrc.orig"
    mv .cqfdrc.new "$extdir/cqfdrc"
}

teardown_file() {
    # moveback .cqfdrc and .cqfd
    mv "$extdir/cqfdrc.orig" .cqfdrc
    mv "$extdir/cqfd" .cqfd
    rm -f "$extdir/cqfdrc"

    # cleanup
    rmdir -p "$extdir"
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd from a subdirectory with options -f and -d using path relative to subdirectory should pass" {
    run cqfd -C "$extdir" -d cqfd -f cqfdrc
    assert_success
    assert_line "$PWD/$extdir"
}

@test "run cqfd with options -f and -d using relative path should pass" {
    run cqfd -d "$extdir/cqfd" -f "$extdir/cqfdrc"
    assert_success
    assert_line "$PWD"
}

@test "run cqfd with options -f and -d using absolute path should pass" {
    run cqfd -d "$PWD/$extdir/cqfd" -f "$PWD/$extdir/cqfdrc"
    assert_success
    assert_line "$PWD"
}

@test "run cqfd from a subdirectory with environments CQFDRC_FILE and CQFD_DIR using relative path to subdirectory should pass" {
    CQFD_DIR=cqfd CQFDRC_FILE=cqfdrc run cqfd -C "$extdir"
    assert_success
    assert_line "$PWD/$extdir"
}

@test "run cqfd with environments CQFDRC_FILE and CQFD_DIR using relative path should pass" {
    CQFD_DIR="$extdir/cqfd" CQFDRC_FILE="$extdir/cqfdrc" run cqfd
    assert_success
    assert_line "$PWD"
}

@test "run cqfd from a subdirectory with environments CQFDRC_FILE and CQFD_DIR using absolute path should pass" {
    CQFD_DIR="$PWD/$extdir/cqfd" CQFDRC_FILE="$PWD/$extdir/cqfdrc" run cqfd
    assert_success
    assert_line "$PWD"
}
