#!/usr/bin/env bats
#
# validate the allocation of pty and the behavior of redirections

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
    sed -e "/\[build\]/,/^$/s/^command=.*$/command='tty || true'/" .cqfdrc.orig >.cqfdrc
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
}

# the tests below require a terminal: script(1) allocates a pty to attach
# stdin and stdout of cqfd to a tty as bats does not.
@test "run cqfd with stdin and stdout attached to tty should allocate a pty" {
    if ! command -v script; then
        skip "script: command not found"
    fi

    run script -qec "cqfd" /dev/null
    assert_success
    assert_output --regexp "/dev/pts/[[:digit:]]+"
}

@test "run cqfd with stdin attached to tty and stdout piped should not allocate a pty" {
    if ! command -v script; then
        skip "script: command not found"
    fi

    run script -qec "cqfd | cat" /dev/null
    assert_success
    assert_output --partial "not a tty"
}

@test "run cqfd with stdin redirected to /dev/null should not allocate a pty" {
    run cqfd </dev/null
    assert_success
    assert_line "not a tty"
}

@test "run cqfd with stdout piped should not allocate a pty" {
    run cqfd
    assert_success
    assert_line "not a tty"
}

@test "run cqfd with allocated pty should redirect stdout and stderr to same endpoint" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo stdout \&\& echo stderr >\&2'," -i .cqfdrc

    run cqfd >out
    assert_success

    # cleanup
    rm out
}

@test "run cqfd without allocated pty should redirect stdout and stderr to distinct endpoints" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo stdout \&\& echo stderr >\&2'," -i .cqfdrc

    cqfd >out 2>err
    run grep '^stdout$' out
    assert_success
    run grep '^stderr$' err
    assert_success

    # cleanup
    rm out err
}
