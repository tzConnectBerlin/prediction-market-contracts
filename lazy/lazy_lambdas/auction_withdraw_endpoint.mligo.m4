m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_WITHDRAW_ENDPOINT»,,«m4_define(«AUCTION_WITHDRAW_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(..,auction_withdraw.mligo.m4) m4_dnl

LAZY_TYPE(market_id)

let auction_withdraw_endpoint : business_endpoint_lambda =
	( params, storage : bytes * business_storage ) ->
	let params = unpack_market_id params in
	withdraw_tokens_from_auction ( params, business_storage )

») m4_dnl