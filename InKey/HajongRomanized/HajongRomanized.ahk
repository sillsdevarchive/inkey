/*	InKey script to provide a keyboard layout for Hajong Romanized.

	Keyboard:	Hajong Romanized
	Version:	1.0
	Author:
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes. Please give credit as appropriate.

Remarks:

HISTORY:
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:
K_MinimumInKeyLibVersion = 0.092	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.
K_UseContext = 1
#include InKeyLib.ahki

;________________________________________________________________________________________________________________
;*** OnLoadScript Subroutine --------------------------------
OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
;		Perform any script-wide initialization here, such as calls to RegisterRota().
RegisterRota(1, "e ê", 0x65, 0, 0, 8)  ;| e ê
RegisterRota(2, "o ô", 0x6F, 0, 0, 8)  ;| o ô
RegisterRota(3, "a â", 0x61, 0, 0, 8)  ;| a â
RegisterRota(4, "E Ê", 0x45, 0, 0, 8)  ;| E Ê
RegisterRota(5, "O Ô", 0x4F, 0, 0, 8)  ;| O Ô
RegisterRota(6, "A Â", 0x41, 0, 0, 8)  ;| A Â

Return
;*   END OnLoadScript Subroutine

;--------------------------------

$e:: DoRota(1)
$o:: DoRota(2)
$a:: DoRota(3)
$+e:: DoRota(4)
$+o:: DoRota(5)
$+a:: DoRota(6)
