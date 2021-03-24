m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«PAYOUTS»,,«m4_define(«PAYOUTS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl

let reward_denominator = 100n
let liquidity_reward_numerator = 4n
//let auction_reward_numerator = 1n 

type payout_numbers =
[@layout:comb]
{
	quantity : nat;
	token_supply : nat;
	currency_pool : nat;
}

let calculate_payout ( payout : payout_numbers ) : payout_numbers =
	let numerator = mul_nat_nat payout.currency_pool payout.quantity in
	let currency_payout = div_nat_nat_floor numerator payout.token_supply err_INTERNAL in
	let new_currency_pool = sub_nat_nat payout.currency_pool currency_payout err_INTERNAL in
	let new_token_supply = sub_nat_nat payout.token_supply payout.quantity err_INTERNAL in
	{
		quantity = currency_payout;
		token_supply = new_token_supply;
		currency_pool = new_currency_pool;
	}

let split_revenue ( quantity : nat ) : currency_pool =
	let liquidity_reward_currency_pool = div_nat_nat_floor ( mul_nat_nat quantity liquidity_reward_numerator ) reward_denominator err_INTERNAL in
	let auction_reward_currency_pool = div_nat_nat_floor quantity reward_denominator err_INTERNAL in
	let market_currency_pool = sub_nat_nat quantity ( add_nat_nat liquidity_reward_currency_pool auction_reward_currency_pool ) err_INTERNAL in
	{
		market_currency_pool = market_currency_pool;
		liquidity_reward_currency_pool = liquidity_reward_currency_pool;
		auction_reward_currency_pool = auction_reward_currency_pool;
	}


») m4_dnl