m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«LQT_REWARDS»,,«m4_define(«LQT_REWARDS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl

let err_BET_NOT_WITHDRAWN = "Withdraw auction bet before further liquidity operations"

let get_current_liquidity_activity_level ( bootstrapped_market_data : bootstrapped_market_data ) : nat =
	match bootstrapped_market_data.resolution with
	| None -> Tezos.level
	| Some e -> add_nat_nat e.resolved_at_block 1n // Count the resolution block for liquidity rewards - we need this if the market is resolved directly from auction

let save_lqt_provider_update_level ( lqt_provider_id, level, liquidity_provider_map : lqt_provider_id * nat * liquidity_provider_map ) : liquidity_provider_map =
	Big_map.update lqt_provider_id ( Some( Liquidity_reward_updated_at( level ) ) ) liquidity_provider_map

type update_lqt_reward_supply_internal_args =
{
	level : nat;
	lqt_token_id : token_id;
	lqt_reward_token_id : token_id;
}

let update_lqt_reward_supply_internal ( args, bootstrapped_market_data, supply_map : update_lqt_reward_supply_internal_args * bootstrapped_market_data * supply_map ) : bootstrapped_market_data * supply_map =
	let blocks_elapsed = sub_nat_nat args.level bootstrapped_market_data.liquidity_reward_supply_updated_at_block m4_debug_err("blocks_elapsed@update_lqt_reward_supply_internal@lqt_rewards.mligo.m4") in
	let lqt_supply = get_token_supply ( args.lqt_token_id, supply_map ) in
	let lqt_reward_to_mint = mul_nat_nat blocks_elapsed lqt_supply in
	let supply_map = token_mint_to_reserve ( {
		token_id = args.lqt_reward_token_id;
		amount = lqt_reward_to_mint; }, supply_map ) in
	{ bootstrapped_market_data with liquidity_reward_supply_updated_at_block = args.level; }, supply_map

let update_lqt_reward_supply ( market_id, bootstrapped_market_data, supply_map : market_id * bootstrapped_market_data * supply_map ) : bootstrapped_market_data * supply_map =
	let level = get_current_liquidity_activity_level bootstrapped_market_data in
	let lqt_token_id = get_liquidity_token_id market_id in
	let lqt_reward_token_id = get_liquidity_reward_token_id market_id in
	update_lqt_reward_supply_internal ( {
		level = level;
		lqt_token_id = lqt_token_id;
		lqt_reward_token_id = lqt_reward_token_id;
	}, bootstrapped_market_data, supply_map )

type withdraw_lqt_reward_tokens_internal_args =
{
	level : nat;
	last_update : nat;
	provider_address : address;
	lqt_token_id : token_id;
	lqt_reward_token_id : token_id;
}

let withdraw_lqt_reward_tokens_internal ( args, token_storage : withdraw_lqt_reward_tokens_internal_args * token_storage ) : token_storage =
	let blocks_elapsed = sub_nat_nat args.level args.last_update m4_debug_err("blocks_elapsed@withdraw_lqt_reward_tokens_internal@lqt_rewards.mligo.m4") in
	let lqt_balance = get_token_balance ( { 
		token_id = args.lqt_token_id;
		owner = args.provider_address;
	}, token_storage.ledger_map ) in
	let lqt_reward_to_withdraw = mul_nat_nat blocks_elapsed lqt_balance in
	token_release_to_account ( {
		token_id = args.lqt_reward_token_id;
		amount = lqt_reward_to_withdraw;
		dst = args.provider_address;
	}, token_storage )

let update_lqt_reward ( lqt_provider_id, bootstrapped_market_data, liquidity_provider_map, token_storage :
		lqt_provider_id * bootstrapped_market_data * liquidity_provider_map * token_storage ) :
		bootstrapped_market_data * liquidity_provider_map * token_storage =
	let level = get_current_liquidity_activity_level bootstrapped_market_data in
	let lqt_token_id = get_liquidity_token_id lqt_provider_id.market_id in
	let lqt_reward_token_id = get_liquidity_reward_token_id lqt_provider_id.market_id in
	let ( bootstrapped_market_data, new_supply_map ) = update_lqt_reward_supply_internal ( {
		level = level;
		lqt_token_id = lqt_token_id;
		lqt_reward_token_id = lqt_reward_token_id;
	}, bootstrapped_market_data, token_storage.supply_map ) in
	let token_storage = { token_storage with supply_map = new_supply_map } in
	let new_liquidity_provider_map = save_lqt_provider_update_level ( lqt_provider_id, level, liquidity_provider_map ) in
	match ( Big_map.find_opt lqt_provider_id liquidity_provider_map ) with
	| None -> ( bootstrapped_market_data, new_liquidity_provider_map, token_storage )
	| Some e -> ( match e with
		| Bet _ -> ( failwith err_BET_NOT_WITHDRAWN : bootstrapped_market_data * liquidity_provider_map * token_storage )
		| Liquidity_reward_updated_at last_update -> (
			let token_storage = withdraw_lqt_reward_tokens_internal ( {
				level = level;
				last_update = last_update;
				provider_address = lqt_provider_id.originator;
				lqt_token_id = lqt_token_id;
				lqt_reward_token_id = lqt_reward_token_id;
			}, token_storage ) in
			( bootstrapped_market_data, new_liquidity_provider_map, token_storage )
		)
	)

») m4_dnl