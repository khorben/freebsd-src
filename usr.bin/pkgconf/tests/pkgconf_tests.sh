#! /bin/sh
#
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2026 The FreeBSD Foundation
#
# This software was developed by Pierre Pronchery <khorben@FreeBSD.org>
# under sponsorship of the FreeBSD Foundation.

_test() {
	id="$1"
	desc="$2"
	shift 2

	# use a non-UTF-8 locale to pass the UTF-8 test (missing test file)
	log=$(LANG=C LC_ALL=C "$@" 2>&1)
	if [ $? -eq 0 ]; then
		echo "ok $id $desc"
	else
		echo "not ok $id $desc"
	fi
	echo "$log" | while read line; do
		echo "# $line"
	done
}

_tests() {
	prefix="$1"
	# from contrib/pkgconf/meson.build:292
	api_tests="audit buffer bytecode client dependency fileio fragment license path-utils personality queue tuple variable version serialize"
	# from contrib/pkgconf/meson.build:406
	tests="basic cli link-abi ordering parser personality solver sbom sysroot tuple bomtool spdxtool symlink"
	cnt=0
	for test in $api_tests $tests; do cnt=$((cnt + 1)); done
	failed=

	i=1
	echo "$i..$cnt"
	echo "# Log of test suite run on $(date)"

	for test in $api_tests; do
		_test $i "pkgconf:api-$test" "$prefix/test-api-$test"
		i=$((i + 1))
	done

	for test in $tests; do
		_test $i "pkgconf:$test" "$prefix/test-runner" --test-fixtures "$prefix/tests" --tool-dir "$prefix" "$prefix/t/$test"
		i=$((i + 1))
	done
}

_tests "$(dirname $0)"
