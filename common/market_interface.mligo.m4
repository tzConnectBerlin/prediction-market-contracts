m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_INTERFACE»,,«m4_define(«MARKET_INTERFACE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths_interface.mligo.m4) m4_dnl
m4_loadfile(.,external_token_interface.mligo.m4) m4_dnl

//
// Storage types
//

// Market state machine

type auction_data =
[@layout:comb]
{
	auction_period_end : timestamp;
	quantity : nat;
	yes_preference : fixedpoint;
	uniswap_contribution : fixedpoint;
}

type currency_pool =
[@layout_comb]
{
	market_currency_pool : nat;
	liquidity_reward_currency_pool : nat;
	creator_reward_currency_pool : nat;
}

type outcome_type =
	| Yes
	| No

type resolution_data =
[@layout:comb]
{
	winning_prediction : outcome_type;
	resolved_at_block : nat;
}

type bootstrapped_market_data =
[@layout:comb]
{
	currency_pool : currency_pool;
	bootstrap_yes_probability : fixedpoint;
	bootstrapped_at_block : nat;
	liquidity_reward_supply_updated_at_block : nat;
	resolution : resolution_data option;
}

type market_state =
	| AuctionRunning of auction_data
	| MarketBootstrapped of bootstrapped_market_data

// Describing a market

type market_metadata =
[@layout:comb]
{
	ipfs_hash : string option;
	description : string;
	adjudicator : address;
	currency : external_token;
}

type market_data =
[@layout:comb]
{
	metadata : market_metadata;
	state : market_state;
}

// Big map of markets

type market_id = nat

type market_map = ( market_id, market_data ) big_map

// Bets (auction bets need to be saved)

type bet =
[@layout:comb]
{
	predicted_probability : fixedpoint;
	quantity : nat;
}

type lqt_provider_id =
[@layout:comb]
{
	originator : address;
	market_id : market_id;
}

type lqt_provider_details =
	| Bet of bet
	| Liquidity_reward_updated_at of nat
	
type liquidity_provider_map = ( lqt_provider_id, lqt_provider_details ) big_map

// The root storage for markets

type market_storage =
[@layout:comb]
{
	market_map : market_map;
	liquidity_provider_map : liquidity_provider_map;
	create_restriction : address option;
}

//
// Call argument types
//

type operation_details =
[@layout:comb]
{
	execution_deadline : timestamp;
	market_id : market_id;
}

type create_market_args =
[@layout:comb]
{
	operation_details : operation_details;
	metadata : market_metadata;
	auction_period_end : timestamp;
	bet : bet;
}

type bet_args =
[@layout:comb]
{
  operation_details : operation_details;
  bet : bet;
}

type resolve_market_args =
[@layout:comb]
{
	market_id : market_id;
	winning_prediction : outcome_type;
}

type direction =
	| Mint
	| Burn

type enter_exit_args =
[@layout:comb]
{
	operation_details : operation_details;
	direction : direction;
	amount : nat;
}

type token_trade_args =
[@layout:comb]
{
	operation_details : operation_details;
	token_to_sell : outcome_type;
	fixed_input : nat;
	min_output : nat;
}

type token_pair =
[@layout:comb]
{
	token_a : nat; // Yes token
	token_b : nat; // No token
}

type add_liquidity_args =
[@layout:comb]
{
	operation_details : operation_details;
	intended_token_amounts : token_pair;
	min_token_amounts : token_pair;
}

type remove_liquidity_args =
[@layout:comb]
{
	operation_details : operation_details;
	amount : nat;
	min_token_amounts : token_pair;
}

») m4_dnl