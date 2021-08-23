m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_ADD_LQT»,,«m4_define(«SWAP_ADD_LQT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,lqt_rewards.mligo.m4) m4_dnl
m4_loadfile(.,swap.mligo.m4) m4_dnl

let calc_liquidity_token_amounts ( intended_token_amounts, pool_status : token_pair * liquidity_pool ) : nat * token_pair =
	let intended_ratio = div_nat_nat intended_token_amounts.token_a intended_token_amounts.token_b err_INVALID_AMOUNT in

	let yes_in_pool = pool_status.reserves.token_a in
	let no_in_pool = pool_status.reserves.token_b in
	let pool_ratio = div_nat_nat yes_in_pool no_in_pool m4_debug_err("pool_ratio@calc_liquidity_token_amounts@swap_add_lqt.mligo.m4") in

	let stake_ratio = if ( pool_ratio >= intended_ratio ) then
		div_nat_nat intended_token_amounts.token_a yes_in_pool m4_debug_err("true@stake_ratio@calc_liquidity_token_amounts@swap_add_lqt.mligo.m4")
	else
		div_nat_nat intended_token_amounts.token_b no_in_pool m4_debug_err("false@stake_ratio@calc_liquidity_token_amounts@swap_add_lqt.mligo.m4") in

	let lqt_amount = floor ( mul_fp_nat stake_ratio pool_status.liquidity_supply ) in
	let added_yes_amount = floor ( mul_fp_nat stake_ratio yes_in_pool ) in
	let added_no_amount = floor ( mul_fp_nat stake_ratio no_in_pool ) in
	lqt_amount, { token_a = added_yes_amount; token_b = added_no_amount; }

let add_liquidity ( args, business_storage : add_liquidity_args * business_storage ) : business_storage =
	let _ = check_execution_deadline args.operation_details.execution_deadline in
	let market_id = args.operation_details.market_id in

	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let _ = check_is_market_still_open bootstrapped_market_data in

	let token_storage = business_storage.tokens in

	let ( bootstrapped_market_data, liquidity_provider_map, token_storage ) = update_lqt_reward ( {
		market_id = market_id;
		originator = Tezos.sender;
	}, bootstrapped_market_data, business_storage.markets.liquidity_provider_map, token_storage ) in

	let pool_token_ids = get_pool_token_ids ( market_id ) in
	let pool_status = get_pool_status ( pool_token_ids, token_storage ) in

	let ( lqt_amount, token_amounts ) = calc_liquidity_token_amounts ( args.intended_token_amounts, pool_status ) in
	let _ = check_pair_slippage_control ( token_amounts, args.min_token_amounts ) in
	let token_storage = execute_add_lqt ( lqt_amount, token_amounts, pool_token_ids, token_storage ) in

	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( market_id, market_data, market_map ) in
	{ business_storage with
		markets.market_map = market_map;
		markets.liquidity_provider_map = liquidity_provider_map;
		tokens = token_storage; }

») m4_dnl