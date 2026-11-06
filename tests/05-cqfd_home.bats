#!/usr/bin/env bats
#
# validate the behavior of cqfd with home directory

setup_file() {
    cp -f .cqfdrc .cqfdrc.orig
    cp -f .cqfd/docker/Dockerfile .cqfd/docker/Dockerfile.orig
}

teardown_file() {
    mv -f .cqfdrc.orig .cqfdrc
    mv -f .cqfd/docker/Dockerfile.orig .cqfd/docker/Dockerfile

    # restore container
    cqfd init
}

setup() {
    load 'test_helper/common-setup'
    _common_setup

    read -r -a cqfd_docker <<<"${CQFD_DOCKER:-docker}"
    if [ "$CQFD_RUN_WITH_SUDO" = true ]; then
        cqfd_docker=(sudo "${cqfd_docker[@]}")
    fi
}

teardown() {
    cp -f .cqfdrc.orig .cqfdrc
}

@test "run cqfd should set user's HOME environment variable" {
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo \$HOME'," .cqfdrc.orig >.cqfdrc

    run cqfd
    assert_success
    assert_line "$HOME"
}

@test "run cqfd with --env in CQFD_EXTRA_RUN_ARGS including HOME should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    val2="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo -n \$FOO \$HOME'," .cqfdrc.orig >.cqfdrc

    CQFD_EXTRA_RUN_ARGS="-e FOO=$val1 -e HOME=$val2" run cqfd
    assert_success
    assert_line "$val1 $val2"
}

@test "run cqfd with --env HOME in CQFD_EXTRA_RUN_ARGS should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo \$HOME'," .cqfdrc.orig >.cqfdrc

    CQFD_EXTRA_RUN_ARGS="-e HOME=$val1" run cqfd
    assert_success
    assert_line "$val1"
}

@test "run cqfd with --env in CQFD_EXTRA_RUN_ARGS including JAVA_HOME and HOME should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    val2="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo -n \$JAVA_HOME \$HOME'," .cqfdrc.orig >.cqfdrc

    CQFD_EXTRA_RUN_ARGS="-e JAVA_HOME=$val1 -e HOME=$val2" run cqfd
    assert_success
    assert_line "$val1 $val2"
}

@test "run cqfd should set home directory to passwd file" {
    if [ "${cqfd_docker[0]}" = "sudo" ] || [ "${cqfd_docker[-1]}" = "podman" ]; then
        skip "not supported by sudo or podman"
    fi

    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='grep -E \"^$USER:x:[[:digit:]]+:[[:digit:]]+:.*:\$HOME:/bin/sh$\" /etc/passwd'," .cqfdrc.orig >.cqfdrc

    run cqfd
    assert_success
}

@test "run cqfd with --env in docker_run_args including HOME should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    val2="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo -n \$FOO \$HOME'," .cqfdrc.orig >.cqfdrc
    sed -e "/\[build\]/adocker_run_args=\"--env FOO=$val1 --env HOME=$val2\"" -i .cqfdrc

    run cqfd
    assert_success
    assert_line "$val1 $val2"
}

@test "run cqfd with --env HOME in docker_run_args should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo \$HOME'," .cqfdrc.orig >.cqfdrc
    sed -e "/\[build\]/adocker_run_args=\"--env HOME=$val1\"" -i .cqfdrc

    run cqfd
    assert_success
    assert_line "$val1"
}

@test "run cqfd with --env in docker_run_args including JAVA_HOME and HOME should set overriden HOME environment variable" {
    val1="value-$RANDOM"
    val2="value-$RANDOM"
    # shellcheck disable=SC2016
    sed -e "/\[build\]/,/^$/s,^command=.*$,command='echo -n \$JAVA_HOME \$HOME'," .cqfdrc.orig >.cqfdrc
    sed -e "/\[build\]/adocker_run_args=\"--env JAVA_HOME=$val1 --env HOME=$val2\"" -i .cqfdrc

    run cqfd
    assert_success
    assert_line "$val1 $val2"
}

@test "run cqfd should delete the ubuntu user if it conflicts with the user uid" {
    cp -f .cqfd/docker/Dockerfile.home_path .cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --exec grep -E "^ubuntu:x:$(id -u):[0-9]+" /etc/passwd
    assert_failure
}

@test "run cqfd should delete the ubuntu group if it conflicts with the user gid" {
    run cqfd --exec grep "^ubuntu:x:$(id -g):" /etc/group
    assert_failure
}

@test "run cqfd should name the primary group of the user after the user if the ubuntu group existed" {
    run cqfd --exec id -gn
    assert_success
    assert_line "$USER"
}

@test "run cqfd should give access to ssh config in home directory if the ubuntu user existed" {
    run cqfd --run 'ssh -G random_host | grep userknownhostsfile'
    assert_success
    assert_line --partial "$HOME"
}

@test "run cqfd should give access to ssh config in home directory if no user existed with the user uid" {
    sed -e "s/ubuntu:24.04/debian:trixie/" .cqfd/docker/Dockerfile.home_path >.cqfd/docker/Dockerfile

    run cqfd init
    assert_success

    run cqfd --run 'ssh -G random_host | grep userknownhostsfile'
    assert_success
    assert_line --partial "$HOME"
}

@test "run cqfd should name the primary group of the user after the user if no ubuntu group existed" {
    run cqfd --exec id -gn
    assert_success
    assert_line "$USER"
}
