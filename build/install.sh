#!/bin/bash

if [[ -z "${1}" ]]; then
echo "Usage: ./install.sh {tezos-client account name}"
echo "Eg. ./compile-storage alice"
exit 1
fi

account_name=${1}
contract_name="binarypm"
burn_cap=2.0

account_addr=`./getaddr.sh ${account_name}`
./build.sh ${account_addr}

lazy_folder="./bin/lazy"
lambda_files=${lazy_folder}/*.tz

echo "Installing contract..."
storage=`cat bin/storage.tz`
tezos-client originate contract ${contract_name} transferring 0 from ${account_name} \
	running bin/main.tz --init "${storage//[$'\t\r\n']}" --burn-cap ${burn_cap} --force

for f in ${lambda_files}
do
	filename=${f##*/}
	lambda_name=${filename%.[^.]*}
	lambda=`cat ${f}`
	echo "Installing ${filename} as ${lambda_name}..."
	tezos-client transfer 0 from ${account_name} to ${contract_name} --burn-cap ${burn_cap} \
		--entrypoint installLambda --arg \(Pair\ \"${lambda_name}\"\ "${lambda//[$'\t\r\n']}"\)
done

echo "Sealing contract..."
tezos-client transfer 0 from ${account_name} to ${contract_name} --burn-cap ${burn_cap} --entrypoint sealContract
