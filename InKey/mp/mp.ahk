/*	InKey script to provide a keyboard layout for mp
	  Autogenerated by InKeyKeyboardCreator

	Keyboard:	mp
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
RegisterRota(1, "n ŋ", 0x6E, 0, 0, 8)  ;| n ŋ
RegisterRota(2, "Mark Penny woz 'ere", 0x4D, 0, 0, 0)  ;| Mark Penny woz 'ere
return
;________________________________________________________________________________________________________________

$n::
DoRota(1)
return
$+m::
DoRota(2)
return