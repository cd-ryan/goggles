#!/usr/bin/env sh

if !which wget >/dev/null 2>&1; then >&2 echo "please install wget"; exit 1; fi

LISTS="
https://raw.githubusercontent.com/brave/goggles-quickstart/main/goggles/no_pinterest.goggle
https://raw.githubusercontent.com/brave/goggles-quickstart/main/goggles/copycats_removal.goggle"

SCRIPTDIR=$(dirname "$0")
SCRIPTDIR=$(readlink -f "$SCRIPTDIR")
cd "$SCRIPTDIR" || exit 1

rm "$SCRIPTDIR"/*.goggle*
cat "$SCRIPTDIR"/rm_bad_base.txt > "$SCRIPTDIR"/rm_bad.goggle

for LIST in $LISTS; do
	wget $LIST
	egrep -v -E '^!|^$' "$SCRIPTDIR"/$(basename "$LIST") >> "$SCRIPTDIR"/rm_bad.goggle
done

cd - >/dev/null || exit 1

echo "hard coded URL:" 'https%3A%2F%2Fraw.githubusercontent.com%2Fcd-ryan%2Fgoggles%2Fmain%2Frm_bad.goggle'
