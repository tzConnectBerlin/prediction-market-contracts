m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«AUCTION»,,«m4_define(«AUCTION»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl

let err_AUCTION_CLOSED = "Market auction closed"
let err_INVALID_PROBABILITY = "Probability must be a fixed point number with domain [0.0; 1.0]"
let err_INVALID_AMOUNT = "Amount must be greater than zero"

type bet_details =
[@layout:comb]
{
	yes_preference : fixedpoint;
	uniswap_contribution : fixedpoint;
}

let empty_bet : bet =
{
	quantity = 0n;
	predicted_probability = fixedpoint_half;
}

let calculate_yes_preference ( bet : bet ) : fixedpoint =
	mul_fp_nat bet.predicted_probability bet.quantity

let calculate_no_preference ( bet : bet ) : fixedpoint =
	mul_fp_nat ( complement bet.predicted_probability err_INVALID_PROBABILITY ) bet.quantity

let calculate_uniswap_contrib ( bet : bet ) : fixedpoint =
	let bet_lower_complement = min_fp bet.predicted_probability ( complement bet.predicted_probability err_INVALID_PROBABILITY ) in
	mul_fp_nat bet_lower_complement bet.quantity

let calculate_bet_details ( bet : bet ) : bet_details =
	let bet_yes_preference = calculate_yes_preference bet in
	let bet_uniswap_contribution = calculate_uniswap_contrib bet in
	{
		yes_preference = bet_yes_preference;
		uniswap_contribution = bet_uniswap_contribution;
	}

let get_auction_data ( market_data : market_data ) : auction_data =
	match market_data.state with
	| AuctionRunning e -> e
	| MarketBootstrapped u -> ( failwith err_AUCTION_CLOSED : auction_data )

let save_auction_data ( auction_data, market_data : auction_data * market_data ) : market_data =
	{ market_data with state = AuctionRunning(auction_data); }

let get_auction_bet ( auction_bet_id, auction_bet_map : auction_bet_id * auction_bet_map ) : bet =
	match Big_map.find_opt auction_bet_id auction_bet_map with
	| Some e -> e
	| None -> empty_bet

let save_auction_bet ( auction_bet_id, bet, auction_bet_map : auction_bet_id * bet * auction_bet_map ) : auction_bet_map =
	Big_map.update auction_bet_id ( Some(bet) ) auction_bet_map

let delete_auction_bet ( auction_bet_id, auction_bet_map : auction_bet_id * auction_bet_map ) : auction_bet_map =
	Big_map.update auction_bet_id ( None : bet option ) auction_bet_map

») m4_dnl