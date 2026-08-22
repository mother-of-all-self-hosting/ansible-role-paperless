#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Slavi Pantaleev
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Exercises bin/compute-next-tag.sh against throwaway git repositories.
#
# Usage: bin/test-compute-next-tag.sh
#
# Every scenario creates a repository in a temporary directory, gives it role
# files and a release history, and then replays a series of merges through the
# real script, tagging as it goes just like the autotag workflow does. This
# repository is never touched and no network access is needed.

set -euo pipefail

script_under_test="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/compute-next-tag.sh"

failures=0
workdir=''

cleanup() {
	cd /
	if [ -n "$workdir" ]; then
		rm -rf "$workdir"
		workdir=''
	fi
}

trap cleanup EXIT

# Starts a scenario with a repository at Paperless-ngx 3.0.5 (with Tika and
# Gotenberg as secondary components) which has already seen two releases of it
# (v3.0.5-0 and v3.0.5-1).
scenario() {
	echo "$1"

	cleanup
	workdir="$(mktemp -d)"

	mkdir -p "$workdir/bin" "$workdir/defaults" "$workdir/tasks"
	cp "$script_under_test" "$workdir/bin/"
	cd "$workdir"

	git init -q -b main .
	git config user.email 'test@example.com'
	git config user.name 'Test'
	git config commit.gpgsign false

	{
		printf 'paperless_version: "3.0.5"\n'
		printf 'paperless_tika_version: "3.1.0.0"\n'
		printf 'paperless_gotenberg_version: "8.36.0"\n'
	} > defaults/main.yml
	printf 'placeholder\n' > tasks/main.yml
	printf 'placeholder\n' > README.md

	git add -A
	git commit -qm 'Initial commit'

	local release_number
	for release_number in 0 1; do
		git tag "v3.0.5-$release_number"
	done
}

# Applies a change, commits it, and tags whatever the script says it should be.
# Prints the tag, or nothing when the script decided against a release.
merge() {
	local change="$1" tag

	eval "$change"
	git add -A
	git commit -qm 'Merge'

	tag="$(bin/compute-next-tag.sh 2>/dev/null)"

	if [ -n "$tag" ]; then
		git tag "$tag"
	fi

	printf '%s' "$tag"
}

expect() {
	local description="$1" expected="$2" actual="$3"

	if [ "$actual" = "$expected" ]; then
		printf '  ok   | %s -> %s\n' "$description" "${actual:-no release}"
	else
		printf '  FAIL | %s -> expected %s, got %s\n' "$description" "${expected:-no release}" "${actual:-no release}"
		failures=$((failures + 1))
	fi
}

bump_paperless="sed -i 's|paperless_version: \"3.0.5\"|paperless_version: \"3.0.6\"|' defaults/main.yml"
bump_tika="sed -i 's|paperless_tika_version: \"3.1.0.0\"|paperless_tika_version: \"4.0.0.0\"|' defaults/main.yml"
bump_gotenberg="sed -i 's|paperless_gotenberg_version: \"8.36.0\"|paperless_gotenberg_version: \"8.37.0\"|' defaults/main.yml"
edit_task="printf 'a task\n' >> tasks/main.yml"
edit_readme="printf 'documentation\n' >> README.md"

scenario 'Component bumps only move the release counter'
expect 'tika'      v3.0.5-2 "$(merge "$bump_tika")"
expect 'gotenberg' v3.0.5-3 "$(merge "$bump_gotenberg")"
expect 'paperless' v3.0.6-0 "$(merge "$bump_paperless")"

scenario 'A paperless bump merged before component bumps'
expect 'paperless' v3.0.6-0 "$(merge "$bump_paperless")"
expect 'tika'      v3.0.6-1 "$(merge "$bump_tika")"

scenario 'Commits that do not affect the role'
expect 'README' ''       "$(merge "$edit_readme")"
expect 'a task' v3.0.5-2 "$(merge "$edit_task")"

scenario 'Release numbers past 9'
for release_number in 2 3 4 5 6 7 8 9 10; do
	git tag "v3.0.5-$release_number"
done
expect 'a task' v3.0.5-11 "$(merge "$edit_task")"

if [ "$failures" -gt 0 ]; then
	echo >&2 "$failures scenario(s) behaved unexpectedly"
	exit 1
fi

echo 'All scenarios behaved as expected'
