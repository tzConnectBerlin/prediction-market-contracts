m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_MOVE_LQT_ENDPOINT»,,«m4_define(«SWAP_MOVE_LQT_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,swap_add_lqt.mligo.m4) m4_dnl

LAZY_TYPE(add_liquidity_args)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_add_liquidity_args params in
	let business_storage = add_liquidity ( params, business_storage ) in
	( [] : operation list ), business_storage

») m4_dnl
