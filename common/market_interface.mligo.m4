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
	auction_reward_currency_pool : nat;
}

type resolution_data =
[@layout:comb]
{
	winning_prediction : bool; // Which outcome won - yes or no === true or false
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
}

//
// Call argument types
//

type bet_params =
[@layout:comb]
{
  market_id : market_id;
  bet : bet;
}

type create_market_params =
[@layout:comb]
{
	market_id : market_id;
	metadata : market_metadata;
	auction_period_end : timestamp;
	bet : bet;
}

type resolve_market_params =
[@layout:comb]
{
	market_id : market_id;
	winning_prediction : bool;
}

type market_trade_params =
[@layout:comb]
{
	market_id : market_id;
	amount : nat;
}

type directional_market_trade_params =
[@layout:comb]
{
	token_to_sell : bool;
	params : market_trade_params;
}

») m4_dnl