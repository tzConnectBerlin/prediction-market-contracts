m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MATHS»,,«m4_define(«MATHS»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl
m4_loadfile(../common,maths_interface.mligo.m4) m4_dnl

[@inline]
let add_nat_nat ( a : nat ) ( b : nat ) : nat =
	a + b

[@inline]
let sub_nat_nat ( a : nat ) ( b : nat ) ( err : string ) : nat =
	match is_nat (a - b) with
    	| None -> ( failwith err : nat )
    	| Some x -> x

let sub_fp_fp ( a : fixedpoint ) ( b : fixedpoint ) ( err : string ) : fixedpoint =
	{ n = ( sub_nat_nat a.n b.n err ); }

[@inline]
let nat_to_fp ( a : nat ) : fixedpoint =
	{ n = ( Bitwise.shift_left a fixedpoint_radix ); }

[@inline]
let floor ( a : fixedpoint ) : nat =
	Bitwise.shift_right a.n fixedpoint_radix

[@inline]
let add_fp_fp ( a : fixedpoint ) ( b : fixedpoint ) : fixedpoint =
	{ n = a.n + b.n; }

[@inline]
let mul_nat_nat ( a : nat ) ( b : nat ) : nat =
	a * b

[@inline]
let mul_fp_nat ( a : fixedpoint ) ( b : nat ) : fixedpoint =
	{ n = a.n * b; }

[@inline]
let div_internal ( a : nat ) ( b : nat ) ( err : string ) : nat =
	let result = ediv a b in
	match result with 
	| Some p -> p.0
	| None -> ( failwith err : nat )

[@inline]
let div_fp_nat ( a : fixedpoint ) ( b : nat ) ( err : string ) : fixedpoint =
	let quot = div_internal a.n b err in
	{ n = quot; }

[@inline]
let div_nat_nat ( a : nat ) ( b : nat ) ( err : string ) : fixedpoint =
	let a = nat_to_fp a in
	div_fp_nat a b err

[@inline]
let div_nat_nat_floor ( a : nat ) ( b : nat ) ( err : string ) : nat =
	div_internal a b err

[@inline]
let div_fp_fp ( a : fixedpoint ) ( b : fixedpoint ) ( err : string ) : fixedpoint =
	div_nat_nat a.n b.n err // Upscale a, and divide by the integer rep of b

[@inline]
let div_fp_fp_floor ( a : fixedpoint ) ( b : fixedpoint ) ( err : string ) : nat =
	div_internal a.n b.n err

[@inline]
let gt_fp ( a : fixedpoint ) ( b : fixedpoint ) : bool =
	( a.n > b.n )

[@inline]
let min_fp ( a : fixedpoint ) ( b : fixedpoint ) : fixedpoint =
	if ( gt_fp b a ) then
		a
	else
		b
	
[@inline]
let complement ( a : fixedpoint ) ( err : string ) : fixedpoint =
	sub_fp_fp fixedpoint_one a err

») m4_dnl