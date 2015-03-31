/*	InKey script to provide a keyboard layout for Saltillo
	  Autogenerated by InKeyKeyboardCreator 2.0.2

	Keyboard:	Saltillo
	Version:    1.0
	Author:
	Official Distribution: http://inkeysoftware.com

*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 1.912
	  ; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	  ; It can be found near the top of the InKeyLib.ahki file.
	  ; It may be lower than the InKey version number.
	  ; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	  ; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 2  ; Causes uncaptured character keys to be included in the context too. CAPS-sensitive.

#include InKeyLib.ahki
;________________________________________________________________________________________________________________


$'::InCase(LoopMap("ꞌ '"))
	|| Send("ꞌ")
