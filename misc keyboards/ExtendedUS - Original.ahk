/*	InKey script to provide a keyboard layout for creating InKey Maps

	Keyboard:	ExtendedUS
	Version:	1.0
	Author:		Dan M
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes.

Remarks:


HISTORY:
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 1.910
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; Look it up near the top of the InKeyLib.ahki file, and enter it here.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

 K_UseContext = 1	; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki

;________________________________________________________________________________________________________________
OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
	OnScreen(Button("→", "Alt+FullStop", "w24 h24", thenSend("→"))
			, Button("⇛", "Alt+Equals", "wp hp", thenSend("⇛"))
			, Button("↺", "Alt+Comma", "wp hp", thenSend("↺")))
	return

;________________________________________________________________________________________________________________
;   Key Handlers

;_____________________________
; Make the arrow characters accessible
$!.::Send("→")		; Alt period (same key as right wedge) for an arrow
$!=::Send("⇛")		; Alt equals, for a triple arrow
$!,::Send("↺")		; Alt comma (same key as left wedge) for a looping arrow

;_____________________________
; Alt-Minus demonstrates a pig-latinizing function.
$!-::InCase(Replace("\b([bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ]+)(\p{L}+)") with("$2$1ay"))
		||  InCase(After("\b[aeiouAEIOU]\p{L}*") thenSend("way"))
		|| Beep()


;_____________________________
; Other general-purpose auto-corrections

; Dash key:  double-tap for n-dash, triple-tap for m-dash.  If more than that, just go back to all dashes.
$-::InCase(After("----") thenSend("-"))
		|| InCase(MultiTapSend("- – — ----"))



; ________________________________________________
; Special cases:  Not a typical kind of keyboard behavior.  No need to implement in TINKER.

; Alt-x will convert any preceding hex digits into the character of that codepoint, including SMP
$!x::
cc := context(6)
if (cc = "")   ; No context to work with
	return
if (RegExMatch(cc, "[0-9A-Fa-f]+$", hexdigits)) {  ; Hex digits to convert to text
		hh := "0x" hexdigits
		hh += 0
		InCase(Replace(hexdigits) with(Char(hh)))
		return
}
; Text character to convert to hex codepoint
SetFormat integerfast, H
lastChar := SubStr(cc, 0)
lastCode := Asc(lastChar)
if  (lastCode & 0xdc00 = 0xdc00)   { ; if a trailing surrogate
	lastChar := SubStr(cc, -1)  					; get the whole SMP character
	lastCode := Ord(lastChar)
}
InCase(Replace(lastChar) with(SubStr(lastCode, 3)))
SetFormat integerfast, D
return
