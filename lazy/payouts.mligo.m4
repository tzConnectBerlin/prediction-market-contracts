m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«PAYOUTS»,,«m4_define(«PAYOUTS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl

let reward_denominator = 100n
let liquidity_reward_numerator = 4n
//let auction_reward_numerator = 1n 

type payout_params =
[@layout:comb]
{
	quantity : nat;
	token_supply : nat;
	currency_pool : nat;
}

type payout_result =
[@layout:comb]
{
	currency_payout : nat;
	new_currency_pool : nat;
}

let calculate_payout ( payout : payout_params ) : payout_result =
	if ( payout.quantity = 0n ) then
		{
			currency_payout = 0n;
			new_currency_pool = payout.currency_pool;
		}
	else (
		let numerator = mul_nat_nat payout.currency_pool payout.quantity in
		let currency_payout = div_nat_nat_floor numerator payout.token_supply m4_debug_err("currency_payout@calculate_payout@payouts.mligo.m4") in
		let new_currency_pool = sub_nat_nat payout.currency_pool currency_payout m4_debug_err("new_currency_pool@calculate_payout@payouts.mligo.m4") in
		{
			currency_payout = currency_payout;
			new_currency_pool = new_currency_pool;
		}
	)

let split_revenue ( quantity : nat ) : currency_pool =
	let liquidity_reward_currency_pool = div_nat_nat_floor ( mul_nat_nat quantity liquidity_reward_numerator ) reward_denominator m4_debug_err("liquidity_reward_currency_pool@split_revenue@payouts.mligo.m4") in
	let auction_reward_currency_pool = div_nat_nat_floor quantity reward_denominator m4_debug_err("auction_reward_currency_pool@split_revenue@payouts.mligo.m4") in
	let market_currency_pool = sub_nat_nat quantity ( add_nat_nat liquidity_reward_currency_pool auction_reward_currency_pool ) m4_debug_err("market_currency_pool@split_revenue@payouts.mligo.m4") in
	{
		market_currency_pool = market_currency_pool;
		liquidity_reward_currency_pool = liquidity_reward_currency_pool;
		auction_reward_currency_pool = auction_reward_currency_pool;
	}


») m4_dnl