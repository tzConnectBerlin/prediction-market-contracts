m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_ENTER»,,«m4_define(«MARKET_ENTER»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,external_token.mligo.m4) m4_dnl
m4_loadfile(.,payouts.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl

let get_tokenpool_payout ( token_id, currency_pool, token_storage : token_id * nat * token_storage ) : payout_result =
	let token_balance_and_supply = get_token_balance_and_supply ( {
		owner = Tezos.sender;
		token_id = token_id;
	}, token_storage ) in
	calculate_payout ( {
		quantity = token_balance_and_supply.balance;
		token_supply = token_balance_and_supply.supply;
		currency_pool = currency_pool;
	} )

(* let claim_market_rewards ( market_id, business_storage : market_id * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_trade_params.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let resolution_data = get_market_result bootstrapped_market_data in
	let liquidity_reward_token_id = get_liquidity_reward_token_id market_id in
	// let something = update_liquidity_reward ( Tezos.sender, resolution_data.resolved_at_block, business_storage )
	
	let auction_reward_token_id = get_auction_reward_token_id market_id in

	let token_storage = business_storage.tokens in
	let winning_token_id = if ( resolution_data.winning_prediction ) then
		get_yes_token_id market_id
	else
		get_no_token_id market_id in
	let winning_token_payout_numbers = get_tokenpool_payout ( winning_token_id, bootstrapped_market_data.currency_pool.market_currency_pool ) in
	*)

») m4_dnl