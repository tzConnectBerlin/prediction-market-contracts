m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_CREATE»,,«m4_define(«MARKET_CREATE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,market_interface.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,external_token.mligo.m4) m4_dnl

let err_MARKET_EXISTS = "Market already exists"
let err_CREATE_NOT_ALLOWED = "Market creation not allowed for caller"

m4_define(«CREATOR_TOKEN_DECIMALS»,«18») m4_dnl
let creator_reward_token_supply = m4_bc(10^CREATOR_TOKEN_DECIMALS())n

let mint_creator_reward_tokens ( market_id, token_storage : market_id * token_storage ) : token_storage =
	token_mint_to_account ( {
		dst = Tezos.sender;
		amount = creator_reward_token_supply;
		token_id = ( get_creator_reward_token_id market_id );
	}, token_storage )

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
	| Some _ -> failwith err_MARKET_EXISTS
	| None -> unit

let check_market_create_permission ( market_storage : market_storage ) : unit =
	match market_storage.create_restriction with
	| None -> unit
	| Some e -> if ( e = Tezos.sender ) then
		unit
	else
		failwith err_CREATE_NOT_ALLOWED

let create_market ( create_market_args, business_storage : create_market_args * business_storage ) : operation list * business_storage =
	let _ = check_execution_deadline create_market_args.operation_details.execution_deadline in
	let market_id = create_market_args.operation_details.market_id in
	let market_storage = business_storage.markets in
	let _ = check_market_create_permission market_storage in
	let _ = check_market_id_availability ( market_id, market_storage.market_map ) in
	let auction_data = initialize_auction ( create_market_args.auction_period_end, create_market_args.bet ) in
	let market_data : market_data = {
		metadata = create_market_args.metadata;
		state = AuctionRunning(auction_data)
	} in
	let market_map = save_market ( market_id, market_data, market_storage.market_map ) in
	let lqt_provider_id : lqt_provider_id = {
		originator = Tezos.sender;
		market_id = market_id;
	} in
	let liquidity_provider_map = save_auction_bet ( lqt_provider_id, create_market_args.bet, market_storage.liquidity_provider_map ) in
	let market_storage = { market_storage with
		market_map = market_map;
		liquidity_provider_map = liquidity_provider_map;
	} in
	let token_storage = mint_creator_reward_tokens ( market_id, business_storage.tokens ) in
	let pull_payment = get_pull_payment ( create_market_args.metadata.currency, create_market_args.bet.quantity ) in
	[ pull_payment ], { business_storage with
		markets = market_storage;
		tokens = token_storage; }

») m4_dnl
