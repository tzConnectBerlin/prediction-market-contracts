m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_ENTER»,,«m4_define(«MARKET_ENTER»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,market_withdraw.mligo.m4) m4_dnl
m4_loadfile(.,external_token.mligo.m4) m4_dnl
m4_loadfile(.,payouts.mligo.m4) m4_dnl


let get_market_result ( bootstrapped_market_data : bootstrapped_market_data ) : resolution_data =
	match bootstrapped_market_data.resolution with
	| Some d -> d
	| None -> ( failwith err_MARKET_NOT_RESOLVED : resolution_data )

let get_tokenpool_payout ( acct, token_id, currency_pool, token_storage : address * token_id * nat * token_storage ) : payout_result * nat =
	let token_balance_and_supply = get_token_balance_and_supply ( {
		owner = acct;
		token_id = token_id;
	}, token_storage ) in
	( calculate_payout ( {
		quantity = token_balance_and_supply.balance;
		token_supply = token_balance_and_supply.supply;
		currency_pool = currency_pool;
	} ), token_balance_and_supply.balance )

let claim_market_rewards ( market_id, business_storage : market_id * business_storage ) : operation list * business_storage =
	let business_storage = withdraw_reserve_tokens ( market_id, business_storage ) in
	let acct = Tezos.sender in
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let resolution_data = get_market_result bootstrapped_market_data in
	//
	// Calculate payouts
	let token_storage = business_storage.tokens in
	let liquidity_reward_token_id = get_liquidity_reward_token_id market_id in
	let liquidity_reward_payout_numbers, lqt_reward_balance = get_tokenpool_payout ( acct, liquidity_reward_token_id, bootstrapped_market_data.currency_pool.liquidity_reward_currency_pool, token_storage ) in
	let auction_reward_token_id = get_auction_reward_token_id market_id in
	let auction_reward_payout_numbers, auction_reward_balance = get_tokenpool_payout ( acct, auction_reward_token_id, bootstrapped_market_data.currency_pool.auction_reward_currency_pool, token_storage ) in
	let winning_token_id = if ( resolution_data.winning_prediction ) then
		get_yes_token_id market_id
	else
		get_no_token_id market_id in
	let winning_token_payout_numbers, winning_token_balance = get_tokenpool_payout ( acct, winning_token_id, bootstrapped_market_data.currency_pool.market_currency_pool, token_storage ) in
	//
	// Burn tokens and update currency pool record
	let token_storage = token_burn_from_account ( {
		src = acct;
		tx = {
			token_id = liquidity_reward_token_id;
			amount = lqt_reward_balance;
		};
	}, token_storage ) in
	let token_storage = token_burn_from_account ( {
		src = acct;
		tx = {
			token_id = auction_reward_token_id;
			amount = auction_reward_balance;
		};
	}, token_storage ) in
	let token_storage = token_burn_from_account ( {
		src = acct;
		tx = {
			token_id = winning_token_id;
			amount = winning_token_balance;
		};
	}, token_storage ) in
	let bootstrapped_market_data = { bootstrapped_market_data with
		currency_pool.liquidity_reward_currency_pool = liquidity_reward_payout_numbers.new_currency_pool;
		currency_pool.auction_reward_currency_pool = auction_reward_payout_numbers.new_currency_pool;
		currency_pool.market_currency_pool = winning_token_payout_numbers.new_currency_pool;
	} in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( market_id, market_data, market_map ) in
	//
	// Add up currency payout
	let currency_payout = add_nat_nat winning_token_payout_numbers.currency_payout ( add_nat_nat liquidity_reward_payout_numbers.currency_payout auction_reward_payout_numbers.currency_payout ) in
	let push_payout = get_push_payout ( market_data.metadata.currency, currency_payout ) in
	[ push_payout ], { business_storage with
		markets.market_map = market_map;
		tokens = token_storage;
	}

») m4_dnl