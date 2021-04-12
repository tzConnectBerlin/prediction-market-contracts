m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«COMMON_ERROR»,,«m4_define(«COMMON_ERROR»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,maths_interface.mligo.m4) m4_dnl

let err_UNAUTHORIZED_CALLER = "Access denied: unauthorized caller"
let err_INTERNAL = "Internal error"

») m4_dnl