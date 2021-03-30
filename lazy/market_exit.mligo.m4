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
m4_loadfile(.,meta.mligo.m4) m4_dnl

let calculate_currency_payout ( market_trade_params, market_currency_pool, token_storage : market_trade_params * nat * token_storage ) : payout_numbers =
	let yes_token_id = get_yes_token_id market_trade_params.market_id in
	let yes_token_supply_record = get_token_supply ( yes_token_id, token_storage.supply_map ) in
	calculate_payout ( {
		quantity = market_trade_params.amount;
		token_supply = yes_token_supply_record.total_supply;
		currency_pool = market_currency_pool;
	} )

let burn_prediction_tokens ( acct, market_trade_params, token_storage : address * market_trade_params * token_storage ) : token_storage =
	let token_storage = token_burn_from_account ( {
		src = acct;
		tx = { 
			amount = market_trade_params.amount;
			token_id = ( get_yes_token_id market_trade_params.market_id );
		};
	}, token_storage ) in
	token_burn_from_account ( {
		src = acct;
		tx = {
			amount = market_trade_params.amount;
			token_id = ( get_no_token_id market_trade_params.market_id );
		};
	}, token_storage )

let exit_market ( market_trade_params, business_storage : market_trade_params * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_trade_params.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let token_storage = business_storage.tokens in
	let currency_payout_data = begin
		check_is_market_still_open bootstrapped_market_data;
		calculate_currency_payout ( market_trade_params, bootstrapped_market_data.currency_pool.market_currency_pool, token_storage )
	end in
	// Burn has to happen after the calculation or numbers will be off!
	let token_storage = burn_prediction_tokens ( Tezos.sender, market_trade_params, token_storage ) in
	let push_payout = get_push_payout ( market_data.metadata.currency, currency_payout_data.quantity ) in
	let bootstrapped_market_data = { bootstrapped_market_data with currency_pool.market_currency_pool = currency_payout_data.currency_pool } in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( market_trade_params.market_id, market_data, market_map ) in
	[ push_payout ], { business_storage with
		markets.market_map = market_map;
		tokens = token_storage;
	}

») m4_dnl
