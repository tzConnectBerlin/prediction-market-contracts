m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«LAZY_TYPING»,,«m4_define(«LAZY_TYPING»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl

//
// This file should be unaffected by changes to business logic
// Treat it as a framework file
//

m4_define(«LAZY_TYPE»,«m4_dnl

m4_ifdef(«RELEASE»,,let err_INVALID_TYPE_$1 = "Lazy type error: expected $1")

let unpack_$1 ( packed_value : bytes ) : $1 =
	match ( ( Bytes.unpack packed_value ) : $1 option ) with
	| None -> ( failwith m4_ifdef(«RELEASE»,«err_INTERNAL»,err_INVALID_TYPE_$1) : $1 )
	| Some e -> e

») m4_dnl

») m4_dnl
