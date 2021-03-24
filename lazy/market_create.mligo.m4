m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_CREATE»,,«m4_define(«MARKET_CREATE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,market_interface.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,external_token.mligo.m4) m4_dnl

let err_MARKET_EXISTS = "Market already exists"

let initialize_auction ( auction_period_end, bet : timestamp * bet ) : auction_data =
	let bet_details = calculate_bet_details bet in
	{
		auction_period_end = auction_period_end;
		quantity = bet.quantity;
		yes_preference = bet_details.yes_preference;
		uniswap_contribution = bet_details.uniswap_contribution;
	}

let check_market_id_availability ( market_id, market_map : market_id * market_map ) : unit =
	match Big_map.find_opt market_id market_map with
	| Some u -> failwith err_MARKET_EXISTS
	| None -> unit

let create_market ( create_market_params, market_storage : create_market_params * market_storage ) : operation list * market_storage =
	let u = check_market_id_availability ( create_market_params.market_id, market_storage.market_map ) in
	let auction_data = initialize_auction ( create_market_params.auction_period_end, create_market_params.bet ) in
	let market_data : market_data = {
		metadata = create_market_params.metadata;
		state = AuctionRunning(auction_data);
	} in
	let market_map = save_market ( create_market_params.market_id, market_data, market_storage.market_map ) in
	let auction_bet_id : auction_bet_id = {
		originator = Tezos.sender;
		market_id = create_market_params.market_id;
	} in
	let auction_bet_map = save_auction_bet ( auction_bet_id, create_market_params.bet, market_storage.auction_bet_map ) in
	let pull_payment = get_pull_payment ( create_market_params.metadata.currency, create_market_params.bet.quantity ) in
	[ pull_payment ], { market_storage with
		market_map = market_map;
		auction_bet_map = auction_bet_map;
	}

») m4_dnl
