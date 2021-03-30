m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«INSTALLER»,,«m4_define(«INSTALLER»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common/framework,lazy_endpoint.mligo.m4) m4_dnl
m4_loadfile(.,storage.mligo.m4) m4_dnl

//
// This file should be unaffected by changes to business logic
// Treat it as a framework file
//

type install_params =
[@layout:comb]
{
	name : lambda_id;
	code : business_endpoint_lambda;
}

type installer_action =
	| InstallLambda of install_params
	| SealContract

let err_CONTRACT_SEALED = "Access denied: contract sealed"
let err_ACCESS_DENIED = "Access denied: unauthorized caller"

let assert_installer_access_control ( lambda_repository : lambda_repository ) : unit =
	let creator = match lambda_repository.creator with
	| None -> ( failwith err_CONTRACT_SEALED : address )
	| Some addr -> addr in
	if ( creator <> Tezos.sender ) then
		( failwith err_ACCESS_DENIED : unit )
	else
		unit

[@inline]
let install_lambda ( install_params, lambda_repository : install_params * lambda_repository ) : lambda_repository =
	let updated_map = Big_map.update install_params.name ( Some ( install_params.code ) ) lambda_repository.lambda_map in
	{ lambda_repository with lambda_map = updated_map }

[@inline]
let seal_contract ( lambda_repository : lambda_repository ) : lambda_repository =
	{ lambda_repository with creator = ( None : address option ) }

[@inline]
let installer_dispatch ( action, container_storage : installer_action * container_storage ) : operation list * container_storage =
	let lambda_repository = container_storage.lambda_repository in
	let new_repository = begin
		assert_installer_access_control lambda_repository;
		match action with
		| InstallLambda params -> install_lambda ( params, lambda_repository )
		| SealContract -> seal_contract lambda_repository
	end in
	( [] : operation list ), { container_storage with lambda_repository = new_repository }

») m4_dnl
