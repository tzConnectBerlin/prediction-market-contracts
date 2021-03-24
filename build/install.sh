#!/bin/bash

lazy_folder="./bin/lazy"
lambda_files=${lazy_folder}/*.tz

echo "Installing contract..."
storage=`cat bin/storage.tz`
tezos-client originate contract munchlax transferring 0 from alice \
	running bin/main.tz --init "${storage//[$'\t\r\n']}" --burn-cap 0.5 --force

for f in ${lambda_files}
do
	filename=${f##*/}
	lambda_name=${filename%.[^.]*}
	lambda=`cat ${f}`
	echo "Installing ${filename} as ${lambda_name}..."
	tezos-client transfer 0 from alice to munchlax --burn-cap 0.5 \
		--entrypoint installLambda --arg \(Pair\ \"${lambda_name}\"\ "${lambda//[$'\t\r\n']}"\)
done

echo "Sealing contract..."
tezos-client transfer 0 from alice to snorlax --burn-cap 0.5 --entrypoint sealContract
