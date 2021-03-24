#!/bin/bash

if [[ -z "${1}" ]]; then
echo "Usage: ./preprocess.sh {path to root m4 file} {path to output file}"
exit 1
fi

working_directory=${1%/*}
helper_directory="../m4_helpers"

mkdir -p tmp
m4 -P -I ${helper_directory} -D "M4_WORKING_DIR=${working_directory}" ${1} > ${2}
