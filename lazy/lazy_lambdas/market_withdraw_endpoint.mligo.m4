m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_WITHDRAW_ENDPOINT»,,«m4_define(«AUCTION_WITHDRAW_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,market_withdraw.mligo.m4) m4_dnl

LAZY_TYPE(market_id)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_market_id params in
	( [] : operation list ), withdraw_reserve_tokens ( params, business_storage )

») m4_dnl
