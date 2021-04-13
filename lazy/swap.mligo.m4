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
	let lqt_ratio = div_nat_nat lqt_amount liquidity_pool.liquidity_supply err_INTERNAL in
	let token_a = floor ( mul_fp_nat lqt_ratio liquidity_pool.reserves.token_a ) in
	let token_b = floor ( mul_fp_nat lqt_ratio liquidity_pool.reserves.token_b ) in
	{
		token_a = token_a;
		token_b = token_b;
	}

let calc_fixed_input_swap ( token_a_in, token_pair : nat * token_pair ) : nat =
	let numerator = mul_nat_nat ( mul_nat_nat token_a_in token_pair.token_b ) swap_fee_numerator in
	let denominator = add_nat_nat ( mul_nat_nat token_pair.token_a swap_fee_denominator ) ( mul_nat_nat token_a_in swap_fee_numerator ) in
	div_nat_nat_floor numerator denominator err_INTERNAL

») m4_dnl