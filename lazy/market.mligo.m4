m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET»,,«m4_define(«MARKET»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl

let err_NO_SUCH_MARKET = "No such market"
let err_MARKET_NOT_BOOTSTRAPPED = "Market not bootstrapped"
let err_MARKET_NOT_RESOLVED = "Market not resolved"
let err_MARKET_ALREADY_RESOLVED = "Market has already been resolved"

let check_is_market_still_open ( bootstrapped_market_data : bootstrapped_market_data ) : unit =
	match bootstrapped_market_data.resolution with
	| Some _ -> ( failwith err_MARKET_ALREADY_RESOLVED )
	| None -> unit

let get_market ( market_id, market_map : market_id * market_map ) : market_data =
	match Big_map.find_opt market_id market_map with
	| None -> ( failwith err_NO_SUCH_MARKET : market_data )
	| Some e -> e

let get_bootstrapped_market_data ( market_data : market_data ) : bootstrapped_market_data =
	match market_data.state with
	| MarketBootstrapped e -> e
	| AuctionRunning _ -> ( failwith err_MARKET_NOT_BOOTSTRAPPED : bootstrapped_market_data )

let increment_currency_pool ( currency_pool, bootstrapped_market_data : currency_pool * bootstrapped_market_data ) : bootstrapped_market_data =
	let currency_pool : currency_pool = {
		market_currency_pool = ( add_nat_nat currency_pool.market_currency_pool bootstrapped_market_data.currency_pool.market_currency_pool );
		liquidity_reward_currency_pool = ( add_nat_nat currency_pool.liquidity_reward_currency_pool bootstrapped_market_data.currency_pool.liquidity_reward_currency_pool );
		creator_reward_currency_pool = ( add_nat_nat currency_pool.creator_reward_currency_pool bootstrapped_market_data.currency_pool.creator_reward_currency_pool );
	} in
	{ bootstrapped_market_data with currency_pool = currency_pool; }

let save_bootstrapped_market_data ( bootstrapped_market_data, market_data : bootstrapped_market_data * market_data ) : market_data =
	{ market_data with state = MarketBootstrapped(bootstrapped_market_data); }

let save_market ( market_id, market_data, market_map : market_id * market_data * market_map ) : market_map =
	Big_map.update market_id ( Some(market_data) ) market_map

») m4_dnl