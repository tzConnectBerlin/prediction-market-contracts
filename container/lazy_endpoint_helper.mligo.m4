m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«LAZY_ENDPOINT_HELPER»,,«m4_define(«LAZY_ENDPOINT_HELPER»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(.,storage.mligo.m4) m4_dnl

//
// This file should be unaffected by changes to business logic
// Treat it as a framework file
//

m4_ifdef(«RELEASE»,«m4_dnl
let err_INTERNAL = "Fatal internal error"»,«m4_dnl
let err_NO_SUCH_LAMBDA  = "No such lambda: "») m4_dnl

let business_endpoint_dispatch ( lambda_id, packed_params, container_storage : lambda_id * bytes * container_storage ) : operation list * container_storage =
	let lambda_map = container_storage.lambda_repository.lambda_map in
	let business_storage = container_storage.business_storage in
	let lambda = match Big_map.find_opt lambda_id lambda_map with
	| None -> ( failwith m4_ifdef(«RELEASE»,«err_INTERNAL»,«( err_NO_SUCH_LAMBDA ^ lambda_id )») : business_endpoint_lambda )
	| Some e -> e in
	let operations, new_storage = lambda ( packed_params, business_storage ) in
	operations, { container_storage with business_storage = new_storage }

») m4_dnl
