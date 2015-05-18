/*	InKey script to provide a keyboard layout for Bambam
	  Autogenerated by InKeyKeyboardCreator

	Keyboard:	Bambam
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
RegisterRota(1, "͒ ^", 0x352, 0, 0, 8)  ;| ͒ ^
return
;________________________________________________________________________________________________________________

$z::
SendChar(0xC4)  ;| Ä
return
$x::
SendChar(0xE4)  ;| ä
return
$^::
DoRota(1)
return
${::
SendChar(0xD834)  ;| �
SendChar(0xDD77)  ;| �
return
$}::
SendChar(0xD834)  ;| �
SendChar(0xDD78)  ;| �
return
$^>:: SendChar(0x323)  ;| ̣