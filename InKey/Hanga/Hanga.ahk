/*	InKey script to provide a keyboard layout for Hanga
	  Autogenerated by InKeyKeyboardCreator

	Keyboard:	Hanga
	Version:    1.0
	Author:
	Official Distribution: http://inkeysoftware.com

*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.092
	  ; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	  ; It can be found near the top of the InKeyLib.ahki file.
	  ; It may be lower than the InKey version number.
	  ; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	  ; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 1  ; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki
;________________________________________________________________________________________________________________


OnLoadScript:
rota =
( C

)
RegisterRota(1, "ee ɛ ɛɛ", 0x65, 0, 0, 8)  ;| e ee ɛ ɛɛ
RegisterRota(2, "oo ɔ ɔɔ", 0x6F, 0, 0, 8)  ;| o oo ɔ ɔɔ
RegisterRota(3, "`; "" £ °", 0x3B, 0, 0, 8)  ;| `; "" £ °
RegisterRota(4, "nn ŋ ŋŋ", 0x6E, 0, 0, 8)  ;| n nn ŋ ŋŋ
RegisterRota(5, "EE Ɛ ƐƐ", 0x45, 0, 0, 8)  ;| E EE Ɛ ƐƐ
RegisterRota(6, "OO Ɔ ƆƆ", 0x4F, 0, 0, 8)  ;| O OO Ɔ ƆƆ
RegisterRota(7, "NN Ŋ ŊŊ", 0x4E, 0, 0, 8)  ;| N NN Ŋ ŊŊ
RegisterRota(8, "N Ŋ	n ŋ	e ɛ	o ɔ	e E	O Ɔ", 0x3E, 0, 0x3E, 1)  ;|


return
;________________________________________________________________________________________________________________

$e::
DoRota(1)
return
$o::
DoRota(2)
return
$`;::
DoRota(3)
return
$n::
DoRota(4)
return
$+e::
DoRota(5)
return
$+o::
DoRota(6)
return
$+n::
DoRota(7)
return

$=::
DoRota(8)
return
