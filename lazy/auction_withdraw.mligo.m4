m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_WITHDRAW»,,«m4_define(«AUCTION_WITHDRAW»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,token.mligo.m4) m4_dnl
m4_loadfile(.,market_token_ids.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,lqt_rewards.mligo.m4) m4_dnl

let err_NOT_A_LIQUIDITY_PROVIDER = "Caller has not provided liquidity or participated in the auction"

type auction_withdraw_numbers =
[@layout:comb]
{
	quantity : nat;
	liquidity_share : nat;
	yes_token_withdrawable : nat;
	no_token_withdrawable : nat;
}

let do_auction_withdraw_calculations ( bet, bootstrapped_market_data : bet * bootstrapped_market_data ) : auction_withdraw_numbers =
	let bootstrap_yes_probability = bootstrapped_market_data.bootstrap_yes_probability in
	let bootstrap_no_probability = complement bootstrap_yes_probability m4_debug_err("bootstrap_no_probability@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let bet_yes_preference = calculate_yes_preference bet in
	let bet_no_preference = calculate_no_preference bet in
	let bet_uniswap_contribution = ( min_fp bet_yes_preference bet_no_preference ) in
	let yes_token_alloc = div_fp_fp_floor bet_yes_preference bootstrap_yes_probability m4_debug_err("yes_token_alloc@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let yes_token_contributed = div_fp_fp_floor bet_uniswap_contribution bootstrap_yes_probability m4_debug_err("yes_token_contributed@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let yes_token_withdrawable = sub_nat_nat yes_token_alloc yes_token_contributed m4_debug_err("yes_token_withdrawable@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let no_token_alloc = div_fp_fp_floor bet_no_preference bootstrap_no_probability m4_debug_err("no_token_alloc@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let no_token_contributed = div_fp_fp_floor bet_uniswap_contribution bootstrap_no_probability m4_debug_err("no_token_contributed@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
	let no_token_withdrawable = sub_nat_nat no_token_alloc no_token_contributed m4_debug_err("no_token_withdrawable@mint_do_auction_withdraw_calculationstokens@auction_withdraw.mligo.m4") in
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
	token_release_to_account ( {
		dst = args.caller;
		token_id = get_liquidity_token_id args.market_id;
		amount = auction_withdraw_numbers.liquidity_share;
	}, token_storage )

let withdraw_lqt_reward_tokens ( lqt_provider_id, last_update, bootstrapped_market_data, token_storage :
		lqt_provider_id * nat * bootstrapped_market_data * token_storage ) :
		bootstrapped_market_data * token_storage * nat =
	let provider_address = lqt_provider_id.originator in
	let level = get_current_liquidity_activity_level bootstrapped_market_data in
	let market_id = lqt_provider_id.market_id in
	let lqt_token_id = get_liquidity_token_id market_id in
	let lqt_reward_token_id = get_liquidity_reward_token_id market_id in
	//
	// Update supply
	let ( bootstrapped_market_data, new_supply_map ) = update_lqt_reward_supply_internal ( {
		level = level;
		lqt_token_id = lqt_token_id;
		lqt_reward_token_id = lqt_reward_token_id;
	}, bootstrapped_market_data, token_storage.supply_map ) in
	let token_storage = { token_storage with supply_map = new_supply_map } in
	//
	// Withdraw tokens from updated supply
	let token_storage = withdraw_lqt_reward_tokens_internal ( {
		level = level;
		last_update = last_update;
		provider_address = provider_address;
		lqt_token_id = lqt_token_id;
		lqt_reward_token_id = lqt_reward_token_id;
	}, token_storage ) in
	bootstrapped_market_data, token_storage, level

let withdraw_reserve_tokens ( market_id, business_storage : market_id * business_storage ) : business_storage =
	let caller = Tezos.sender in
	let lqt_provider_id : lqt_provider_id = {
		originator = caller;
		market_id = market_id;
	} in
	let liquidity_provider_map = business_storage.markets.liquidity_provider_map in
	match ( Big_map.find_opt lqt_provider_id liquidity_provider_map ) with
	| None -> ( failwith err_NOT_A_LIQUIDITY_PROVIDER : business_storage )
	| Some lqt_provider_details -> (
		let market_map = business_storage.markets.market_map in
		let market_data = get_market ( market_id, market_map ) in
		let bootstrapped_market_data = get_bootstrapped_market_data ( market_data ) in
 		let ( token_storage, liquidity_reward_updated_at ) = match lqt_provider_details with
		| Bet bet -> (
			let auction_withdraw_numbers = do_auction_withdraw_calculations ( bet, bootstrapped_market_data ) in
			( transfer_auction_tokens ( {
				caller = caller;
				market_id = market_id;
			}, auction_withdraw_numbers, business_storage.tokens ) ),
			bootstrapped_market_data.bootstrapped_at_block )
		| Liquidity_reward_updated_at l -> ( business_storage.tokens, l ) in
		let ( bootstrapped_market_data, token_storage, update_level ) = withdraw_lqt_reward_tokens ( lqt_provider_id, liquidity_reward_updated_at, bootstrapped_market_data, token_storage ) in
		let liquidity_provider_map = save_lqt_provider_update_level ( lqt_provider_id, update_level, liquidity_provider_map ) in
		let market_data = save_bootstrapped_market_data ( bootstrapped_market_data, market_data ) in
		let market_map = save_market ( market_id, market_data, market_map ) in
		{ business_storage with
			markets.liquidity_provider_map = liquidity_provider_map;
			markets.market_map = market_map;
			tokens = token_storage;
		}
	)	

») m4_dnl
