m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_BET_ENDPOINT»,,«m4_define(«AUCTION_BET_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(..,auction_bet.mligo.m4) m4_dnl

LAZY_TYPE(bet_params)

let auction_bet_endpoint : business_endpoint_lambda =
	( params, storage : bytes * business_storage ) ->
	let params = unpack_bet_params params in
	let operations, market_storage = place_auction_bet ( params, business_storage.markets ) in
	operations, { business_storage with
		markets = market_storage;
	}

»)