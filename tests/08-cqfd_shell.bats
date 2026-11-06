#!/usr/bin/env bats
#
# validate the behavior of shell command

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

@test "run cqfd shell without stdin should pass" {
    run cqfd shell </dev/null
    assert_success
}

@test "run cqfd shell should read commands from stdin" {
    run cqfd shell <<<"tty"
    assert_failure
    assert_line "not a tty"
}

@test "run cqfd shell should use program set in shell" {
    sed -e '/\[build\]/ashell="/bin/bash"' .cqfdrc.orig >.cqfdrc

    # shellcheck disable=SC2016
    run cqfd shell <<<'printf "$0"'
    assert_success
    assert_line "/bin/bash"
}

@test "run cqfd shell should preserve the arguments" {
    # shellcheck disable=SC2016
    run cqfd shell -c 'printf "0=$0,*=$*,#=$#"' zero one two three
    assert_success
    assert_line "0=zero,*=one two three,#=3"
}

@test "run cqfd shell should run shell script" {
    run cqfd shell ./whereami.sh
    assert_success
    assert_line --regexp "^Ubuntu .* LTS$"
}

@test "run cqfd bash should run shell script" {
    run cqfd bash ./whereami.sh
    assert_success
    assert_line --regexp "^Ubuntu .* LTS$"
}

@test "run cqfd shell as a shell interpreter should pass" {
    # shellcheck disable=SC2030
    PATH="$BATS_SUITE_TMPDIR/.local/bin:$PATH"
    run ./whereami.sh
    assert_success
    assert_line --regexp "^Ubuntu .* LTS$"
}

@test "run cqfd shell as a SHELL= program should pass" {
    if ! command -v make; then
        skip "make: command not found"
    fi

    # shellcheck disable=SC2031
    PATH="$BATS_SUITE_TMPDIR/.local/bin:$PATH" run make whereami
    assert_success
    assert_line --regexp "^Ubuntu .* LTS$"
}

@test "run cqfd shell with option --release should generate cqfd-test.tar.xz tarball archive by default" {
    cat .cqfdrc.orig - <<EOF2 >.cqfdrc
files="shell"
EOF2

    run cqfd --release shell -c "touch shell"
    assert_success
    run tar tf cqfd-test.tar.xz
    assert_success
    assert_line "shell"

    # cleanup
    rm cqfd-test.tar.xz shell
}
