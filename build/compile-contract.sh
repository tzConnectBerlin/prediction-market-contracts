#!/bin/bash

contract_file="../container/main.mligo.m4"
m4_filename=${contract_file##*/}
preprocessed_source_filename="${m4_filename%.[^.]*}"
preprocessed_source_with_path="./tmp/${preprocessed_source_filename}"

mkdir -p tmp
./preprocess.sh ${contract_file} ${preprocessed_source_with_path}

mkdir -p bin
ligo compile-contract ${preprocessed_source_with_path} main > bin/main.tz
