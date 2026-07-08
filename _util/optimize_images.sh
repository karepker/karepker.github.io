#! /bin/bash

# Resize and strip metadata from JPEGs so they are ready to serve on the web.
# Operates in place, overwriting each image with its optimized version.
#
# Each processed image is stamped with a marker in its JPEG comment so that
# re-running on the same directory skips already-optimized images. This keeps
# the script idempotent: JPEG is lossy, so re-encoding a file would otherwise
# degrade it a little on every run. Pass -f to force reprocessing.
#
# An image whose comment is "keep-original" is always skipped, even with -f, so
# images we want to serve at their native resolution can opt out entirely. Stamp
# one losslessly (without re-encoding) using libjpeg's wrjpgcom:
#
#  $ wrjpgcom -replace -comment "keep-original" image.jpg

set -euo pipefail

width=1200
quality=75
force=0
marker="optimized-for-web"
keep_marker="keep-original"

usage() {
	echo "Usage: $0 [-w WIDTH] [-q QUALITY] [-f] DIR"
	echo "  -w WIDTH    max width in pixels, only downscales (default: ${width})"
	echo "  -q QUALITY  JPEG quality (default: ${quality})"
	echo "  -f          force reprocessing of already-optimized images"
}

while getopts "w:q:fh" opt; do
	case "${opt}" in
		w) width="${OPTARG}" ;;
		q) quality="${OPTARG}" ;;
		f) force=1 ;;
		h) usage; exit 0 ;;
		*) usage; exit 1 ;;
	esac
done
shift $((OPTIND - 1))

if (( $# < 1 )); then
	usage
	exit 1
fi

dir="$1"
if [[ ! -d "${dir}" ]]; then
	echo "Not a directory: ${dir}" >&2
	exit 1
fi

if command -v magick > /dev/null 2>&1; then
	convert="magick"
	identify="magick identify"
else
	convert="convert"
	identify="identify"
fi

find "${dir}" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 |
while IFS= read -r -d '' image; do
	comment="$(${identify} -format '%c' "${image}")"
	if [[ "${comment}" == "${keep_marker}" ]]; then
		echo "Skipping ${image} (keep-original)"
		continue
	fi
	if (( force == 0 )) && [[ "${comment}" == "${marker}" ]]; then
		echo "Skipping ${image} (already optimized)"
		continue
	fi
	echo "Optimizing ${image}"
	# ">" means only shrink images wider than WIDTH, never upscale.
	# -strip drops all metadata, then -set comment re-adds the marker so future
	# runs can recognize this image as already processed.
	"${convert}" "${image}" -resize "${width}>" -quality "${quality}" \
		-strip -set comment "${marker}" "${image}"
done
