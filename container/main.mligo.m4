m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MAIN»,,«m4_define(«MAIN»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,storage.mligo.m4) m4_dnl
m4_loadfile(.,installer.mligo.m4) m4_dnl
m4_loadfile(.,lazy_endpoint_helper.mligo.m4) m4_dnl

type market_action =
	| MakeBootstrapPrediction of prediction_params // "Auction bid"
	| ClearBootstrap of market_id // "Close auction"

type main_action =
	| Installer of installer_action
	| Market of market_action

let market_dispatcher ( action, container_storage : market_action * container_storage ) : operation list * container_storage =
	match action with
	| MakeBootstrapPrediction params -> business_endpoint_dispatch ( "make_bootstrap_prediction", Bytes.pack params, container_storage )
	| BootstrapMarket params -> business_endpoint_dispatch ( "bootstrap_market", Bytes.pack params, container_storage )

let main ( action, container_storage : main_action * container_storage) : operation list * container_storage =
	match action with
	| Installer params -> installer_dispatch ( params, container_storage )
	| Market params -> business_endpoint_dispatch ( "add", Bytes.pack params, container_storage )

») m4_dnl
