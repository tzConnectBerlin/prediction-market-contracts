m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«SWAP»,,«m4_define(«SWAP»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl

let swap_fee_numerator = 997n (* 0.3% fee *)
let swap_fee_denominator = 1000n

type token_pair =
[@layout:comb]
{
	token_a : nat;
	token_b : nat;
}

type liquidity_pool =
[@layout:comb]
{
	reserves : token_pair;
	liquidity_supply : nat;
}

let calc_liquidity_to_tokens ( lqt_amount, liquidity_pool : nat * liquidity_pool ) : token_pair =
	if ( lqt_amount = 0n ) then
		{
			token_a = 0n;
			token_b = 0n;
		}
	else (
		let lqt_ratio = div_nat_nat lqt_amount liquidity_pool.liquidity_supply m4_debug_err("lqt_ratio@calc_liquidity_to_tokens@swap.mligo.m4") in
		let token_a = floor ( mul_fp_nat lqt_ratio liquidity_pool.reserves.token_a ) in
		let token_b = floor ( mul_fp_nat lqt_ratio liquidity_pool.reserves.token_b ) in
		{
			token_a = token_a;
			token_b = token_b;
		}
	)

let calc_fixed_input_swap ( token_a_in, token_pair : nat * token_pair ) : nat =
	let numerator = mul_nat_nat ( mul_nat_nat token_a_in token_pair.token_b ) swap_fee_numerator in
	let denominator = add_nat_nat ( mul_nat_nat token_pair.token_a swap_fee_denominator ) ( mul_nat_nat token_a_in swap_fee_numerator ) in
	div_nat_nat_floor numerator denominator m4_debug_err("calc_fixed_input_swap@swap.mligo.m4")

type pool_token_ids =
[@layout:comb]
{
	yes_token_id : token_id;
	no_token_id : token_id;
	lqt_token_id : token_id;
}

let get_pool_token_ids ( market_id : market_id ) : pool_token_ids =
	{
		yes_token_id = get_yes_token_id market_id;
		no_token_id = get_no_token_id market_id;
		lqt_token_id = get_liquidity_token_id market_id;
	}

let get_pool_status ( pool_token_ids, token_storage : pool_token_ids * token_storage ) : liquidity_pool =
	let pair_address = Tezos.self_address in
	let yes_balance = get_token_balance ( {
		token_id = pool_token_ids.yes_token_id;
		owner = pair_address;
	}, token_storage.ledger_map ) in
	let no_balance = get_token_balance ( {
		token_id = pool_token_ids.no_token_id;
		owner = pair_address;
	}, token_storage.ledger_map ) in
	let lqt_supply = get_token_supply ( pool_token_ids.lqt_token_id, token_storage.supply_map ) in
	{
		reserves = {
			token_a = yes_balance;
			token_b = no_balance;
		};
		liquidity_supply = lqt_supply;
	}

let execute_add_lqt ( lqt_amount, token_amounts, pool_token_ids, token_storage : nat * token_pair * pool_token_ids * token_storage ) : token_storage =
	let pair_address = Tezos.self_address in
	let client_address = Tezos.sender in
	let token_storage = token_mint_to_account ( {
		dst = client_address;
		token_id = pool_token_ids.lqt_token_id;
		amount = lqt_amount;
	}, token_storage ) in
	let ledger_map = token_transfer_internal ( {
		src = client_address;
		tx = {
			dst = pair_address;
			token_id = pool_token_ids.yes_token_id;
			amount = token_amounts.token_a;
		};
	}, token_storage.ledger_map ) in
	let ledger_map = token_transfer_internal ( {
		src = client_address;
		tx = {
			dst = pair_address;
			token_id = pool_token_ids.no_token_id;
			amount = token_amounts.token_b;
		};
	}, ledger_map ) in
	{ token_storage with ledger_map = ledger_map; }

let execute_remove_lqt ( lqt_amount, token_amounts, pool_token_ids, token_storage : nat * token_pair * pool_token_ids * token_storage ) : token_storage =
	let pair_address = Tezos.self_address in
	let client_address = Tezos.sender in
	let token_storage = token_burn_from_account ( {
		src = client_address;
		tx = { 
			token_id = pool_token_ids.lqt_token_id;
			amount = lqt_amount;
		};
	}, token_storage ) in
	let ledger_map = token_transfer_internal ( {
		src = pair_address;
		tx = {
			dst = client_address;
			token_id = pool_token_ids.yes_token_id;
			amount = token_amounts.token_a;
		};
	}, token_storage.ledger_map ) in
	let ledger_map = token_transfer_internal ( {
		src = pair_address;
		tx = {
			dst = client_address;
			token_id = pool_token_ids.no_token_id;
			amount = token_amounts.token_b;
		};
	}, ledger_map ) in
	{ token_storage with ledger_map = ledger_map; }

») m4_dnl