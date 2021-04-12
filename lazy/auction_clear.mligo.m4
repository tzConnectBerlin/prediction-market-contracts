m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_CLEAR»,,«m4_define(«AUCTION_CLEAR»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,payouts.mligo.m4) m4_dnl

let err_CANT_CLEAR_BEFORE_END = "Can't clear market before auction end date"

let check_auction_end_date ( auction_data : auction_data ) : unit =
	if ( Tezos.now < auction_data.auction_period_end ) then
		failwith err_CANT_CLEAR_BEFORE_END
	else
		unit

let clearing_yes_probability ( auction_data : auction_data ) : fixedpoint =
	div_fp_nat auction_data.yes_preference auction_data.quantity err_INTERNAL

type clearing_numbers =
[@layout:comb]
{
	total_quantity : nat;
	clearing_yes_probability : fixedpoint;
	yes_contributed_to_swap : nat;
	no_contributed_to_swap : nat;
	lqt_in_swap : nat;
}

let do_clearing_calculations ( auction_data : auction_data ) : clearing_numbers =
	let clearing_yes_probability = clearing_yes_probability auction_data in
	let clearing_no_probability = complement clearing_yes_probability err_INTERNAL in
	let yes_contributed_to_swap = div_fp_fp_floor auction_data.uniswap_contribution clearing_yes_probability err_INTERNAL in
	let no_contributed_to_swap = div_fp_fp_floor auction_data.uniswap_contribution clearing_no_probability err_INTERNAL in
	{
		total_quantity = auction_data.quantity;
		clearing_yes_probability = clearing_yes_probability;
		yes_contributed_to_swap = yes_contributed_to_swap;
		no_contributed_to_swap = no_contributed_to_swap;
		lqt_in_swap = floor auction_data.uniswap_contribution;
	}

let mint_tokens ( market_id, clearing_numbers, token_storage : market_id * clearing_numbers * token_storage ) : token_storage =
	let self = Tezos.self_address in
	let yes_token_id = get_yes_token_id market_id in
	let no_token_id = get_no_token_id market_id in
	let yes_token_in_reserve = sub_nat_nat clearing_numbers.total_quantity clearing_numbers.yes_contributed_to_swap err_INTERNAL in
	let no_token_in_reserve = sub_nat_nat clearing_numbers.total_quantity clearing_numbers.no_contributed_to_swap err_INTERNAL in
	let token_storage = token_mint_to_account ( {
		amount = clearing_numbers.yes_contributed_to_swap;
		dst = self;
		token_id = yes_token_id;
		}, token_storage ) in
	let token_storage = token_mint_to_account ( {
		amount = clearing_numbers.no_contributed_to_swap;
		dst = self;
		token_id = no_token_id;
		}, token_storage ) in
	let supply_map = token_mint_to_reserve ( {
		amount = yes_token_in_reserve;
		token_id = ( get_yes_token_id market_id );
	}, token_storage.supply_map ) in
	let supply_map = token_mint_to_reserve ( {
		amount = no_token_in_reserve;
		token_id = ( get_no_token_id market_id );
	}, supply_map ) in
	let supply_map = token_mint_to_reserve ( {
		amount = clearing_numbers.lqt_in_swap;
		token_id = ( get_liquidity_token_id market_id );
	}, supply_map ) in
//	let supply_map = token_mint_to_reserve ( {
//		amount = clearing_numbers.lqt_in_swap;
//		token_id = ( get_liquidity_reward_token_id market_id );
//	}, supply_map ) in
	let supply_map = token_mint_to_reserve ( {
		amount = clearing_numbers.total_quantity;
		token_id = ( get_auction_reward_token_id market_id );
	}, supply_map ) in
	{ token_storage with supply_map = supply_map; }

let set_market_state_cleared ( market_id, auction_data, token_storage : market_id * auction_data * token_storage ) : bootstrapped_market_data * token_storage =
	let clearing_numbers = do_clearing_calculations auction_data in
	let currency_pool = split_revenue clearing_numbers.total_quantity in
	let level = Tezos.level in
	let bootstrapped_market_data : bootstrapped_market_data = {
		currency_pool = currency_pool;
		bootstrap_yes_probability = clearing_numbers.clearing_yes_probability;
		bootstrapped_at_block = level;
		liquidity_reward_supply_updated_at_block = level;
		resolution = ( None : resolution_data option );
	} in
	let token_storage = mint_tokens ( market_id, clearing_numbers, token_storage ) in
	bootstrapped_market_data, token_storage

let clear_auction ( market_id, business_storage : market_id * business_storage ) : operation list * business_storage =
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_id, market_map ) in
	let auction_data = get_auction_data market_data in
	let _ = check_auction_end_date auction_data in
	let bootstrapped_market_data, token_storage = set_market_state_cleared ( market_id, auction_data, business_storage.tokens ) in
	let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
	let market_map = save_market ( market_id, market_data, market_map ) in
	( [] : operation list ), { business_storage with
		tokens = token_storage;
		markets.market_map = market_map;
	}

») m4_dnl
