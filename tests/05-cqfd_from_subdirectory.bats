#!/usr/bin/env bats
#
# validate the behavior of cqfd from subdirectory

setup_file() {
    export subdir="dir with space/b/c/d/e"
    mkdir -p "$subdir"
}

teardown_file() {
    # moveback .cqfdrc, .cqfd and Makefile
    if [ -e "$subdir/.cqfdrc" ]; then
        mv "$subdir/.cqfdrc" "$subdir/.cqfd" "$subdir/Makefile" .
    fi

    # cleanup
    rmdir -p "$subdir"
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd from project subdirectory containing whitespaces should pass" {
    cp -f .cqfdrc .cqfdrc.orig
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='pwd'," .cqfdrc.orig >.cqfdrc
    cd "$subdir"

    run cqfd
    cd "$OLDPWD"
    mv -f .cqfdrc.orig .cqfdrc
    assert_success
    assert_line "$PWD/$subdir"
}

@test "run cqfd from project directory containing whitespaces should pass" {
    # move Makefile, .cqfd and .cqfdrc
    mv Makefile .cqfd .cqfdrc "$subdir"
    cd "$subdir"

    run cqfd
    assert_success
    assert [ -f a/cqfd_a.txt ]

    # cleanup
    make clean
}
