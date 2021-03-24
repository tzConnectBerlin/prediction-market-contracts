m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«LAZY_ENDPOINT»,,«m4_define(«LAZY_ENDPOINT»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(..,business_interface_root.mligo.m4) m4_dnl

//
// This file should be unaffected by changes to business logic
// Treat it as a framework file
//

type business_endpoint_params = ( bytes * business_storage )

type business_endpoint_return = ( operation list * business_storage )

type business_endpoint_lambda = business_endpoint_params -> business_endpoint_return

») m4_dnl
