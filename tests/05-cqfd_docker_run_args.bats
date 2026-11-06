#!/usr/bin/env bats
#
# validate the behavior of cqfd with docker extra run arguments

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo \"\$FOO \$BAR\"'," -i .cqfdrc
    cp -f .cqfdrc .cqfdrc.test
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    rm -f .cqfdrc.test
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

teardown() {
    cp -f .cqfdrc.test .cqfdrc
}

@test "run cqfd without --env in CQFD_EXTRA_RUN_ARGS and docker_run_args should not set environment variables" {
    run cqfd
    assert_success
    assert_line " "
}

@test "run cqfd with --env in CQFD_EXTRA_RUN_ARGS should set environment variables" {
    CQFD_EXTRA_RUN_ARGS="--env FOO=foo --env BAR=bar" run cqfd
    assert_success
    assert_line "foo bar"
}

@test "run cqfd with --env containing whitespaces in CQFD_EXTRA_RUN_ARGS should set environment variables and preserve whitespaces" {
    CQFD_EXTRA_RUN_ARGS="--env FOO=foo\ foobar --env BAR=bar" run cqfd
    assert_success
    assert_line "foo foobar bar"
}

@test "run cqfd with --env in docker_run_args should set environment variables" {
    sed -e '/\[build\]/adocker_run_args="--env FOO=foo --env BAR=bar"' -i .cqfdrc

    run cqfd
    assert_success
    assert_line "foo bar"
}

@test "run cqfd with --env containing whitespaces in docker_run_args should set environment variables and preserve whitespaces" {
    sed -e '/\[build\]/adocker_run_args="--env FOO=foo\\ foobar --env BAR=bar"' -i .cqfdrc

    run cqfd
    assert_success
    assert_line "foo foobar bar"
}
