m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«EXTERNAL_TOKEN»,,«m4_define(«EXTERNAL_TOKEN»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,external_token_interface.mligo.m4) m4_dnl

let err_INVALID_TOKEN_CONTRACT = "Invalid external token contract"

type fa12_transfer_args =
[@layout:comb]
{
	[@annot:from] src : address;
	[@annot:to] dst : address;
	value : nat;
}

type transfer_addresses =
[@layout:comb]
{
	src : address;
	dst : address;
}

let get_fa12_transfer_entrypoint ( token_address : address ) : fa12_transfer_args contract =
	match ( Tezos.get_entrypoint_opt "%transfer" token_address : fa12_transfer_args contract option ) with
	| None -> ( failwith err_INVALID_TOKEN_CONTRACT : fa12_transfer_args contract )
	| Some e -> e

let get_fa12_transfer_op ( transfer_addresses, token_address, token_amount : transfer_addresses * address * nat ) : operation =
	let args : fa12_transfer_args = {
		src = transfer_addresses.src;
		dst = transfer_addresses.dst;
		value = token_amount;
	} in
	let entrypoint = get_fa12_transfer_entrypoint token_address in
	Tezos.transaction args 0mutez entrypoint

let get_fa2_transfer_entrypoint ( token_address : address ) : fa2_batch_transfer list contract =
	match ( Tezos.get_entrypoint_opt "%transfer" token_address : fa2_batch_transfer list contract option ) with
	| None -> ( failwith err_INVALID_TOKEN_CONTRACT : fa2_batch_transfer list contract )
	| Some e -> e

let get_fa2_transfer_op ( transfer_addresses, fa2_token_identifier, token_amount : transfer_addresses * fa2_token_identifier * nat ) : operation =
	let args : fa2_batch_transfer list = [{
		src = transfer_addresses.src;
		txs = [ {
			dst = transfer_addresses.dst;
			token_id = fa2_token_identifier.token_id;
			amount = token_amount;
		} ];
	}] in
	let entrypoint = get_fa2_transfer_entrypoint fa2_token_identifier.token_address in
	Tezos.transaction args 0mutez entrypoint

let get_transfer_op ( transfer_addresses, external_token, token_amount : transfer_addresses * external_token * nat ) : operation =
	match external_token with
	| Fa12 token_address -> get_fa12_transfer_op ( transfer_addresses, token_address, token_amount )
	| Fa2 fa2_token_identifier -> get_fa2_transfer_op ( transfer_addresses, fa2_token_identifier, token_amount )

let get_pull_payment ( external_token, token_amount : external_token * nat ) : operation =
	let transfer_addresses : transfer_addresses = {
		src = Tezos.sender;
		dst = Tezos.self_address;
	} in
	get_transfer_op ( transfer_addresses, external_token, token_amount )

let get_push_payout ( external_token, token_amount : external_token * nat ) : operation =
	let transfer_addresses : transfer_addresses = {
		src = Tezos.self_address;
		dst = Tezos.sender;
	} in
	get_transfer_op ( transfer_addresses, external_token, token_amount )

») m4_dnl
