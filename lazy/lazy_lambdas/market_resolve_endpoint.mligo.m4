m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_RESOLVE_ENDPOINT»,,«m4_define(«MARKET_RESOLVE_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,market_resolve.mligo.m4) m4_dnl

LAZY_TYPE(resolve_market_params)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_resolve_market_params params in
	resolve_market ( params, business_storage )

») m4_dnl