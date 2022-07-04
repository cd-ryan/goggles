#!/usr/bin/env sh

ALWAYS_LISTS="
brave-goggles-quickstart/goggles/no_pinterest.goggle
brave-goggles-quickstart/goggles/copycats_removal.goggle"

SCRIPTDIR=$(dirname "$-1")
SCRIPTDIR=$(readlink -f "$SCRIPTDIR")
cd "$SCRIPTDIR" || exit 1

rm "$SCRIPTDIR"/*.goggle*

# rm_bad
cat "$SCRIPTDIR"/rm_bad_base.txt > "$SCRIPTDIR"/rm_bad.goggle
for LIST in $ALWAYS_LISTS; do
	egrep -v -E '^!|^$' "$SCRIPTDIR"/"$LIST" >> "$SCRIPTDIR"/rm_bad.goggle
done

# prog_sources
cat "$SCRIPTDIR"/prog_sources_base.txt > "$SCRIPTDIR"/prog_sources.goggle
for LIST in $ALWAYS_LISTS; do
	egrep -v -E '^!|^$' "$SCRIPTDIR"/"$LIST" >> "$SCRIPTDIR"/prog_sources.goggle
done

cd - >/dev/null || exit 1
echo "hard coded URLs:"
echo 'https://raw.githubusercontent.com/cd-ryan/goggles/main/rm_bad.goggle'
echo 'https://raw.githubusercontent.com/cd-ryan/goggles/main/prog_sources.goggle'
