#!/usr/bin/env bats
#
# validate the behavior of run with working directory

setup_file() {
    mkdir -p workingdir

    # move .cqfd and .cqfdrc
    mv .cqfd workingdir/.cqfd
    mv .cqfdrc workingdir/.cqfdrc

    # backup .cqfdrc
    mv workingdir/.cqfdrc workingdir/.cqfdrc.orig

    sed -e "/\[build\]/,/^$/s,^command=.*$,command='stat --printf '%u:' . ..'," workingdir/.cqfdrc.orig >workingdir/.cqfdrc
}

teardown_file() {
    # restore .cqfdrc
    mv -f workingdir/.cqfdrc.orig workingdir/.cqfdrc

    # moveback .cqfdrc and .cqfd
    mv workingdir/.cqfdrc .cqfdrc
    mv workingdir/.cqfd .cqfd

    # cleanup
    rmdir workingdir
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
    cd workingdir || return 1
}

@test "run cqfd without --working-directory should own working directory and should not own its parent directory" {
    run cqfd
    assert_success
    assert_line "$UID:0:"
}

@test "run cqfd with --working-directory set to inexistent directory should fail" {
    run cqfd -w "nonexistentdir"
    assert_failure
}

@test "run cqfd with --working-directory set to parent directory should own parent directory and should not own its parent directory" {
    run cqfd -w ".."
    assert_success
    assert_line "$UID:0:"
}

@test "run cqfd with --working-directory set to parent directory using absolute path should own parent directory and should not own its parent directory" {
    run cqfd -w "$PWD/.."
    assert_success
    assert_line "$UID:0:"
}

@test "run cqfd with CQFD_WORKDIR set to inexistent directory should fail" {
    CQFD_WORKDIR="nonexistentdir" run cqfd
    assert_failure
}

@test "run cqfd with CQFD_WORKDIR set to parent directory should own parent directory and should not own its parent directory" {
    CQFD_WORKDIR=".." run cqfd
    assert_success
    assert_line "$UID:0:"
}

@test "run cqfd with CQFD_WORKDIR set to parent directory using absolute path should own parent directory and should not own its parent directory" {
    CQFD_WORKDIR="$PWD/.." run cqfd
    assert_success
    assert_line "$UID:0:"
}
