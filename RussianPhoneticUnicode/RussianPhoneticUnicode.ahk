/*	InKey script to provide a keyboard layout for Russian.

	Keyboard:	Russian Phonetic Unicode
	Version:	1.2
	Author:		Ben Chenoweth (NEG)
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes. Please give credit as appropriate.

Remarks:
	This keyboard provides the user the option of using the standard Russian keyboard layout and a phonetic layout based on the US keyboard.
	The phonetic keyboard has been designed to not use as many of the usual punctuation keys as possible.  This is done by utilising rotas:
		The 'a' key rotates between cyrillic_small_letter_a (а), cyrillic_small_letter_ya (я)
		The 'e' key rotates between cyrillic_small_letter_ie (е), cyrillic_small_letter_e (э)
		The 'i' key rotates between cyrillic_small_letter_i (и), cyrillic_small_letter_yeru (ы)
		The 'o' key rotates between cyrillic_small_letter_o (о), cyrillic_small_letter_io (ё)
		The 'u' key rotates between cyrillic_small_letter_u (у), cyrillic_small_letter_yu (ю)
		The 't' key rotates between cyrillic_small_letter_te (т), cyrillic_small_letter_tse (ц)
		The 'h' key rotates between cyrillic_small_letter_soft_sign (ь), cyrillic_small_letter_hard_sign (ъ)

HISTORY:
2008-11-04  1.0  Created by Ben Chenoweth (NEG)
2008-11-19	1.1  Updated for InKeyLib.ahki version 0.092 (simplifies retrieving parameters)
2008-11-24	1.2  Added the missing io characters (upper and lowercase), removed cyrillic_small_letter_short_i (й) from 'i' rota.
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.092
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 1	; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki

;________________________________________________________________________________________________________________

OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
;		Perform any script-wide initialization here, such as calls to RegisterRota().
RegisterRota(1, "е э", 0x435, 0, 0, 8)	;|	cyrillic_small_letter_ie (е), cyrillic_small_letter_e (э)
RegisterRota(2, "Е Э", 0x415, 0, 0, 8)	;|	cyrillic_capital_letter_ie (Е), cyrillic_capital_letter_e (Э)
RegisterRota(3, "ь ъ", 0x44C, 0, 0, 8)	;|	cyrillic_small_letter_soft_sign (ь), cyrillic_small_letter_hard_sign (ъ)
RegisterRota(4, "Ь Ъ", 0x42C, 0, 0, 8) ;|	cyrillic_capital_letter_soft_sign (Ь), cyrillic_capital_letter_hard_sign (Ъ)
RegisterRota(5, "а я", 0x430, 0, 0, 8)	;|	cyrillic_small_letter_a (а), cyrillic_small_letter_ya (я)
RegisterRota(6, "А Я", 0x410, 0, 0, 8)	;|	cyrillic_capital_letter_a (А), cyrillic_capital_letter_ya (Я)
RegisterRota(7, "и ы", 0x438, 0, 0, 8)	;|	cyrillic_small_letter_i (и), cyrillic_small_letter_yeru (ы)
RegisterRota(8, "И Ы", 0x418, 0, 0, 8)	;|	cyrillic_capital_letter_i (И), cyrillic_capital_letter_yeru (Ы)
RegisterRota(9, "у ю", 0x443, 0, 0, 8)	;|	cyrillic_small_letter_u (у), cyrillic_small_letter_yu (ю)
RegisterRota(10, "У Ю", 0x423, 0, 0, 8)	;|	cyrillic_capital_letter_u (У), cyrillic_capital_letter_yu (Ю)
RegisterRota(11, "т ц", 0x442, 0, 0, 8)	;|	cyrillic_small_letter_te (т), cyrillic_small_letter_tse (ц)
RegisterRota(12, "Т Ц", 0x422, 0, 0, 8)	;|	cyrillic_capital_letter_te (Т), cyrillic_capital_letter_tse (Ц)
RegisterRota(13, "о ё", 0x43E, 0, 0, 8)	;|	cyrillic_small_letter_o (о), cyrillic_small_letter_io (ё)
RegisterRota(14, "О Ё", 0x41E, 0, 0, 8)	;|	cyrillic_capital_letter_o (О), cyrillic_capital_letter_io (Ё)
return
;________________________________________________________________________________________________________________

OnLoadKeyboard:	; InKeyLib will call this subroutine the first time InKey calls on this script for a particular keyboard.
;			(The user may configure multiple keyboards from a single keyboard script, if the keyboard script
;			supports parameters.)  The parameter string associated with the current keyboard will be contained in
;			the global named K_Params.
;			Perform any one-time keyboard-specific initialization here, such as any calls to RegisterKbdRota().
;			Also, if you need it, the numeric identifier that InKey has assigned to the current keyboard will be
;			contained in the global named K_ID.  It may be useful to use this as an array index for storing
;			keyboard-specific values.  (This may be more efficient than re-processing the K_Param string each
;			time OnKeyboardInit is called.)

	; Determine whether to use phonetic keyboard layout
	Phonetic := GetParam("Phonetic", 0)

;________________________________________________________________________________________________________________
; In the following mappings of keystrokes to Unicode characters to send, each keystroke code is prefixed with a
; dollar sign ($), telling InKey to act on the keystroke only if it has not been artificially generated by InKey itself.
; Some keystrokes are then prefixed with a plus sign (+), indicating the shifted form of the key.
; See the AutoHotKey documentation for a full description of the syntax for specifying hotkeys.

; symbol keys
$`::
If (Phonetic)
	SendChar(0x60)	;|	grave_accent (`)
else
	SendChar(0x451)	;|	cyrillic_small_letter_io (ё)
return
$~::
If (Phonetic)
	SendChar(7E)	;|	tilde (~)
else
	SendChar(0x401)	;|	cyrillic_capital_letter_io (Ё)
return
$@::
If (Phonetic)
	SendChar(0x40)	;|	commercial_at (@)
else
	SendChar(0x22)	;|	quotation_mark (")
return
$#::
If (Phonetic)
	SendChar(0x23)	;|	number_sign (#)
else
	SendChar(0x2116)	;|	numero_sign (№)
return
$$::
If (Phonetic)
	SendChar(0x24)	;|	dollar_sign ($)
else
	SendChar(0x3B)	;|	semicolon (;)
return
$^::
If (Phonetic)
	SendChar(0x5E)	;|	circumflex_accent (^)
else
	SendChar(0x3A)	;|	colon (:)
return
$&::
If (Phonetic)
	SendChar(0x26)	;|	ampersand (&)
else
	SendChar(0x3F)	;|	question_mark (?)
return
$>::
If (Phonetic)
	SendChar(0x3E)	;|	greater_than_sign (>)
else
	SendChar(0x42E)	;|	cyrillic_capital_letter_yu (Ю)
return
$<::
If (Phonetic)
	SendChar(0x3C)	;|	less_than_sign (<)
else
	SendChar(0x411)	;|	cyrillic_capital_letter_be (Б)
return
${::
If (Phonetic)
	SendChar(0x7B)	;|	left_curly_bracket ({)
else
	SendChar(0x425)	;|	cyrillic_capital_letter_ha (Х)
return
$}::
If (Phonetic)
	SendChar(0x7D)	;|	right_curly_bracket (})
else
	SendChar(0x42A)	;|	cyrillic_capital_letter_hard_sign (Ъ)
return
$]::
If (Phonetic)
	SendChar(0x5D)	;|	right_square_bracket (])
else
	SendChar(0x44A)	;|	cyrillic_small_letter_hard_sign (ъ)
return
$[::
If (Phonetic)
	SendChar(0x5B)	;|	left_square_bracket ([)
else
	SendChar(0x445)	;|	cyrillic_small_letter_ha (х)
return
$+`;::	; colon key
If (Phonetic)
	SendChar(0x3A)	;|	colon (:)
else
	SendChar(0x416)	;|	cyrillic_capital_letter_zhe (Ж)
return
$`;::	; semi colon key
If (Phonetic)
	SendChar(0x3B)	;|	semicolon (;)
else
	SendChar(0x436)	;|	cyrillic_small_letter_zhe (ж)
return
$\::
If (Phonetic)
	SendChar(0x5C)	;|	reverse_solidus (\)
else
	SendChar(0x2F)	;|	solidus (/)
return
$|::
If (Phonetic)
	SendChar(0x7c)	;|	vertical_line (|)
else
	SendChar(0x7c)	;|	vertical_line (|)
return
$"::
If (Phonetic)
	SendChar(0x22)	;|	quotation_mark (")
else
	SendChar(0x42D)	;|	cyrillic_capital_letter_e (Э)
return
$'::
If (Phonetic)
	SendChar(0x27)	;|	apostrophe (')
else
	SendChar(0x44D)	;|	cyrillic_small_letter_e (э)
return
$,::
If (Phonetic)
	SendChar(0x2C)	;|	comma (,)
else
	SendChar(0x431)	;|	cyrillic_small_letter_be (б)
return
$.::
If (Phonetic)
	SendChar(0x2E)	;|	full_stop (.)
else
	SendChar(0x44E)	;|	cyrillic_small_letter_yu (ю)
return
$/::
If (Phonetic)
	SendChar(0x2F)	;|	solidus (/)
else
	SendChar(0x2E)	;|	full_stop (.)
return
$?::
If (Phonetic)
	SendChar(0x3F)	;|	question_mark (?)
else
	SendChar(0x2C)	;|	comma (,)
return

; unshifted letter keys
$a::
If (Phonetic)
	DoRota(5)	;|	cyrillic_small_letter_a (а), cyrillic_small_letter_ya (я)
else
	SendChar(0x444)	;|	cyrillic_small_letter_ef (ф)
return
$b::
If (Phonetic)
	SendChar(0x431)	;|	cyrillic_small_letter_be (б)
else
	SendChar(0x438)	;|	cyrillic_small_letter_i (и)
return
$c::
If (Phonetic)
	SendChar(0x447)	;|	cyrillic_small_letter_che (ч)
else
	SendChar(0x441)	;|	cyrillic_small_letter_es (с)
return
$d::
If (Phonetic)
	SendChar(0x434)	;|	cyrillic_small_letter_de (д)
else
	SendChar(0x432)	;|	cyrillic_small_letter_ve (в)
return
$e::
If (Phonetic)
	DoRota(1)	;|	cyrillic_small_letter_ie (е), cyrillic_small_letter_e (э)
else
	SendChar(0x443)	;|	cyrillic_small_letter_u (у)
return
$f::
If (Phonetic)
	SendChar(0x444)	;|	cyrillic_small_letter_ef (ф)
else
	SendChar(0x430)	;|	cyrillic_small_letter_a (а)
return
$g::
If (Phonetic)
	SendChar(0x433)	;|	cyrillic_small_letter_ghe (г)
else
	SendChar(0x43F)	;|	cyrillic_small_letter_pe (п)
return
$h::
If (Phonetic)
	DoRota(3)	;|	cyrillic_small_letter_soft_sign (ь) cyrillic_small_letter_hard_sign (ъ)
else
	SendChar(0x440)	;|	cyrillic_small_letter_er (р)
return
$i::
If (Phonetic)
	DoRota(7)	;|	cyrillic_small_letter_i (и), cyrillic_small_letter_yeru (ы), cyrillic_small_letter_short_i (й)
else
	SendChar(0x448)	;|	cyrillic_small_letter_sha (ш)
return
$j::
If (Phonetic)
	SendChar(0x436)	;|	cyrillic_small_letter_zhe (ж)
else
	SendChar(0x43E)	;|	cyrillic_small_letter_o (о)
return
$k::
If (Phonetic)
	SendChar(0x43A)	;|	cyrillic_small_letter_ka (к)
else
	SendChar(0x43B)	;|	cyrillic_small_letter_el (л)
return
$l::
If (Phonetic)
	SendChar(0x43B)	;|	cyrillic_small_letter_el (л)
else
	SendChar(0x434)	;|	cyrillic_small_letter_de (д)
return
$m::
If (Phonetic)
	SendChar(0x43C)	;|	cyrillic_small_letter_em (м)
else
	SendChar(0x44C)	;|	cyrillic_small_letter_soft_sign (ь)
return
$n::
If (Phonetic)
	SendChar(0x43D)	;|	cyrillic_small_letter_en (н)
else
	SendChar(0x442)	;|	cyrillic_small_letter_te (т)
return
$o::
If (Phonetic)
	DoRota(13)	;|	cyrillic_small_letter_o (о), cyrillic_small_letter_io (ё)
else
	SendChar(0x449)	;|	cyrillic_small_letter_shcha (щ)
return
$p::
If (Phonetic)
	SendChar(0x43F)	;|	cyrillic_small_letter_pe (п)
else
	SendChar(0x437)	;|	cyrillic_small_letter_ze (з)
return
$q::
If (Phonetic)
	SendChar(0x448)	;|	cyrillic_small_letter_sha (ш)
else
	SendChar(0x439)	;|	cyrillic_small_letter_short_i (й)
return
$r::
If (Phonetic)
	SendChar(0x440)	;|	cyrillic_small_letter_er (р)
else
	SendChar(0x43A)	;|	cyrillic_small_letter_ka (к)
return
$s::
If (Phonetic)
	SendChar(0x441)	;|	cyrillic_small_letter_es (с)
else
	SendChar(0x44B)	;|	cyrillic_small_letter_yeru (ы)
return
$t::
If (Phonetic)
	DoRota(11)	;|	cyrillic_small_letter_te (т), cyrillic_small_letter_tse (ц)
else
	SendChar(0x435)	;|	cyrillic_small_letter_ie (е)
return
$u::
If (Phonetic)
	DoRota(9)	;|	cyrillic_small_letter_u (у), cyrillic_small_letter_yu (ю)
else
	SendChar(0x433)	;|	cyrillic_small_letter_ghe (г)
return
$v::
If (Phonetic)
	SendChar(0x432)	;|	cyrillic_small_letter_ve (в)
else
	SendChar(0x43C)	;|	cyrillic_small_letter_em (м)
return
$w::
If (Phonetic)
	SendChar(0x449)	;|	cyrillic_small_letter_shcha (щ)
else
	SendChar(0x446)	;|	cyrillic_small_letter_tse (ц)
return
$x::
If (Phonetic)
	SendChar(0x445)	;|	cyrillic_small_letter_ha (х)
else
	SendChar(0x447)	;|	cyrillic_small_letter_che (ч)
return
$y::
If (Phonetic)
	SendChar(0x439)	;|	cyrillic_small_letter_short_i (й)
else
	SendChar(0x43D)	;|	cyrillic_small_letter_en (н)
return
$z::
If (Phonetic)
	SendChar(0x437)	;|	cyrillic_small_letter_ze (з)
else
	SendChar(0x44F)	;|	cyrillic_small_letter_ya (я)
return

; shifted letter keys
$+a::
If (Phonetic)
	DoRota(6)	;|	cyrillic_capital_letter_a (А)
else
	SendChar(0x424)	;|	cyrillic_capital_letter_ef (Ф)
return
$+b::
If (Phonetic)
	SendChar(0x411)	;|	cyrillic_capital_letter_be (Б)
else
	SendChar(0x418)	;|	cyrillic_capital_letter_i (И)
return
$+c::
If (Phonetic)
	SendChar(0x427)	;|	cyrillic_capital_letter_che (Ч)
else
	SendChar(0x421)	;|	cyrillic_capital_letter_es (С)
return
$+d::
If (Phonetic)
	SendChar(0x414)	;|	cyrillic_capital_letter_de (Д)
else
	SendChar(0x412)	;|	cyrillic_capital_letter_ve (В)
return
$+e::
If (Phonetic)
	DoRota(2)	;|	cyrillic_capital_letter_ie (Е), cyrillic_capital_letter_e (Э)
else
	SendChar(0x423)	;|	cyrillic_capital_letter_u (У)
return
$+f::
If (Phonetic)
	SendChar(0x424)	;|	cyrillic_capital_letter_ef (Ф)
else
	SendChar(0x410)	;|	cyrillic_capital_letter_a (А)
return
$+g::
If (Phonetic)
	SendChar(0x413)	;|	cyrillic_capital_letter_ghe (Г)
else
	SendChar(0x41F)	;|	cyrillic_capital_letter_pe (П)
return
$+h::
If (Phonetic)
	DoRota(4)	;|	cyrillic_capital_letter_soft_sign (Ь) cyrillic_capital_letter_hard_sign (Ъ)
else
	SendChar(0x420)	;|	cyrillic_capital_letter_er (Р)
return
$+i::
If (Phonetic)
	DoRota(8)	;|	cyrillic_capital_letter_i (И), cyrillic_capital_letter_yeru (Ы), cyrillic_capital_letter_short_i (Й)
else
	SendChar(0x428)	;|	cyrillic_capital_letter_sha (Ш)
return
$+j::
If (Phonetic)
	SendChar(0x416)	;|	cyrillic_capital_letter_zhe (Ж)
else
	SendChar(0x41E)	;|	cyrillic_capital_letter_o (О)
return
$+k::
If (Phonetic)
	SendChar(0x41A)	;|	cyrillic_capital_letter_ka (К)
else
	SendChar(0x41B)	;|	cyrillic_capital_letter_el (Л)
return
$+l::
If (Phonetic)
	SendChar(0x41B)	;|	cyrillic_capital_letter_el (Л)
else
	SendChar(0x414)	;|	cyrillic_capital_letter_de (Д)
return
$+m::
If (Phonetic)
	SendChar(0x41C)	;|	cyrillic_capital_letter_em (М)
else
	SendChar(0x42C)	;|	cyrillic_capital_letter_soft_sign (Ь)
return
$+n::
If (Phonetic)
	SendChar(0x41D)	;|	cyrillic_capital_letter_en (Н)
else
	SendChar(0x422)	;|	cyrillic_capital_letter_te (Т)
return
$+o::
If (Phonetic)
	DoRota(14)	;|	cyrillic_capital_letter_o (О), cyrillic_capital_letter_io (Ё)
else
	SendChar(0x429)	;|	cyrillic_capital_letter_shcha (Щ)
return
$+p::
If (Phonetic)
	SendChar(0x41F)	;|	cyrillic_capital_letter_pe (П)
else
	SendChar(0x417)	;|	cyrillic_capital_letter_ze (З)
return
$+q::
If (Phonetic)
	SendChar(0x428)	;|	cyrillic_capital_letter_sha (Ш)
else
	SendChar(0x419)	;|	cyrillic_capital_letter_short_i (Й)
return
$+r::
If (Phonetic)
	SendChar(0x420)	;|	cyrillic_capital_letter_er (Р)
else
	SendChar(0x41A)	;|	cyrillic_capital_letter_ka (К)
return
$+s::
If (Phonetic)
	SendChar(0x421)	;|	cyrillic_capital_letter_es (С)
else
	SendChar(0x42B)	;|	cyrillic_capital_letter_yeru (Ы)
return
$+t::
If (Phonetic)
	DoRota(12)	;|	cyrillic_capital_letter_te (Т), cyrillic_capital_letter_tse (Ц)
else
	SendChar(0x415)	;|	cyrillic_capital_letter_ie (Е)
return
$+u::
If (Phonetic)
	DoRota(10)	;|	cyrillic_capital_letter_u (У), cyrillic_capital_letter_yu (Ю)
else
	SendChar(0x413)	;|	cyrillic_capital_letter_ghe (Г)
return
$+v::
If (Phonetic)
	SendChar(0x412)	;|	cyrillic_capital_letter_ve (В)
else
	SendChar(0x41C)	;|	cyrillic_capital_letter_em (М)
return
$+w::
If (Phonetic)
	SendChar(0x429)	;|	cyrillic_capital_letter_shcha (Щ)
else
	SendChar(0x426)	;|	cyrillic_capital_letter_tse (Ц)
return
$+x::
If (Phonetic)
	SendChar(0x425)	;|	cyrillic_capital_letter_ha (Х)
else
	SendChar(0x427)	;|	cyrillic_capital_letter_che (Ч)
return
$+y::
If (Phonetic)
	SendChar(0x419)	;|	cyrillic_capital_letter_short_i (Й)
else
	SendChar(0x41D)	;|	cyrillic_capital_letter_en (Н)
return
$+z::
If (Phonetic)
	SendChar(0x417)	;|	cyrillic_capital_letter_ze (З)
else
	SendChar(0x42F)	;|	cyrillic_capital_letter_ya (Я)
return