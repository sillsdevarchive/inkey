/*	InKey script to provide a keyboard layout for Xinaluq

	Keyboard:	Khinalug Unicode
	Version:    1.0
	Author:     Ben Chenoweth
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

$sc029:: SendChar(1, 96)		; ` > DEADKEY

;________________________________________________________________________________________________________________
; Numbers and Punctuation above numbers
;________________________________________________________________________________________________________________

$sc002:: SendChar(0x31) ;| 1
$sc003:: SendChar(0x32) ;| 2
$sc004:: SendChar(0x33) ;| 3
$sc005:: SendChar(0x34) ;| 4
$sc006:: SendChar(0x35) ;| 5
$sc007:: SendChar(0x36) ;| 6
$sc008:: SendChar(0x37) ;| 7
$sc009:: SendChar(0x38) ;| 8
$sc00A:: SendChar(flags() = 96 ? 0xAB : 0x39) ;| « 9
$sc00B:: SendChar(flags() = 96 ? 0xBB : 0x30) ;| » 0

$+sc002:: SendChar(0x21)  ;| ! > !
$+sc003:: SendChar(0x22)  ;| @ > "
$+sc004:: SendChar(0x23)  ;| # > #
$+sc005:: SendChar(0x3B)  ;| $ > ;
$+sc006:: SendChar(0x25)  ;| % > %
$+sc007:: SendChar(0x3A)  ;| ^ > :
$+sc008:: SendChar(0x3F)  ;| & > ?
$+sc009:: SendChar(0x2A)  ;| * > *
$+sc00A:: SendChar(0x28)  ;| ( >
$+sc00B:: SendChar(0x29)  ;| ) >


$sc02B:: SendChar(0x27)  ;| \ > '
$w:: SendChar(0xFC)  ;| ü
$t::
If (flags() = 96)
	{
		SendChar(0x74) ;| t
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x74) ;| t
return
$p::
If (flags() = 96)
	{
		SendChar(0x70) ;| p
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x70) ;| p
return
$h:: SendChar(flags() = 96 ? 0x127 : 0x68) ;| ħ h
$k::
If (flags() = 96)
	{
		SendChar(0x6B) ;| k
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x6B) ;| k
return
$sc01A:: SendChar(0xF6)   ;| [ > ö
$sc01B:: SendChar(0x11F)  ;| ] > ğ
$sc027:: SendChar(0x131)     ;| ; > ı
$sc028:: SendChar(0x259)      ;| ' > ə
$sc033::                  ;| ,
If (flags() = 96)
	{
		SendChar(0xE7)    ;| ç
		SendChar(0x301)   ;| ́
	}
else
	SendChar(0xE7)  ;| ç
return
$sc034:: SendChar(0x15F)  ;| . > ş
$sc035:: SendChar(0x2E)  ;| / > .
$+w:: SendChar(0xDC)  ;| Ü
$+t::
If (flags() = 96)
	{
		SendChar(0x54) ;| T
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x54) ;| T
return
$+i:: SendChar(0x130)  ;| İ
$+p::
If (flags() = 96)
	{
		SendChar(0x50) ;| P
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x50) ;| P
return
$+h:: SendChar(flags() = 96 ? 0x126 : 0x48) ;| Ħ H
$+k::
If (flags() = 96)
	{
		SendChar(0x4B) ;| K
		SendChar(0x301) ;| ́
	}
else
	SendChar(0x4B) ;| K
return
$+sc01A:: SendChar(0xD6)  ;| { > Ö
$+sc01B:: SendChar(0x11E)  ;| } > Ğ
$+sc027:: SendChar(0x49)  ;| : > I
$+sc028:: SendChar(0x18F)  ;|" > Ə
$+sc033::             ;|  <
If (flags() = 96)
	{
		SendChar(0xC7) ;| Ç
		SendChar(0x301) ;| ́
	}
else
	SendChar(0xC7)  ;| Ç
return
$+sc034:: SendChar(0x15E)  ;| > > Ş
$+sc035:: SendChar(0x2C)  ;| ? > ,
