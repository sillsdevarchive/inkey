/*InKey Script to provide a context-sensitive keyboard layout for NE India Roman script

	Keyboard:	NE Roman
	Version:	1.1
	Authors:	Dan M
	Official Distributionː	http://inkeysoftware.com

	You are free to modify this script for your own purposes.
	Please retain the above authorship details as appropriate.

HISTORY:
2013-01-15  1.0 Initial version
2014-07-30  1.1 Add macron

*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.102
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 2	; Causes uncaptured character keys to be included in the context too. CAPS-sensitive.

#include InKeyLib.ahki

;________________________________________________________________________________________________________________


;*** OnLoadScript Subroutine --------------------------------
OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
;		Perform any script-wide initialization here, such as calls to RegisterRota().

RegisterRota(1, "̀	``", 0x0300, 0, 0x60)	; combining grave accent on backtick (`) key
RegisterRota(2, "̂	^", 0x0302, 0, 0x5e)	; combining circumflex accent on circumflex (^) key
RegisterRota(3, "̈	%", 0x0308, 0, 0x26)	; combining diaeresis on percent (%) key
RegisterRota(4, "̦	[", 0x0326, 0, 0x5b)	; combining comma on left bracket ([) key
RegisterRota(5, "̣ ] ]]	t ṭ t]	T Ṭ T]	n ṇ n]	N Ṇ N]	", 0x0323, 0, 0x5d, 3)	; combining comma on right bracket (]) key
  ; Note: MS Word refuses to accept consonants with the combining dot below, so we use pre-composed characters.
RegisterRota(6, "̃	~", 0x0303, 0, 0x7e)	; combining tilde on tilde (~) key
RegisterRota(7, "̄	_", 0x0304, 0, 0xaf)	; combining macron on underscore (_) key

Return
;*   END OnLoadScript Subroutine

;----------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------
$`::DoRota(1)
$^::DoRota(2)
$%::DoRota(3)
$[::DoRota(4)
$]::DoRota(5)
$~::DoRota(6)
$_::DoRota(7)
