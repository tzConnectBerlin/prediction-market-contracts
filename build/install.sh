#!/bin/bash

burn_cap=2.0

lazy_folder="./bin/lazy"
lambda_files=${lazy_folder}/*.tz

echo "Installing contract..."
storage=`cat bin/storage.tz`
tezos-client originate contract munchlax transferring 0 from alice \
	running bin/main.tz --init "${storage//[$'\t\r\n']}" --burn-cap ${burn_cap} --force

for f in ${lambda_files}
do
	filename=${f##*/}
	lambda_name=${filename%.[^.]*}
	lambda=`cat ${f}`
	echo "Installing ${filename} as ${lambda_name}..."
	tezos-client transfer 0 from alice to munchlax --burn-cap ${burn_cap} \
		--entrypoint installLambda --arg \(Pair\ \"${lambda_name}\"\ "${lambda//[$'\t\r\n']}"\)
done

echo "Sealing contract..."
tezos-client transfer 0 from alice to munchlax --burn-cap ${burn_cap} --entrypoint sealContract
