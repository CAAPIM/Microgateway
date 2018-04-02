#!/usr/bin/env bash
CWD="$(cd "$(dirname "$0")" && pwd)" # Script directory

# Function: print usage
function usage {
	>&2 echo "
Convert a solution kit (.sskar) in a skmult (.skmult)

$0 SOLUTIONKIT_NAME SSKAR SKMULT

SOLUTIONKIT_NAME - Name of the solution kit that matches the header and footer
                   files in the build/ folder
SSKAR  - Path of the solution kit to convert (.sskar)
SKMULT - Path of the skmult to create (.skmult)
"
}

# Function: print an error message and exit 1
function error {
	>&2 echo "$1"
	exit 1
}

# Check number of parameters
if [ $# -ne 3 ]; then
  >&2 echo "error: expects 3 parameters."
	usage; exit 1
fi

# Get inputs
solutionkit_name="${1}"
in_sskar="${2}"
out_skmult="${3}"

# Check inputs
if ! test -f "${in_sskar}"; then
	error "File not found: ${in_sskar}"
elif ! file "${in_sskar}" | grep --quiet "Zip archive data"; then
	error "File not a Zip archive: ${in_sskar}"
fi

# Build
cat "${CWD}/build/${solutionkit_name}.skmult.header" "${in_sskar}" "${CWD}/build/${solutionkit_name}.skmult.footer" > "${out_skmult}"
