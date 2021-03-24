m4_changequote m4_dnl
m4_changequote(«,») m4_dnl
m4_ifdef(«MATHS_INTERFACE»,,«m4_define(«MATHS_INTERFACE»,1) m4_dnl
m4_include(m4_helpers.m4) m4_dnl

m4_define(«FIXEDPOINT_RADIX»,«64») m4_dnl

type fixedpoint = { n: nat; }

let fixedpoint_radix = FIXEDPOINT_RADIX()n

let fixedpoint_one : fixedpoint = { n = m4_bc(2^FIXEDPOINT_RADIX())n; }
let fixedpoint_half : fixedpoint = { n = m4_bc((2^FIXEDPOINT_RADIX)/2)n; }
let fixedpoint_zero : fixedpoint = { n = 0n; }

») m4_dnl
