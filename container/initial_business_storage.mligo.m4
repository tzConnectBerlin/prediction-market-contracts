m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«INIT_BUSINESS_STORAGE»,,«m4_define(«INIT_BUSINESS_STORAGE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl

// Initial storage for deployment

let initial_business_storage : business_storage = {
	markets = {
		market_map = ( Big_map.empty : market_map );
		liquidity_provider_map = ( Big_map.empty : liquidity_provider_map );
	};
	tokens = {
		ledger_map = ( Big_map.empty : ledger_map );
		supply_map = ( Big_map.empty : supply_map );
	};
}

») m4_dnl