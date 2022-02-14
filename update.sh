#!/bin/bash

set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

ALL_IMAGE=sstc/headful-chromium:latest

TEMPLATE_0=$(cat ./Dockerfile-0)
TEMPLATE_1=$(cat ./Dockerfile-1-build)
TEMPLATE_2=$(cat ./Dockerfile-2-download)

function generate() {
	local template="$1"
	local target="$2"
	if [ -f "$target" ]; then
		cat "$template" |
			ALL_IMAGE="$ALL_IMAGE" \
				TEMPLATE_0="$TEMPLATE_0" \
				TEMPLATE_1="$TEMPLATE_1" \
				TEMPLATE_2="$TEMPLATE_2" \
				envsubst >"$target"
		echo "$target updated."
	else
		echo >&2 "File not found ($target)"
		exit 2
	fi
}

function generate_by_tag() {
	local tag="$1"
	local template="./Dockerfile-$tag.template"
	local target="./$tag/Dockerfile"
	generate "$template" "$target"
}

for tag in all scratch; do
	generate_by_tag "$tag"
done
