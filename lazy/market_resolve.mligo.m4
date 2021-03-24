m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_RESOLVE»,,«m4_define(«MARKET_RESOLVE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction_clear.mligo.m4) m4_dnl

let resolve_market ( resolve_market_params, business_storage : resolve_market_params * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( resolve_market_params.market_id, market_map ) in
	let bootstrapped_market_data, token_storage = match market_data.state with
	| AuctionRunning e -> set_market_state_cleared ( resolve_market_params.market_id, e, business_storage.tokens )
	| MarketBootstrapped e -> ( e, business_storage.tokens ) in
	let resolution_data = match bootstrapped_market_data.resolution with
	| Some u -> ( failwith err_MARKET_ALREADY_RESOLVED : resolution_data )
	| None -> {
		winning_prediction = resolve_market_params.winning_prediction;
		resolved_at_block = Tezos.level;
	} in
	let bootstrapped_market_data = { bootstrapped_market_data with
		resolution = Some(resolution_data)
	} in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( resolve_market_params.market_id, market_data, market_map ) in
	( [] : operation list ), { business_storage with
		tokens = token_storage;
		markets.market_map = market_map;
	}

») m4_dnl
