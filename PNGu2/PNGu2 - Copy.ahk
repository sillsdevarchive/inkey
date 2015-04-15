/*	InKey script to provide a keyboard layout for GENERIC.

	Keyboard:	GENERIC
	Version:	1.0
	Author:
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes. Please give credit as appropriate.

Remarks:

HISTORY:
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.094
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 2	; Causes uncaptured character keys to be included in the context too.  CONTEXT SENSITIVE

#include InKeyLib.ahki

OnLoadScript:	; This section is executed when this InKey script is first loaded.
	RegisterRota(300, "̀`` ̀ ``", 0x300)
	RegisterRota(301, "́' ́ '", 0x301)
	RegisterRota(302, "̂^ ̂ ^", 0x302)
	RegisterRota(1303, "̃~ ̃ ~", 0x303)  ; Basic version of the tilde rota
	CreateRota(303, RotaSets("Ñ~ N Ñ N~", "ñ~ n ñ n~", "̃~ ̃ ~"), "𝄞")  ; Tilde rota with explicit n forms
	RegisterRota(308, "̈`; ̈ `;", 0x0308)
	RegisterRota(335, RotaSets("L Ƚ Ⱡ", "l ƚ ⱡ", "I Ɨ", "i ɨ", "u ʉ", "U Ʉ", "n ŋ", "N Ŋ", "? ʔ", "v ʌ", "V Ʌ"), 0x3D, 0, 0, 1)
	;~ RegisterRota(1, RotaSets("ि	ी", "इ	ई",
	;~ or SendText("ई")
	CreateRota(2, RotaSets("ि इ", "ी ई", "ु उ", "ू ऊ"))
	RegisterRota(7, "𝄞 𐀀 𐀁 𐀂", 0x3D, 0, 0, 1)
	CreateRota(37, 	RotaSets("ि	ी", "इ	ई"), "इ")
	CreateRota(38, 	RotaSets("ि	ी", "इ	ई"))
	CreateRota(94, "् ्‍ ्‌", "्")

	sCons = [क-हक़-य़]
	consCluster = %sCons%\x{93c}?(?:\x{94d}[\x{200d}\x{200c}]*%sCons%\x{93c}?)?
	gConsCluster = (%consCluster%)
	return

; _______________________________________________________

;~ $`::DoRota(300)
$`::DoRota(2)
$'::DoRota(301)
$^::DoRota(302)
$[::DoRota(1303)
$~::DoRota(303)
$;::DoRota(308)
$=::DoRota(335)

;~ $1::SendChars("0x61, 0x303")	; Send ã as a + combining tilde	     (NFD)
;~ $2::SendChar(0xE3)		; Send ã as precomposed character  (NFC)
;~ $3::SendText("ñ")
;~ $4::SendChar(0xF1)		; Send ñ as precomposed character  (NFC)
;~ $5::SendChars("0x6E, 0x303")	; Send ñ as n + combining tilde	     (NFD)

;~ $1::InContextSend("(b[⑤④③②①]*)", "①") or InContextReplace("([②③④⑤]+)", "①$1") or SendText("①")
;~ $2::InContextReplace("(b[⑤④③②]*)(①*)", "$1②$2") or InContextReplace("([③④⑤]+)", "②$1") or SendText("②")
;~ $3::InContextReplace("(b[⑤④③]*)([②①]*)", "$1③$2") or InContextReplace("([④⑤]+)", "③$1") or SendText("③")
;~ $4::InContextReplace("(b[⑤④]*)([③②①]*)", "$1④$2") or InContextReplace("(⑤+)", "④$1") or SendText("④")
;~ $5::InContextReplace("(b⑤*)([④③②①]*)", "$1⑤$2") or SendText("⑤")

$1::InContextReplace("([②③④⑤]+)", "①$1") or SendText("①")
$2::InContextReplace("([③④⑤]+)", "②$1") or SendText("②")
$3::InContextReplace("([④⑤]+)", "③$1") or SendText("③")
$4::InContextReplace("(⑤+)", "④$1") or SendText("④")
$5::SendText("⑤")

$6::
SendChar(0xD800)
SendChar(0xDC00)
return

$7::SendText("𝄞")
$8::DoRota(7)
$9::SendChar(0x1d11e)
$q::SendChar(0x1d11f)
$w::SendChar(0x1d120)
$c::SendChar(0x1d121)
$v::SendChar(0x1d122)
;~ $b::TrayTipQ("you pressed the hash key")
$e::InContextSend("[A-Z]", "A") or SendText("a")
;~ $r::InContextReplace("(\p{L})\p{M}\p{L}*", "@$1") or SendText("ARR")

$k::SendText("क")
$+k::SendText("ख")
$g::SendText("ग")
$+g::SendText("घ")

$f::SendChar(0x93c) ; nukta

;~ $i::
	;~ InContextSend($consCluster, "ि")
	;~ or InContextReplace("ि", "ी")
	;~ or InContextReplace("इ", "ई")
	;~ or SendText("इ")
	;~ return

;~ $i::InContextSend("[क-हक़-य़]\x{93c}?", "ि") or DoRota(37)

$i::
	;~ SpeedRota("ि	ी", "इ	ई")
	;~ DoRota(38)
	MultiTap() and DoRota(38)		; InRota(RotaSets("ि	ी", "इ	ई"))
	;~ MultiTap() and InRota(RotaSets("ि	ी", "इ	ई"))
	or InContextSend("[क-हक़-य़]\x{93c}?", "ि", "इ")
	return

$r::SendText("र")
$+r::InContextReplace(gConsCluster, "र्$1", "र")

$z::SendText("ष")
$x::DoRota(94)
