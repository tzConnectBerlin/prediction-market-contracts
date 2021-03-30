m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MARKET_CREATE_ENDPOINT»,,«m4_define(«MARKET_CREATE_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../../common/framework,lazy_typing.mligo.m4) m4_dnl
m4_loadfile(..,market_create.mligo.m4) m4_dnl

LAZY_TYPE(create_market_params)

let f : business_endpoint_lambda =
	fun ( params, business_storage : bytes * business_storage ) ->
	let params = unpack_create_market_params params in
	let operations, market_storage = create_market ( params, business_storage.markets ) in
	operations, { business_storage with
		markets = market_storage;
	}

») m4_dnl