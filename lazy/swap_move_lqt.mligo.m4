m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_MOVE_LQT»,,«m4_define(«SWAP_MOVE_LQT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,lqt_rewards.mligo.m4) m4_dnl
m4_loadfile(.,swap.mligo.m4) m4_dnl

let check_slippage_control ( pair_a, pair_b : token_pair * token_pair ) : unit =
	if ( ( pair_a.token_a >= pair_b.token_a ) && ( pair_a.token_b >= pair_b.token_b ) ) then
		unit
	else
		failwith err_SLIPPAGE_EXCEEDED

let move_liquidity_in_swap ( args, business_storage : move_liquidity_params * business_storage ) : business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( args.params.trade.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let _ = check_is_market_still_open bootstrapped_market_data in
	let token_storage = business_storage.tokens in

	let ( bootstrapped_market_data, liquidity_provider_map, token_storage ) = update_lqt_reward ( {
		market_id = args.params.trade.market_id;
		originator = Tezos.sender;
	}, bootstrapped_market_data, business_storage.markets.liquidity_provider_map, token_storage ) in
	let pool_token_ids = get_pool_token_ids ( args.params.trade.market_id ) in
	let pool_status = get_pool_status ( pool_token_ids, token_storage ) in
	let token_amounts = calc_liquidity_to_tokens ( args.params.trade.amount, pool_status ) in
	let token_storage = match args.params.direction with
	| PayIn -> (
		let _ = check_slippage_control ( args.slippage_control, token_amounts ) in
		execute_add_lqt ( args.params.trade.amount, token_amounts, pool_token_ids, token_storage )
	)
	| PayOut -> (
		let _ = check_slippage_control ( token_amounts, args.slippage_control ) in
		execute_remove_lqt ( args.params.trade.amount, token_amounts, pool_token_ids, token_storage )
	) in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( args.params.trade.market_id, market_data, market_map ) in
	{ business_storage with
		markets.market_map = market_map;
		markets.liquidity_provider_map = liquidity_provider_map;
		tokens = token_storage; }

») m4_dnl