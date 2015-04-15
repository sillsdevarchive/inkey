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

	return

; _______________________________________________________


;~ ; Very simple keyboard with no reordering
;~ $1::Send("①")
;~ $2::Send("②")
;~ $3::Send("③")
;~ $4::Send("④")
;~ $5::Send("⑤")

;~ ; Keyboard with reordering such that sequential digits are always resorted into the order: ①②③④⑤
;~ $1::InCase(Replace("[②③④⑤]+") With("①$0")) or Send("①")
;~ $2::InCase(Replace("[③④⑤]+") With("②$0"))  or Send("②")
;~ $3::InCase(Replace("[④⑤]+") With("③$0")) or Send("③")
;~ $4::InCase(Replace("[⑤]+") With("④$0")) or Send("④")
;~ $5::Send("⑤")

;~ ; Keyboard with context-dependent reordering.
;~ ; Above sort order applies EXCEPT in sequences following the letter 'b', where order is: ⑤④③②①
$1::InCase(After("b[⑤④③②①]*") ThenSend("①"))
  or InCase(Replace("[②③④⑤]+") With("①$0"))
  or Send("①")

$2::InCase(After("b[⑤④③②]*") Replace("①*") With("②$0"))
  or InCase(Replace("[③④⑤]+") With("②$0"))
  or Send("②")

$3::InCase(After("b[⑤④③]*") Replace("[②①]*") With("③$0"))
  or InCase(Replace("[④⑤]+") With("③$0"))
  or Send("③")

$4::InCase(After("b[⑤④]*") Replace("[③②①]*") With("④$0"))
  or InCase(Replace("[⑤]+") With("④$0"))
  or Send("④")

$5::InCase(After("b[⑤]*") Replace("[④③②①]*") With("⑤$0"))
  or Send("⑤")



$=::InCase(LoopMap("h ɥ ħ ɦ", "y ɥ ʏ"))

$`::InCase(Replace("\b([bcdfghjklmnpqrstvwxyz]+)(\p{L}+)") with("$2$1ay"))
		or  InCase(After("\b[aeiou] \p{L}*") thenSend("way"))
		or Beep()

$\::Send(DeadKey(1))
$|::Send(DeadKey(2))

$e::InCase(Map(DeadKey(1) to "ĕ", DeadKey(2) to "ē"))
	|| Send("e")

$a::InCase(After(DeadKey(1)) thenSend("ă"))
	|| InCase(After(DeadKey(2)) thenSend("ā"))
	|| Send("a")


$~::
if MultiTap()    ; If following a vowel with combining tilde on, then replace with tilde otherwise output tilde
{
	InCase(After("[aeiouAEIOU]\x{303}") Replace("\x{303}") With("~"))
}
else
{
	InCase(After("[aeiouAEIOU]")  thenSend(Char(0x303)))
	||InCase(After("[aeiouAEIOU][\x{301}\x{323}]") thenSend(Char(0x303)))
	|| Send("~")
}


;~ $i::InCase(MultiTapMap("ि ी", "इ ई"))
	;~ || InCase(After("${Cons}")  thenSend("ि"))
	;~ || Send("इ")

;~ $`::InCase(Map("\x{301} \x{300} \x{302} \x{30C} \x{304}"))
	;~ || Send("\x{301}")

;~ $k::Send("k")
;~ $c::Send("k\x{1}")
;~ $h::InCase(Replace("k\x{1}") with("ch"))
	  ;~ || Send("h")
;~ $h::InCase(After("k" Deadkey(1)) thenSend("ch"))
	  ;~ || nCase(After("k") thenSend("kh"))
;~ $h::IsPhase(1) && Send("kh")
	  ;~ || IsPhase(2) && Send("ch")


$k::Send("k") && SetPhase(1)
$c::Send("k") && SetPhase(2)
$h::IsPhase(1) && Send("kh")
	  || IsPhase(2) && Send("ch")
;~ $h::IsPhase(2) && InCase(Replace("k") with("ch"))
	  ;~ || Send("h")
