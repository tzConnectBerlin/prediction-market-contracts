#!/bin/bash

node_output=`tezos-client show address ${1}`
#node_output='Hash: tz1TfBuVJgyLz6vQ9mrQ9yQH8FPKf27NZKbQ Public Key: edpktitRYZVW3f5opUxYXTHBTLpV11HNNQ17B7e9sZwTKN8juUjtji'

tz1_addr=`echo "${node_output}" | grep -Eo 'tz1[0-9a-zA-Z]+'`

echo ${tz1_addr}