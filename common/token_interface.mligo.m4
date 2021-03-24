m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«TOKEN_INTERFACE»,,«m4_define(«TOKEN_INTERFACE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl

// It turned out that the FA2 code we copied isn't really implementing FA2
// For the time being I'm cutting most of it out
// We'll re-add _real_ FA2 interfaces once everything works again
// in the meantime it's a distraction

type token_id = nat

type transfer_details =
[@layout:comb]
{
	[@annot:to_] dst : address;
	token_id : token_id;
	amount : nat;
}

type fa2_batch_transfer =
[@layout:comb]
{
	[@annot:from_] src : address;
	txs : transfer_details list;
}

// MUST compile to (pair (address %owner) (nat %token_id))
type ledger_id =
[@layout:comb]
{
	owner: address;
	token_id: token_id;
}

type ledger_map = ( ledger_id, nat ) big_map

type supply_record =
[@layout:comb]
{
	total_supply : nat;
	in_reserve : nat;
}

type supply_map = ( token_id, supply_record ) big_map

type token_storage =
[@layout:comb]
{
	ledger_map : ledger_map;
	supply_map : supply_map;
//	operator_map : operator_map;
}

») m4_dnl