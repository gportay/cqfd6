#!/bin/bash
#
# Shell test functions
# Copyright (C) 2016,2023,2025-2026 Gaël PORTAY
#               2016-2025 Savoir-faire Linux, Inc.

TDIR="$1"
JTEST_LOGLVL=debug # all debug error fatal info off

declare -A _jloglevels
_jloglevels["all"]=0
_jloglevels["debug"]=1
_jloglevels["error"]=2
_jloglevels["fatal"]=3
_jloglevels["info"]=4
_jloglevels["notice"]=5
_jloglevels["off"]=6

declare -A _jcolornames
_jcolornames["gray"]="1;30"
_jcolornames["red"]="1;31"
_jcolornames["green"]="1;32"
_jcolornames["yellow"]="1;33"
_jcolornames["blue"]="1;34"
_jcolornames["purple"]="1;35"
_jcolornames["cyan"]="1;36"
_jcolornames["white"]="1;37"
_jcolornames["gray2"]="1;90"
_jcolornames["red2"]="1;91"
_jcolornames["green2"]="1;92"
_jcolornames["yellow2"]="1;93"
_jcolornames["blue2"]="1;94"
_jcolornames["purple2"]="1;95"
_jcolornames["cyan2"]="1;96"
_jcolornames["white2"]="1;97"

## _has_to_log() - checks if has to log
# $1: the loglevel ("all", "debug", "error", "fatal", "info", or "off")
_has_to_log()
{
	local level

	level="$1"
	if [ "$JTEST_LOGLVL" = "off" ] || \
	   [ "${_jloglevels[$level]}" -lt "${_jloglevels[$JTEST_LOGLVL]}" ]; then
		return 1
	fi

	return 0;
}

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
	local color

	color="$1"
	shift
	if ! _has_colors || [ -z "$color" ]; then
		printf "%s" "$*"
		return
	fi

	printf "%s%s%s" "\033[${_jcolornames[$color]}m" "$*" "\033[0m"
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
	local level
	local color
	local line

	level="$1"
	shift
	if ! _has_to_log "$level"; then
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
	echo -e "$line"
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
