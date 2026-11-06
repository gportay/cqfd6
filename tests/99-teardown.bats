#!/usr/bin/env bats
#
# validate the behavior of ls and gc command to teardown

setup_file() {
    for i in .cqfd/*/Dockerfile; do
        test -e "$i" || continue
        echo "RUN echo $EPOCHSECONDS" >>"$i"
    done
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "run cqfd ls should list build containers" {
    run cqfd ls
    assert_success
    assert_line --regexp "^cqfd-$USER-.+$"
}

@test "run cqfd gc should collect unused build containers" {
    CQFD_PROMPT=yes run cqfd gc
    assert_success

    run cqfd ls
    assert_success
    refute_line --regexp "^cqfd-$USER-.+[[:blank:]]+(Deleted|Outdated)[[:blank:]][[:alnum:]/.-]+$"
}

@test "run cqfd ls should not list build containers" {
    run cqfd ls
    assert_success
    refute_line --regexp "^cqfd-$USER-.+$"
}
