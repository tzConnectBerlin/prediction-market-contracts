m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_WITHDRAW»,,«m4_define(«AUCTION_WITHDRAW»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,meta.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl

type auction_withdraw_numbers =
[@layout:comb]
{
	quantity : nat;
	liquidity_share : nat;
	yes_token_withdrawable : nat;
	no_token_withdrawable : nat;
}

let do_withdraw_calculations ( bet, bootstrapped_market_data : bet * bootstrapped_market_data ) : auction_withdraw_numbers =
	let bootstrap_yes_probability = bootstrapped_market_data.bootstrap_yes_probability in
	let bootstrap_no_probability = complement bootstrap_yes_probability err_INTERNAL in
	let bet_yes_preference = calculate_yes_preference bet in
	let bet_no_preference = calculate_no_preference bet in
	let bet_uniswap_contribution = ( min_fp bet_yes_preference bet_no_preference ) in
	let yes_token_alloc = div_fp_fp_floor bet_yes_preference bootstrap_yes_probability err_INTERNAL in
	let yes_token_contributed = div_fp_fp_floor bet_uniswap_contribution bootstrap_yes_probability err_INTERNAL in
	let yes_token_withdrawable = sub_nat_nat yes_token_alloc yes_token_contributed err_INTERNAL in
	let no_token_alloc = div_fp_fp_floor bet_no_preference bootstrap_no_probability err_INTERNAL in
	let no_token_contributed = div_fp_fp_floor bet_uniswap_contribution bootstrap_no_probability err_INTERNAL in
	let no_token_withdrawable = sub_nat_nat no_token_alloc no_token_contributed err_INTERNAL in
	{
		quantity = bet.quantity;
		liquidity_share = floor bet_uniswap_contribution;
		yes_token_withdrawable = yes_token_withdrawable;
		no_token_withdrawable = no_token_withdrawable;
	}

type transfer_auction_tokens_args =
[@layout:comb]
{
	caller : address;
	market_id : market_id;
}

let transfer_auction_tokens ( args, auction_withdraw_numbers, token_storage : transfer_auction_tokens_args * auction_withdraw_numbers * token_storage ) : token_storage =
	let token_storage = if ( auction_withdraw_numbers.yes_token_withdrawable > 0n ) then
		token_release_to_account ( {
			dst = args.caller;
			token_id = get_yes_token_id args.market_id;
			amount = auction_withdraw_numbers.yes_token_withdrawable;
		}, token_storage )
	else ( token_storage ) in
	let token_storage = if ( auction_withdraw_numbers.no_token_withdrawable > 0n ) then
		token_release_to_account ( {
			dst = args.caller;
			token_id = get_no_token_id args.market_id;
			amount = auction_withdraw_numbers.no_token_withdrawable;
		}, token_storage )
	else ( token_storage ) in
	let token_storage = token_release_to_account ( {
		dst = args.caller;
		token_id = get_liquidity_token_id args.market_id;
		amount = auction_withdraw_numbers.liquidity_share;
	}, token_storage ) in
	let token_storage = token_release_to_account ( {
		dst = args.caller;
		token_id = get_liquidity_reward_token_id args.market_id;
		amount = auction_withdraw_numbers.liquidity_share;
	}, token_storage ) in
	token_release_to_account ( {
		dst = args.caller; 
		token_id = get_auction_reward_token_id args.market_id;
		amount = auction_withdraw_numbers.quantity;
	}, token_storage )

let withdraw_tokens_from_auction ( market_id, business_storage : market_id * business_storage ) : operation list * business_storage =
	let caller = Tezos.sender in
	let market_map = business_storage.markets.market_map in
	let market_data = get_market ( market_id, market_map ) in
	let bootstrapped_market_data = get_bootstrapped_market_data ( market_data ) in
	let auction_bet_map = business_storage.markets.auction_bet_map in
	let auction_bet_id : auction_bet_id = {
		originator = caller;
		market_id = market_id;
	} in
	let bet = get_auction_bet ( auction_bet_id, auction_bet_map ) in
	let auction_withdraw_numbers = do_withdraw_calculations ( bet, bootstrapped_market_data ) in
	let token_storage = transfer_auction_tokens ( {
		caller = caller;
		market_id = market_id;
	}, auction_withdraw_numbers, business_storage.tokens ) in
	let auction_bet_map = delete_auction_bet ( auction_bet_id, auction_bet_map ) in
	( [] : operation list ), { business_storage with
		markets.auction_bet_map = auction_bet_map;
		tokens = token_storage;
	}

») m4_dnl
