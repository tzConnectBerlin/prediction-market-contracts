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

let mint_prediction_tokens ( recipient, market_trade_params, token_storage : address * market_trade_params * token_storage ) : token_storage =
	let token_storage = token_mint_to_account ( {
		dst = recipient;
		amount = market_trade_params.amount;
		token_id = ( get_yes_token_id market_trade_params.market_id );
	}, token_storage ) in
	token_mint_to_account ( {
		dst = recipient;
		amount = market_trade_params.amount;
		token_id = ( get_no_token_id market_trade_params.market_id );
	}, token_storage )

let enter_market ( market_trade_params, business_storage : market_trade_params * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_trade_params.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let pull_payment = begin
		check_is_market_still_open bootstrapped_market_data;
		get_pull_payment ( market_data.metadata.currency, market_trade_params.amount )
	end in
	let token_storage = mint_prediction_tokens ( Tezos.sender, market_trade_params, business_storage.tokens ) in
	let currency_pool_delta = split_revenue market_trade_params.amount in
	let bootstrapped_market_data = increment_currency_pool ( currency_pool_delta, bootstrapped_market_data ) in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( market_trade_params.market_id, market_data, market_map ) in
	[ pull_payment ], { business_storage with
		markets.market_map = market_map;
		tokens = token_storage;
	}

») m4_dnl
