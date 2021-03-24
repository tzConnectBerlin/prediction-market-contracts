m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION_BET»,,«m4_define(«AUCTION_BET»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,market_interface.mligo.m4) m4_dnl
m4_loadfile(.,common_error.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl
m4_loadfile(.,market.mligo.m4) m4_dnl
m4_loadfile(.,auction.mligo.m4) m4_dnl
m4_loadfile(.,external_token.mligo.m4) m4_dnl

//FIXME: This math may be simplifiable
// First it should test correct, and then we can optimize over unit tests
let update_auction_totals ( old_bet, new_bet, auction_data : bet * bet * auction_data ) : bet * auction_data =
	let old_bet_details = calculate_bet_details old_bet in
	let merged_bet_quantity = add_nat_nat old_bet.quantity new_bet.quantity in
	let new_bet_yes_preference = calculate_yes_preference new_bet in
	let merged_bet_yes_preference = add_fp_fp old_bet_details.yes_preference new_bet_yes_preference in
	let merged_predicted_probability = div_fp_nat merged_bet_yes_preference merged_bet_quantity err_INVALID_AMOUNT in
	let merged_bet = {
		quantity = merged_bet_quantity;
		predicted_probability = merged_predicted_probability;
	} in
	let new_uniswap_contribution = calculate_uniswap_contrib merged_bet in
	let uniswap_contribution_delta = sub_fp_fp new_uniswap_contribution old_bet_details.uniswap_contribution err_INTERNAL in
	let total_quantity = add_nat_nat auction_data.quantity new_bet.quantity in
	let total_yes_preference = add_fp_fp auction_data.yes_preference new_bet_yes_preference in
	let total_uniswap_contribution = add_fp_fp auction_data.uniswap_contribution uniswap_contribution_delta in
	( merged_bet, { auction_data with
		quantity = total_quantity;
		yes_preference = total_yes_preference;
		uniswap_contribution = total_uniswap_contribution;
	} )

let place_auction_bet ( bet_params, market_storage : bet_params * market_storage ) : operation list * market_storage =
	let market_map = market_storage.market_map in
	let market_id = bet_params.market_id in
	let market_data = get_market ( market_id, market_map ) in
	let auction_data = get_auction_data market_data in
	let auction_bet_map = market_storage.auction_bet_map in
	let auction_bet_id : auction_bet_id = {
		originator = Tezos.sender;
		market_id = market_id;
	} in
	let old_bet = get_auction_bet ( auction_bet_id, auction_bet_map ) in
	let ( merged_bet, auction_data ) = update_auction_totals ( old_bet, bet_params.bet, auction_data ) in
	let auction_bet_map = save_auction_bet ( auction_bet_id, merged_bet, market_storage.auction_bet_map ) in
	let market_data = save_auction_data ( auction_data, market_data ) in
	let market_map = save_market ( market_id, market_data, market_map ) in
	let pull_payment = get_pull_payment ( market_data.metadata.currency, bet_params.bet.quantity ) in
	[ pull_payment ], { market_storage with
		auction_bet_map = auction_bet_map;
		market_map = market_map;
	}

») m4_dnl
