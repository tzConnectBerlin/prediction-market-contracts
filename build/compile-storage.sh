#!/bin/bash

if [[ -z "${1}" ]]; then
echo "Usage: ./compile-storage.sh {file} {sender address}"
echo "Eg. ./compile-storage tmp/main.mligo tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"
exit 1
fi

ligo compile-storage tmp/main.mligo main initial_storage --sender=${1} > bin/storage.tz
