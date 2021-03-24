m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_ENTER»,,«m4_define(«MARKET_ENTER»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl

let enter_market ( market_trade_params, business_storage : market_trade_params * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_trade_params.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let u = check_is_market_still_open bootstrapped_market_data in 
	


») m4_dnl