m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP_SWAP_TOKENS»,,«m4_define(«SWAP_SWAP_TOKENS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,swap.mligo.m4) m4_dnl

type swap_token_ids =
[@layout:comb]
{
	token_in_id : token_id;
	token_out_id : token_id;
}

let get_swap_token_ids ( market_id, token_in_type : market_id * outcome_type ) : swap_token_ids =
	let yes_token_id = get_yes_token_id market_id in
	let no_token_id = get_no_token_id market_id in
	match token_in_type with
	| Yes -> {
		token_in_id = yes_token_id;
		token_out_id = no_token_id; }
	| No -> {
		token_in_id = no_token_id;
		token_out_id = yes_token_id; }

let get_token_pool ( swap_token_ids, ledger_map : swap_token_ids * ledger_map ) : token_pair =
	let pair_address = Tezos.self_address in
	let token_a_pool = get_token_balance ( {
		token_id = swap_token_ids.token_in_id;
		owner = pair_address;
	}, ledger_map ) in
	let token_b_pool = get_token_balance ( {
		token_id = swap_token_ids.token_out_id;
		owner = pair_address;
	}, ledger_map ) in
	{
		token_a = token_a_pool;
		token_b = token_b_pool;
	}

let execute_token_swap ( token_amounts, swap_token_ids, ledger_map : token_pair * swap_token_ids * ledger_map ) : ledger_map =
	let pair_address = Tezos.self_address in
	let client_address = Tezos.sender in
	let ledger_map = token_transfer_internal ( {
		src = client_address;
		tx = {
			dst = pair_address;
			token_id = swap_token_ids.token_in_id;
			amount = token_amounts.token_a;
		};
	}, ledger_map ) in
	token_transfer_internal ( {
		src = pair_address;
		tx = {
			dst = client_address;
			token_id = swap_token_ids.token_out_id;
			amount = token_amounts.token_b;
		};
	}, ledger_map )

let swap_token_for_token ( args, business_storage : token_trade_params * business_storage ) : business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( args.params.market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data market_data in
	let _ = check_is_market_still_open bootstrapped_market_data in
	let swap_token_ids = get_swap_token_ids ( args.params.market_id, args.token_to_sell ) in
	let ledger_map = business_storage.tokens.ledger_map in
	let token_pool = get_token_pool ( swap_token_ids, ledger_map ) in
	let token_a_in = args.params.amount in
	let token_b_out = calc_fixed_input_swap ( token_a_in, token_pool ) in
	let ledger_map = execute_token_swap ( {
		token_a = token_a_in;
		token_b = token_b_out;
	}, swap_token_ids, ledger_map ) in
	{ business_storage with tokens.ledger_map = ledger_map; }

») m4_dnl