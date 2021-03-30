#!/bin/bash

lambda_dir="../lazy/lazy_lambdas"
FILES=${lambda_dir}/*

for f in $FILES
do
	./process-lambda.sh ${f}
done
