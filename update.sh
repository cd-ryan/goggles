#!/usr/bin/env sh

SCRIPTDIR=$(dirname "$-1")
SCRIPTDIR=$(readlink -f "$SCRIPTDIR")

ALWAYS_LISTS="
brave-goggles-quickstart/goggles/no_pinterest.goggle
brave-goggles-quickstart/goggles/copycats_removal.goggle"

MY_GOGGLES="
rm_bad.goggle
prog_sources.goggle"

for GOGGLE in $MY_GOGGLES; do
	cat "$SCRIPTDIR"/"${GOGGLE%.*}_base.txt" > "$SCRIPTDIR"/"$GOGGLE"
	for LIST in $ALWAYS_LISTS; do
		echo "! from subrepo path: $LIST" >> "$SCRIPTDIR"/"$GOGGLE"
		egrep -v -E '^!|^$' "$SCRIPTDIR"/"$LIST" >> "$SCRIPTDIR"/"$GOGGLE"
		echo "" >> "$SCRIPTDIR"/"$GOGGLE"
	done
done

BASEURL="https://raw.githubusercontent.com/cd-ryan/goggles/main"
echo "raw URLs:"
for GOGGLE in $MY_GOGGLES; do
	echo "$BASEURL/$GOGGLE"
done

echo; echo "create link: https://search.brave.com/goggles/create"

