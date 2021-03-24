m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«EXTERNAL_TOKEN_INTERFACE»,,«m4_define(«EXTERNAL_TOKEN_INTERFACE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(.,token_interface.mligo.m4) m4_dnl

type fa2_token_identifier =
[@layout:comb]
{
	token_address : address;
	token_id : token_id;
}

type external_token =
	| Fa12 of address
	| Fa2 of fa2_token_identifier

») m4_dnl