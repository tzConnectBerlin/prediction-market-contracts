m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«TOKEN»,,«m4_define(«TOKEN»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,token_interface.mligo.m4) m4_dnl
m4_loadfile(.,maths.mligo.m4) m4_dnl

let err_NOT_ENOUGH_BALANCE = "Not enough balance in source account"

let get_token_supply_record ( token_id, supply_map : token_id * supply_map ) : supply_record =
	match Big_map.find_opt token_id supply_map with
	| None -> ( {
		total_supply = 0n;
		in_reserve = 0n;
	} : supply_record )
	| Some(e) -> e

let get_token_supply ( token_id, supply_map : token_id * supply_map ) : nat =
	let supply_record = get_token_supply_record ( token_id, supply_map ) in
	supply_record.total_supply

let update_token_supply ( token_id, supply_record, supply_map : token_id * supply_record * supply_map ) : supply_map =
	Big_map.update token_id ( Some(supply_record) ) supply_map

let get_token_balance ( ledger_id, ledger_map : ledger_id * ledger_map ) : nat =
	match Big_map.find_opt ledger_id ledger_map with
	| None -> 0n
	| Some(n) -> n

let update_token_balance ( ledger_id, token_amount, ledger_map : ledger_id * nat * ledger_map ) : ledger_map =
	Big_map.update ledger_id ( Some(token_amount) ) ledger_map

let credit_tokens_to ( ledger_id, token_amount, ledger_map : ledger_id * nat * ledger_map ) : ledger_map =
	let token_balance = get_token_balance ( ledger_id, ledger_map ) in
	let token_balance = add_nat_nat token_balance token_amount in
	update_token_balance ( ledger_id, token_balance, ledger_map )	

let debit_tokens_from ( ledger_id, token_amount, ledger_map : ledger_id * nat * ledger_map ) : ledger_map =
	let token_balance = get_token_balance ( ledger_id, ledger_map ) in
	let token_balance = sub_nat_nat token_balance token_amount err_NOT_ENOUGH_BALANCE in
	update_token_balance ( ledger_id, token_balance, ledger_map )

type token_balance_and_supply =
[@layout_comb]
{
	balance : nat;
	supply : nat;
}

let get_token_balance_and_supply ( ledger_id, token_storage : ledger_id * token_storage ) : token_balance_and_supply =
	{
		balance = get_token_balance ( ledger_id, token_storage.ledger_map );
		supply = get_token_supply ( ledger_id.token_id, token_storage.supply_map );
	}

type single_transfer_args =
[@layout:comb]
{
	src : address;
	tx : transfer_details;
}

let token_transfer_internal ( args, ledger_map : single_transfer_args * ledger_map ) : ledger_map =
	let token_id = args.tx.token_id in
	let token_amount = args.tx.amount in
	let src_account : ledger_id = {
		owner = args.src;
		token_id = token_id;
	} in
	let dst_account : ledger_id = {
		owner = args.tx.dst;
		token_id = token_id;
	} in
	let ledger_map = debit_tokens_from ( src_account, token_amount, ledger_map ) in
	credit_tokens_to ( dst_account, token_amount, ledger_map )

type no_address_token_args =
[@layout:comb]
{
	token_id : token_id;
	amount : nat;
}

let token_mint_to_reserve ( args, supply_map : no_address_token_args * supply_map ) : supply_map =
	let token_id = args.token_id in
	let token_amount = args.amount in
	let supply_record = get_token_supply_record ( token_id, supply_map ) in
	let total_supply = add_nat_nat supply_record.total_supply token_amount in
	let in_reserve = add_nat_nat supply_record.in_reserve token_amount in
	let supply_record : supply_record = {
		total_supply = total_supply;
		in_reserve = in_reserve;
	} in
	update_token_supply ( token_id, supply_record, supply_map )

let token_mint_to_account ( args, token_storage : transfer_details * token_storage ) : token_storage =
	let token_id = args.token_id in
	let token_amount = args.amount in
	let supply_record = get_token_supply_record ( token_id, token_storage.supply_map ) in
	let total_supply = add_nat_nat supply_record.total_supply token_amount in
	let supply_record = { supply_record with total_supply = total_supply; } in
	let supply_map = update_token_supply ( token_id, supply_record, token_storage.supply_map ) in
	let dst_account : ledger_id = {
		owner = args.dst;
		token_id = token_id;
	} in
	let ledger_map = credit_tokens_to ( dst_account, token_amount, token_storage.ledger_map ) in
	{ token_storage with
		supply_map = supply_map;
		ledger_map = ledger_map;
	}

let token_release_to_account ( args, token_storage : transfer_details * token_storage ) : token_storage =
	let token_id = args.token_id in
	let token_amount = args.amount in
	let supply_record = get_token_supply_record ( token_id, token_storage.supply_map ) in
	let in_reserve = sub_nat_nat supply_record.in_reserve token_amount err_NOT_ENOUGH_BALANCE in
	let supply_record = { supply_record with in_reserve = in_reserve; } in
	let supply_map = update_token_supply ( token_id, supply_record, token_storage.supply_map ) in
	let dst_account : ledger_id = {
		owner = args.dst;
		token_id = token_id;
	} in
	let ledger_map = credit_tokens_to ( dst_account, token_amount, token_storage.ledger_map ) in
	{ token_storage with
		supply_map = supply_map;
		ledger_map = ledger_map;
	}

type token_burn_args =
[@layout:comb]
{
	src : address;
	tx : no_address_token_args;
}

let token_burn_from_account ( args, token_storage : token_burn_args * token_storage ) : token_storage =
	let token_id = args.tx.token_id in
	let token_amount = args.tx.amount in
	let supply_record = get_token_supply_record ( token_id, token_storage.supply_map ) in
	let total_supply = sub_nat_nat supply_record.total_supply token_amount err_NOT_ENOUGH_BALANCE in
	let supply_record = { supply_record with total_supply = total_supply; } in
	let supply_map = update_token_supply ( token_id, supply_record, token_storage.supply_map ) in
	let src_account : ledger_id = {
		owner = args.src;
		token_id = token_id;
	} in
	let ledger_map = debit_tokens_from ( src_account, token_amount, token_storage.ledger_map ) in
	{ token_storage with
		supply_map = supply_map;
		ledger_map = ledger_map;
	}

») m4_dnl