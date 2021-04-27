#!/bin/bash

if [[ -z "${1}" ]]; then
echo "Usage: ./build.sh {sender address}"
echo "Eg. ./build.sh tz1VSUr8wwNhLAzempoch5d6hLRiTh8Cjcjb"
exit 1
fi

./compile-contract.sh
./compile-storage.sh ${1}
./compile-lambdas.sh

