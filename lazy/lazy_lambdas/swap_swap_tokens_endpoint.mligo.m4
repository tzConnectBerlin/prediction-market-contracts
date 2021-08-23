m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_SWAP_TOKENS_ENDPOINT»,,«m4_define(«SWAP_SWAP_TOKENS_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,swap_swap_tokens.mligo.m4) m4_dnl

LAZY_TYPE(token_trade_args)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_token_trade_args params in
	let business_storage = swap_token_for_token ( params, business_storage ) in
	( [] : operation list ), business_storage

») m4_dnl
