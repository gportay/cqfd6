.PHONY: tests check

tests: export CQFD_NO_DEPRECATED_COMMAND_WARNING = true
tests: export CQFD_NO_DEPRECATED_WARNING = true
tests: CQFD_DOCKER =
tests: CQFD_DEBUG =
tests: CQFD_EXTRA_RUN_ARGS =
tests: CQFD_EXTRA_BUILD_ARGS =
tests: CQFD_EXTRA_PULL_ARGS =
tests: CQFD_EXTRA_RMI_ARGS =
tests: CQFD_NO_SSH_CONFIG =
tests: CQFD_NO_SSH_AUTH_SOCK =
tests: CQFD_NO_USER_SSH_CONFIG =
tests: CQFD_NO_USER_GIT_CONFIG =
tests: CQFD_NO_SYSTEM_GIT_CONFIG =
tests: CQFD_BIND_DOCKER_SOCK =
tests: CQFD_DOCKER_GID =
tests: CQFD_SHELL =
tests: CQFD_HISTFILE =
tests: CQFD_DISABLE_SHELL_HISTORY =
tests: CQFD_PLATFORM =
tests: CQFD_WORKDIR =
tests: CQFD_DIR =
tests: CQFDRC_FILE =
tests:
	./bats/bin/bats $$PWD

check:
	shellcheck -x [0-9][0-9]*
