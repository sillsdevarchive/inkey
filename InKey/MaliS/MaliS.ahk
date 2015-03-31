/*	InKey script to provide a keyboard layout for MALI modified from GENERIC.

	Keyboard:	MALIs
	Version:	1.0
	Author:		Daniel Brubaker de la SIL
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes. Please give credit as appropriate.

Remarks:


HISTORY:
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 1.912
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


; Type a comma, then another regular letter to get a similar vowel or letter, or a space (normal) to keep the comma
$,::InCase(Map("a ǝ", "e ɛ", "i ɩ", "o ɔ", "u ʋ")) || Send(",")

; Type a regular vowel, then a 7 to get a combined vowel with a grave accent (Low tone), or anything else to keep the number 7
$7::InCase(Replace("$F([aeiou])") with("$R") usingMap("a à", "e è", "i ì", "o ò", "u ù", "A À", "E È", "I Ì", "O Ò", "U Ù"))
	 || Send("7")

; End of Mali Simple trial keyboard which checks the header, the Map function, and the Regular expressions