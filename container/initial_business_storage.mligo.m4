m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«INIT_BUSINESS_STORAGE»,,«m4_define(«INIT_BUSINESS_STORAGE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,business_interface_root.mligo.m4) m4_dnl

// Initial storage for deployment

//let initial_business_storage : business_storage = 

») m4_dnl