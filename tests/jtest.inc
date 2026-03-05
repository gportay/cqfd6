#!/bin/bash
#
# Shell test functions
# Copyright (C) 2016,2023,2025-2026 Gaël PORTAY
#               2016-2025 Savoir-faire Linux, Inc.

TDIR="$1"
JTEST_LOGLVL=debug # all debug error fatal info off

## _has_colors() - checks if has color
_has_colors()
{
	if [ -n "$NO_COLOR" ] || [ -z "$TERM" ] || \
	   ! command -v tput >/dev/null || \
	   [ "$(tput colors 2>/dev/null || echo 0)" -lt 8 ]; then
		return 1
	fi

	return 0
}

## _colorize() - colorize string
# $1: the color name ("gray", "red", "green", "yellow", "blue", "purple",
#                     "cyan", "red2", "green2", "yellow2", "blue2", "purple2",
#                     "cyan2", or "white2")
# $2..$*: the string to colorize
# stdout: the colorized string
_colorize()
{
	local color="$1"; shift
	local text="$*"
	local c

	if ! _has_colors; then
		printf "%s" "$text"
		return
	fi

	case "$color" in
	gray)
		c='\033[1;30m'
		;;
	red)
		c='\033[1;31m'
		;;
	green)
		c='\033[1;32m'
		;;
	yellow)
		c='\033[1;33m'
		;;
	blue)
		c='\033[1;34m'
		;;
	purple)
		c='\033[1;35m'
		;;
	cyan)
		c='\033[1;36m'
		;;
	white)
		c='\033[1;37m'
		;;
	gray2)
		c='\033[1;90m'
		;;
	red2)
		c='\033[1;91m'
		;;
	green2)
		c='\033[1;92m'
		;;
	yellow2)
		c='\033[1;93m'
		;;
	blue2)
		c='\033[1;94m'
		;;
	purple2)
		c='\033[1;95m'
		;;
	cyan2)
		c='\033[1;96m'
		;;
	white2)
		c='\033[1;97m'
		;;
	esac

	printf "%s%s%s" "${c}" "${text}" "\033[0m"
}

## _jtest_log_init() - initialize log subsystem
declare -A _jloglevels
_jtest_log_init()
{
	local l
	local i=0

	for l in all debug error fatal info notice off; do
		_jloglevels[$l]=$i
		((i++))
	done
}

## _jtest_trap_error() - invoked if an instruction exits in error
_jtest_trap_error()
{
	jtest_log error "error triggered by ${BASH_SOURCE[1]}"
	_jtest_has_errors=1
}

## _jtest_trap_exit() - invoked at exit
_jtest_trap_exit()
{
	if [ -n "$_jtest_current" ]; then
		jtest_log fatal "crashed during \"$_jtest_current\""
		jtest_result fail
	fi

	# always exit with error if an error occured during script execution
	if [ "$_jtest_has_errors" = "1" ]; then
		jtest_log error "returning error as ${BASH_SOURCE[1]} produced errors"
		exit 1
	fi
}

## jtest_log() - print log message
# $1: the message loglevel ("all", "debug", "error", "fatal", "info", or "off")
# $2..$*: the message to log
# stdout: the logged message
jtest_log()
{
	local level="$1"; shift
	local color

	# filter out messages for lower loglevels
	if [ -z "${_jloglevels[$level]}" ]; then
		# invalid log level
		return 1
	elif [ "$JTEST_LOGLVL" = "off" ]; then
		# logging is off
		return 0
	elif [ "${_jloglevels[$level]}" -lt "${_jloglevels[$JTEST_LOGLVL]}" ]; then
		# insufficient log level
		return 0
	fi

	# per-loglevel coloring rules
	case "$level" in
	error)
		color=red
		;;
	notice)
		color=yellow
		;;
	*)
		;;
	esac

	line=$(_colorize "$color" "[$(date +%T)|$level] $*")
	echo -e "$line\n"
}

## jtest_prepare() - prepare next test
# $1: the test description
# stdout: the test description (notice)
jtest_prepare()
{
	if [ -z "$1" ]; then
		return 1
	fi

	_jtest_current="$1"
	jtest_log notice "preparing: \"$_jtest_current\""
}

## jtest_result() - report test result
# $1: the test status ("pass", "fail" or "skip")
# stdout: the test status (info)
jtest_result()
{
	local status="$1"
	local pfx="  "

	if [ "$status" = "fail" ]; then
		pfx="**"
	elif [ "$status" = "skip" ]; then
		pfx="--"
	fi

	echo "$pfx|${status^^}|$_jtest_current" >>"$TDIR/.jtest_results"

	case "$status" in
	pass)
		status=$(_colorize green "PASS")
		;;
	fail)
		status=$(_colorize red "FAIL")
		;;
	skip)
		status=$(_colorize yellow2 "SKIP")
		;;
	esac

	jtest_log info "result: \"$_jtest_current\": $status"
	unset _jtest_current
}

_jtest_log_init

if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
	jtest_log fatal "jtest requires a bash >4 environment"
	exit 1
fi

if [ ! -d "$TDIR" ]; then
	jtest_log fatal "test directory ($TDIR) not found"
	exit 1
fi

# we want to trap as much errors as possible
trap _jtest_trap_error ERR
trap _jtest_trap_exit EXIT

jtest_log info "-----------------------------------------------------"
jtest_log info "started from ${BASH_SOURCE[1]} in $TDIR"
