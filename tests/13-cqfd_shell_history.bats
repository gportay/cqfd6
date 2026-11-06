#!/usr/bin/env bats
#
# validate the behavior of shell history

setup() {
    load 'test_helper/common-setup'
    _common_setup
    CQFD_HISTFILE="$BATS_SUITE_TMPDIR/.cqfd_history"
    export CQFD_HISTFILE
    commands_file="$BATS_TEST_TMPDIR/commands.txt"
}

teardown() {
    rm -f "$CQFD_HISTFILE"
}

# $1: the shell name
# $2: the cqfd command (i.e. --exec, --run, --shell, exec, run, shell or none)
# $3: set to true if the history is not saved
run_shell_commands() {
    local shell_name="$1"
    local command="$2"
    local history_not_saved="$3"
    local string_to_check="hello from the other side $shell_name"
    echo "echo $string_to_check" >"$commands_file"

    case "$command" in
    --exec|--run|exec|run)
        run cqfd "$command" "$shell_name" -i <"$commands_file"
        ;;
    --shell|shell)
        CQFD_SHELL="$shell_name" run cqfd "$command" -i <"$commands_file"
        ;;
    *)
        run cqfd "$shell_name" -i <"$commands_file"
        ;;
    esac

    # test that the shell commands have been run from the commands file
    assert_success
    assert_line --partial "$string_to_check"

    # test that the commands run are now in the history file
    run tail "${CQFD_HISTFILE:-$HOME/.${shell_name}_history}"
    if [ "$history_not_saved" = "true" ]; then
        assert_failure
    else
        assert_success
        assert_line --partial "echo $string_to_check"
    fi
}

@test "bash: commands run are saved in the history file" {
    touch "$CQFD_HISTFILE"
    run_shell_commands "bash"
}

@test "zsh: commands run are saved in the history file" {
    touch "$CQFD_HISTFILE"
    run_shell_commands "zsh"
}

@test "ksh: commands run are saved in the history file" {
    touch "$CQFD_HISTFILE"
    run_shell_commands "ksh"
}

@test "bash: shell history file is created if it does not already exist" {
    run_shell_commands "bash"
}

@test "zsh: shell history file is created if it does not already exist" {
    run_shell_commands "zsh"
}

@test "ksh: shell history file is created if it does not already exist" {
    run_shell_commands "ksh"
}

@test "bash: history saving functions as expected when cqfd is called with --run" {
    run_shell_commands "bash" "--run"
}

@test "zsh: history saving functions as expected when cqfd is called with --run" {
    run_shell_commands "zsh" "--run"
}

@test "ksh: history saving functions as expected when cqfd is called with --run" {
    run_shell_commands "ksh" "--run"
}

@test "bash: history saving functions as expected when cqfd is called with --exec" {
    run_shell_commands "bash" "--exec"
}

@test "zsh: history saving functions as expected when cqfd is called with --exec" {
    run_shell_commands "zsh" "--exec"
}

@test "ksh: history saving functions as expected when cqfd is called with --exec" {
    run_shell_commands "ksh" "--exec"
}

@test "bash: history saving functions as expected when cqfd is called with --shell" {
    run_shell_commands "bash" "--shell"
}

@test "zsh: history saving functions as expected when cqfd is called with --shell" {
    run_shell_commands "zsh" "--shell"
}

@test "ksh: history saving functions as expected when cqfd is called with --shell" {
    run_shell_commands "ksh" "--shell"
}

@test "bash: history saving functions as expected when cqfd is called with run" {
    run_shell_commands "bash" "run"
}

@test "bash: history saving functions as expected when cqfd is called with exec" {
    run_shell_commands "bash" "exec"
}

@test "bash: history saving functions as expected when cqfd is called with shell" {
    run_shell_commands "bash" "shell"
}

@test "bash: history is saved in \$HOME/.bash_history if CQFD_HISTFILE is unset" {
    unset CQFD_HISTFILE
    HOME="$BATS_TEST_TMPDIR" run_shell_commands "bash"
}

@test "bash: history not saving when using CQFD_DISABLE_SHELL_HISTORY=true" {
    CQFD_DISABLE_SHELL_HISTORY="true" run_shell_commands "bash" "" "true"
}

@test "bash: history saving when using CQFD_DISABLE_SHELL_HISTORY=false" {
    CQFD_DISABLE_SHELL_HISTORY="false" run_shell_commands "bash" "" "false"
}
