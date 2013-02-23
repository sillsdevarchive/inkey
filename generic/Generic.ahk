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

K_MinimumInKeyLibVersion = 0.900
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; Look it up near the top of the InKeyLib.ahki file, and enter it here.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

 K_UseContext = 1	; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki

;________________________________________________________________________________________________________________
OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.

return

;________________________________________________________________________________________________________________
;   Key Handlers


