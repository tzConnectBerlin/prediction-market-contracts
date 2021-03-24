m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET»,,«m4_define(«MARKET»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,maths_interface.mligo.m4) m4_dnl

let err_NO_SUCH_MARKET = "No such market"
let err_MARKET_NOT_BOOTSTRAPPED = "Market not bootstrapped"
let err_MARKET_ALREADY_RESOLVED = "Market has already been resolved"

let check_is_market_still_open ( bootstrapped_market_data : bootstrapped_market_data ) : unit =
	match bootstrapped_market_data.resoltion with
	| Some u -> ( failwith err_MARKET_ALREADY_RESOLVED )
	| None -> unit

let get_market ( market_id, market_map : market_id * market_map ) : market_data =
	match Big_map.find_opt market_id market_map with
	| None -> ( failwith err_NO_SUCH_MARKET : market_data )
	| Some e -> e

let get_bootstrapped_market_data ( market_data : market_data ) : bootstrapped_market_data =
	match market_data.state with
	| MarketBootstrapped e -> e
	| AuctionRunning u -> ( failwith err_MARKET_NOT_BOOTSTRAPPED : bootstrapped_market_data )

let save_bootstrapped_market_data ( bootstrapped_market_data, market_data : bootstrapped_market_data * market_data ) : market_data =
	{ market_data with state = MarketBootstrapped(bootstrapped_market_data); }

let save_market ( market_id, market_data, market_map : market_id * market_data * market_map ) : market_map =
	Big_map.update market_id ( Some(market_data) ) market_map

») m4_dnl