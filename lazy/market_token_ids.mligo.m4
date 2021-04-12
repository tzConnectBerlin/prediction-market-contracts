m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_TOKEN_IDS»,,«m4_define(«MARKET_TOKEN_IDS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,maths_interface.mligo.m4) m4_dnl

[@inline]
let get_base_token_id_for_market ( market_id : market_id ) : token_id =
	Bitwise.shift_left market_id 3n

[@inline]
let get_market_id_for_token ( token_id : token_id ) : market_id =
	Bitwise.shift_right token_id 3n

[@inline]
let get_no_token_id ( market_id : market_id ) : token_id =
	get_base_token_id_for_market market_id

[@inline]
let get_yes_token_id ( market_id : market_id ) : token_id =
	add_nat_nat 1n ( get_base_token_id_for_market market_id )

[@inline]
let get_liquidity_token_id ( market_id : market_id ) : token_id =
	add_nat_nat 2n ( get_base_token_id_for_market market_id )

[@inline]
let get_auction_reward_token_id ( market_id : market_id ) : token_id =
	add_nat_nat 3n ( get_base_token_id_for_market market_id )

[@inline]
let get_liquidity_reward_token_id ( market_id : market_id ) : token_id =
	add_nat_nat 4n ( get_base_token_id_for_market market_id )

») m4_dnl