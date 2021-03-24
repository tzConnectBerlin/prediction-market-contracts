m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_CREATE_ENDPOINT»,,«m4_define(«MARKET_CREATE_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(..,market_enter.mligo.m4) m4_dnl

LAZY_TYPE(market_trade_params)

let enter_market_endpoint : business_endpoint_lambda =
	( params, storage : bytes * business_storage ) ->
	let params = unpack_create_market_params params in
	enter_market ( params, business_storage )

») m4_dnl