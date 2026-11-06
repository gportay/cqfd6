#!/usr/bin/env bats
#
# validate the .cqfdrc syntax

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
    rm -f foo bar bar.inc
}

@test "run cqfd with no project section in cqfdrc file should fail" {
    echo -n "" >.cqfdrc

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing project section!"
}

@test "run cqfd with no name property set in project section in cqfdrc file should fail" {
    echo "[project]" >.cqfdrc

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing project.org or project.name properties!"
}

@test "run cqfd with no org property set in project section in cqfdrc file should fail" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
EOF2

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing project.org or project.name properties!"
}

@test "run cqfd with no build section in cqfdrc file should fail" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
EOF2

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing build section!"
}

@test "run cqfd with no command property set in build section in cqfdrc file should fail" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
[build]
EOF2

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing or empty build.command property!"
}

@test "run cqfd run with argument and required properties set in project and build sections in cqfdrc file should pass" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
[build]
EOF2

    run cqfd run true
    assert_success
}

@test "run cqfd run -c with no command property set in build section in cqfdrc should pass" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
[build]
EOF2

    run cqfd run -c true
    assert_success
    assert_line "cqfd: warning: .cqfdrc: Missing or empty build.command property!"
}

@test "run cqfd run without argument and with command property set in build section in cqfdrc should pass" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
[build]
command=true
EOF2

    run cqfd run
    assert_success
}

@test "run cqfd run -c with command property set in build section in cqfdrc should pass" {
    cat <<EOF2 >.cqfdrc
[project]
name=test
org=cqfd
[build]
command=true
EOF2

    run cqfd run -c true
    assert_success
    refute_output --partial "cqfd: warning: .cqfdrc: Missing or empty build.command property!"
}

@test "run cqfd with tabulation before property assignment in cqfdrc file should pass" {
    printf "foo\t=bar\n" >>.cqfdrc

    run cqfd
    assert_success
}

@test "run cqfd with tabulation after property assignment in cqfdrc file should pass" {
    printf "foo=\tbar\n" >>.cqfdrc

    run cqfd
    assert_success
}

@test "run cqfd with whitespace before property assignment in cqfdrc file should pass" {
    echo "foo =bar" >>.cqfdrc

    run cqfd
    assert_success
}

@test "run cqfd with whitespace after property assignment in cqfdrc file should pass" {
    echo "foo= bar" >>.cqfdrc

    run cqfd
    assert_success
}

@test "run cqfd with ini-style comment in command in cqfdrc file should not strip semicolons in command" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='true; echo \"; works!\"'," -i .cqfdrc

    run cqfd
    assert_success
    assert_line "; works!"
}

@test "run cqfd with shell-style comment in command in cqfdrcfile should not strip hash in command" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='true; echo \"# works!\"'," -i .cqfdrc

    run cqfd
    assert_success
    assert_line "# works!"
}

@test "run cqfd with multilined command in cqfdrc file should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command=\"echo \\\\\\
	foo=bar \\\\\\
	baz=quux\"," -i .cqfdrc

    run cqfd
    assert_success
    assert_line "foo=bar baz=quux"
}

@test "run cqfd with ;-commented project section cqfdrc file should fail" {
    sed -e "/\[project\]/,/^$/s,^,; ," -i .cqfdrc

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing project section!"
}

@test "run cqfd with #-commented build section cqfdrc file should fail" {
    sed -e "/\[build\]/,/^$/s,^,# ," -i .cqfdrc

    run cqfd
    assert_failure 1
    assert_line "cqfd: fatal: .cqfdrc: Missing build section!"
}

@test "run cqfd with include empty file in cqfdrc file should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command=\"make foo\"," -i .cqfdrc
    echo "include /dev/null" >>.cqfdrc

    run cqfd
    assert_success
    [ -e foo ]
}

@test "run cqfd with include file in cqfdrc file should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command=\"make foo\"," -i .cqfdrc
    echo "include /dev/null" >>.cqfdrc
    cat <<EOF2 >bar.inc
[build]
command="make bar"
EOF2
    echo "include bar.inc" >>.cqfdrc

    run cqfd
    assert_success
    [ -e bar ]
}

@test "run cqfd with duplicate include file in cqfdrc file should pass" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command=\"make foo\"," -i .cqfdrc
    echo "include /dev/null" >>.cqfdrc
    cat <<EOF2 >bar.inc
[build]
command="make bar"
EOF2
    echo "include bar.inc" >>.cqfdrc
    echo "include bar.inc" >>.cqfdrc

    run cqfd
    assert_success
    [ -e bar ]
}

@test "run cqfd with recursive include file in cqfdrc file should fail" {
    sed -e "/\[build\]/,/^$/s,^command=.*$,command=\"make foo\"," -i .cqfdrc
    echo "include /dev/null" >>.cqfdrc
    cat <<EOF2 >bar.inc
[build]
command="make bar"
include bar.inc
EOF2
    echo "include bar.inc" >>.cqfdrc
    echo "include bar.inc" >>.cqfdrc

    run cqfd
    assert_failure
}
