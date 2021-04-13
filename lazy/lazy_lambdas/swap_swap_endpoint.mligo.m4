m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_SWAP_ENDPOINT»,,«m4_define(«SWAP_SWAP_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,swap_swap.mligo.m4) m4_dnl

LAZY_TYPE(swap_swap_args)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_swap_swap_args params in
	let business_storage = swap_token_for_token ( params, business_storage ) in
	( [] : operation list ), business_storage

») m4_dnl
