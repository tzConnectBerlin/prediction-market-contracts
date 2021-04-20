m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«STORAGE»,,«m4_define(«STORAGE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl
m4_loadfile(.,initial_business_storage.mligo.m4) m4_dnl

//
// This file should be unaffected by changes to business logic
// Treat it as a framework file
//
// Hint: define business storage in common/business_interface.mligo.m4
//

type lambda_id = string

type lambda_map = ( lambda_id, business_endpoint_lambda ) big_map

type lambda_repository =
[@layout:comb]
{
	creator : address option;
	lambda_map : lambda_map;
}

type container_storage =
[@layout:comb]
{
//	callback_lambda : business_endpoint_lambda option; // For the next stage of the experiment
	lambda_repository : lambda_repository;
	business_storage : business_storage;
}

// Initial storage for deployment

let initial_storage : container_storage =
{
	lambda_repository = {
		creator = Some(Tezos.sender);
		lambda_map = ( Big_map.empty : lambda_map );
	};
	business_storage = initial_business_storage;
}

»)