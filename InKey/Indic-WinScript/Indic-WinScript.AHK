/* AutoHotKey Script to provide a context-sensitive keyboard layout

	Keyboard:	Indic Unicode
	Version History:
		ver 0.6 	Added AKey parameter
		ver 0.61	Extended AKey=0 functionality so that aa never produces long AA vowel
		ver 0.62	Allow X and Shift-X to be assigned in the key layout file
		ver 0.63    Add offsets 88-95 and 113 to the range of characters recognized as consonants
					Add handlers for Oriya YYA and WA
		ver 0.64	Adjust MAL chillu rotas (40, 41), and fix that they are called by NONJOIN function
					Press $ to obtain rupee symbol.
		ver 0.65	2011-02-10	Add offsets 112-113 to the range of characters recognized as consonants in Bengali script.
		ver 0.66	2011-07-1	Adjustments for Gurmukhi
		ver 0.67	2011-08-13	Swap MAL chillu from NONJOIN to JOIN.
		ver 0.68	2012-11-30  More adjustments for Gurmukhi
		ver 0.69	2014-08-05	Add UseNukta and ViramaAnywhere
		ver 0.70  2015-03-02	Add AVAGRAHA
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.092
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 1	; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki

;________________________________________________________________________________________________________________

;--------------------------------
OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
;		Perform any script-wide initialization here, such as calls to RegisterRota().

	; Rota to be used, selected according to Danda parameter
	RegisterRota(0, "..	…", 0x2E)	; 0 => never use Danda (but use elipsis)
	RegisterRota(1, "। ॥ .	…", 0x964)	; 1=> Use Danda by default
	RegisterRota(2, ". । …	॥", 0x2E)	; 2 (Default) => Use period, but make danda available.

	; Rota string for U
	RegisterRota(3, "ु ू ूउ ुउ	उ ऊ	ু ূ ূউ ুউ	উ ঊ	ੁ ੂ ੂਉ ੁਉ	ਉ ਊ	ુ ૂ ૂઉ ુઉ	ઉ ઊ	ୁ ୂ ୂଉ ୁଉ	ଉ ଊ	ு ூ ூஉ ுஉ	உ ஊ	ు ూ ూఉ ుఉ	ఉ ఊ	ು ೂ ೂಉ ುಉ	ಉ ಊ	ു ൂ ൂഉ ുഉ	ഉ ഊ"
			, 0, 0, 0, 11)

	; Rota string for E
	RegisterRota(4, "ॆ े ै ॅ	ऎ ए ऐ ऍ	এ ঐ	ে ৈ	ਏ ਐ	ੇ ੈ	એ ઐ ઍ	ે ૈ ૅ	ଏ ଐ	େ ୈ	எ ஏ ஐ ெ ே ை	ఎ ఏ ఐ	ె ే ై	ಎ ಏ ಐ	ೆ ೇ ೈ	എ ഏ ഐ	െ േ ൈ"
			, 0, 0x65, 0, 11)

	; Rota string for I, enables you to type ii to get long i.  if you actually wanted a sequence of i, keep pressing i.
	RegisterRota(5, "ि ी ीइ िइ	इ ई	ি ী ীই িই	ই ঈ	ਿ ੀ ੀਇ ਿਇ	ਇ ਈ	િ ી ીઇ િઇ	ઇ ઈ	ି ୀ ୀଇ ିଇ	ଇ ଈ	ி ீ ீஇ ிஇ	இ ஈ	ి ీ ీఇ ిఇ	ఇ ఈ	ಿ ೀ ೀಇ ಿಇ	ಇ ಈി ീ ീഇ ിഇ	ഇ ഈ"
			, 0, 0, 0, 11)

	; Rota string for O
	RegisterRota(6, "ऒ ओ औ ऑ	ॊ ो ौ ॉ	অৗ ও ঔ	ৗ ো ৌ	ਓ ਔ ੋ ੌ	ઓ ઔ	ો ૌ	ଓ ଔ	ୋ ୌ	ஒ ஓ ஔ	ொ ோ ௌ	ఒ ఓ ఔ	ొ ో ౌ	ಒ ಓ ಔ	ೊ ೋ ೌ	ഒ ഓ ഔ	ൊ ോ ൌ"
			, 0, 0x6F, 0, 11)

	; Rota for N-like consonants
	RegisterRota(11, "न ण ऩ ञ ङ	ন ণ ঞ ঙ	ਨ ਣ ਞ ਙ	ન ણ ઞ ઙ	ନ ଣ ଞ ଙ	ந ன ண ஞ ங	న ణ ఞ ఙ	ನ ಣ ಞ ಙ	ന ണ ഞ ങ"
			, 0, 0x6E, 0, 11)

	; Rota for L-like consonants
	RegisterRota(12, "ल ळ ऴ	ਲ ਲ਼	લ ળ	ଲ ଳ	ல ள ழ	ల ళ	ಲ ಳ	ല ള ഴ"
			, 0, 0, 0, 11)

	; Rota for R-like consonants
	RegisterRota(13, "र ऱ	ਰ ੜ	র ৰ ৱ	ர ற	ర ఱ	ರ ಱ	ര റ"
			, 0, 0, 0, 11)

	; Rota for S-like consonants
	RegisterRota(14, "स ष श	স ষ শ	ਸ ਸ਼	સ ષ શ	ସ ଷ ଶ	ஸ ஷ ஶ	స ష శ	ಸ ಷ ಶ	സ ഷ ശ"
			, 0, 0, 0, 11)

	; Rota for P-like consonants
	RegisterRota(15, "प फ	প ফ	ਪ ਫ	પ ફ	ପ ଫ	ప ఫ	ಪ ೞ ಫ	പ ഫ"
			, 0, 0x70, 0, 11)

	; Rota for T-like consonants
	RegisterRota(16, "ত ৎ"
			, 0, 0x74, 0, 11)

	; Malayalam Atomic Chillu
	RegisterRota(40, "ണ് ൺ	ന് ൻ	ര് ർ	റ് ർ	ല് ൽ	ള് ൾ	ക് ൿ"
			, 0, 0, 0, 3)

	; Malayalam Chillu prior to Unicode 5.1
;	RegisterRota(41, "ണ് ണ്‍	ന് ന്‍	ര് ര്‍	റ് ര്‍	ല് ല്‍	ള് ള്‍	‍"
;n			, 0, 0, 0, 3)

	; Rupee symbol
	RegisterRota(50, "₹ $ ₨"
			, 0x20b9, 0, 0x24, 0)

	; Bracket alternations
	RegisterRota(100, "( [ {	) ] }"
			, 0, 0, 0, 1)

	; Quote alternations from smart to plain
	RegisterRota(101, "“ ""	” ""	‘ '	’ '"
			, 0, 0, 0, 3)

	; Pressing minus key
	RegisterRota(102, "- – —	——", 0x2D)
	;|	- ­ – —		 002D |  2013 |  2014		 hyphen-minus |  en_dash |  em_dash
	;|	——		 2014 2014		 em_dash em_dash

	;  left/right brackets
	RegisterRota(103, "( [ { ⌊	((", 0x28)
	RegisterRota(104, ") ] } ⌋	))", 0x29)

	; bindi/tippi for gurmukhi.  Optional: If certain characters always take tippi, never bindi, add those to the rota.
	RegisterRota(105, "ਂ ੰ", 0x0A02)

return

;--------------------------------
OnLoadKeyboard:	; InKeyLib will call this subroutine the first time InKey calls on this script for a particular keyboard.
;			(The user may configure multiple keyboards from a single keyboard script, if the keyboard script
;			supports parameters.)  The parameter string associated with the current keyboard will be contained in
;			the global named K_Params.
;			Perform any one-time keyboard-specific initialization here, such as any calls to RegisterKbdRota().
;			Also, if you need it, the numeric identifier that InKey has assigned to the current keyboard will be
;			contained in the global named K_ID.  It may be useful to use this as an array index for storing
;			keyboard-specific values.  (This may be more efficient than re-processing the K_Param string each
;			time OnKeyboardInit is called.)


	script%K_ID% := GetParam("Script", 1) ; Select a particular Indic script
	s := script%KID%
	outputdebug OLK: script%KID%=%s%
	sbase%K_ID% := 128 * (script%K_ID% - 1) + 0x900

	ScriptDigit%K_ID% := GetParam("ScriptDigit", 0) ; Determine whether to use script digits by default (and CapsLock for Roman digits)
	UseShortO%K_ID% := GetParam("UseShortO", 0) ; Determine whether to use the short O
	UseShortE%K_ID% := GetParam("UseShortE", 0) ; Determine whether to use the short E
	AtomicChillu%K_ID% := (script%K_ID% = 9) ? GetParam("AtomicChillu", 0) : 0 ; Determine whether to use Atomic Chillu characters (in Malayalam)
	UseNukta%K_ID% := GetParam("UseNukta", InStr("679", script%K_ID%) ? 0 : 1) ; Determine whether to use the Nukta in a script that does not ordinarily support it (i.e. TAM/TEL/MAL).
	ViramaAnywhere%K_ID% := GetParam("ViramaAnywhere", 0) ; Determine whether to permit virama to be typed anywhere. e.g. after vowels

	AKey%K_ID% := GetParam("AKey", 1) ; Type 'a' twice to get long AA vowel.  e.g. typing 'kaa' produces का (1) or कअ (0)
	SmartQuotes%K_ID% := GetParam("SmartQuotes", 0)

	; Determine which Danda/Fullstop rota to use (0, 1, or 2)
	Danda%K_ID% := GetParam("Danda", 2)
	if (Danda%K_ID% > 1 or Danda%K_ID% < 0)
		Danda%K_ID% = 2

	; Read the key layout file
	if not RegExMatch(K_Params, "i)(?<=\blayout=)\S+", file)
		file := "default.txt"
	Loop, read, %file%
	{
		p := InStr(A_LoopReadLine, "=")
		if (p) {
			label := SubStr(A_LoopReadLine, 1, p-1)
			hk := SubStr(A_LoopReadLine, p+1)
			if (not IsLabel(label))
				FatalError("Invalid Indic key name '" . label . "' on line " . A_Index . " of layout file '" . file . "'.")
			if (key%label% <> hk) {
				key%label% := hk
				; outputdebug [%label%] {%hk%}
				Hotkey $%hk%, %label%, UseErrorLevel
				if (ErrorLevel)
					FatalError("Error (#" . ErrorLevel . ") on line " . A_Index . " of layout file '" . file . "'." . chr(10) . A_LoopReadLine)
			}
		}
	}
	if (not keyJOIN) {  ; key layout file was created before the JOIN and NONJOIN functions were in place there;
		Hotkey $x, JOIN, UseErrorLevel
		Hotkey $+x, NONJOIN, UseErrorLevel
	}
return

;--------------------------------
OnKeyboardInit:		; This subroutine will be called immediately after OnLoadKeyboard, and again every time the current
;			keyboard is changed or needs to be reinitialized.
;			For the sake of efficiency, avoid any processing here that could be performed just once by OnLoadKeyboard.
;			The parameter string associated with the current keyboard will be contained in the global named K_Params.
;			(Also, if you need it, the numeric identifier that InKey has assigned to the
;			current keyboard will be contained in the global named K_KeyboardID.)

	script := script%K_ID%
	outputdebug script=%script%
	sbase := sbase%K_ID%
	ScriptDigit := ScriptDigit%K_ID%
	UseShortE := UseShortE%K_ID%
	UseShortO := UseShortO%K_ID%
	UseNukta := UseNukta%K_ID%
	ViramaAnywhere := ViramaAnywhere%K_ID%
	Danda := Danda%K_ID%
	AtomicChillu := AtomicChillu%K_ID%
	SmartQuotes := SmartQuotes%K_ID%
	AKey := AKey%K_ID%
	outputdebug script=%script%, sbase=%sbase%
return

;=================================================================================================
IsIndicConsonantal(offset) { ; returns true if character at offset is a consonant or a nukta
	global script
	return ((offset>=21 and offset<=60) or (offset>=88 and offset<=95) or (script=5 and offset=113) or (script=2 and (offset=112 or offset=113)))  ; Note: If code points 58 and 59 are ever defined, they may need to be excluded from this
}


;*** Initial glyphs ----------------
CANDRABINDU:					; 	Key: Shift+S
SendChar(sbase + 1)			;	CANDRABINDU
return

ANUSVARA:					; 	Key: Shift+M
if (script = 3)
	DoRota(105)
else
	SendChar(sbase + 2)		;	ANUSVARA
return

VISARGA:					;	Key: Shift+H
SendChar(sbase + 3)		;	VISARGA
return

AVAGRAHA:					;  Key: 	Shift+F
SendChar(sbase + 61)		;	AVAGRAHA
return


NUKTA: 					;	Key: F
if (UseNukta = 0)
	SoundPlay *-1
else if (ctx() = 0x93C)
	ReplaceChar(0x970, 1, 1, 0x66)	; replace DEV NUKTA with DEV ABBREVIATION SYMBOL
else
	SendChar(sbase + 60)	;	NUKTA
return
;*க஼

; ==============================================================================
;*** Vowels
; ==============================================================================

DoVowel(syl, dep, uFlags=0) { ; Send syllabic or dependent character,
	global		    ; determined by whether context is in Consonant range of Indic.
	SendChar(sbase + (IsIndicConsonantal(ctx() - sbase) ? dep : syl), uFlags)
}

A:			;	Key:	A
cc := ctx()
ic := cc - sbase
outputdebug INIT A: cc=%cc%, ic=%ic%, AKey=%AKey%
if (ic >= 21 and ic <= 57) {
	SendChar(1, 0x61)  ; Only adds to the context stack.  Simplifies typing  गए as gae
	PreviewChar(sbase + 62)
	;ToolTipU("ा")
} else	{
	ff := flags()
	if (cc = 1 and ff = 0x61 and AKey <> 0) {
		;outputdebug last one was nul
		SendChar(sbase + 62, 0x61)	; So send aakar
		PreviewChar(sbase + 5)	; preview AA
	} else if (ic = 62 and ff = 0x61) {	;  if it was aakar created by this key
		;outputdebug last one was aakar
		ReplaceChar(sbase + 5, 1, 1, 0x61)	; replace with AA
	} else if (ic = 5 and ff = 0x61 and AKey <> 0) {	;  if it was A created by this key
		ReplaceChar(sbase + 6, 1, 1, 0x61)	; replace with AA
	} else {
		;outputdebug none of these. cc=%cc%, ic=%ic%, ff=%ff%
		SendChar(sbase + 5, 0x61)	;	LETTER A
	}
}
return

AA:			;	Key:	Shift+A
DoVowel(6, 62)		;	LETTER AA, VOWEL SIGN AA
return

I:			;	Key:	I
if (not DoRota(5))
	DoVowel(7, 63)		;	LETTER I, VOWEL SIGN I
return

II:			;	Key:	Shift+I
;if (not DoRota(5))
	DoVowel(8, 64)		;	LETTER II, VOWEL SIGN II
return

U:			;	Key:	U
if (not DoRota(3))
	DoVowel(9, 65)		;	LETTER U, VOWEL SIGN U
return

UU:			;	Key:	Shift+U
DoVowel(10, 66)		;	LETTER UU, VOWEL SIGN UU
return

; q & $r::
; SendChar(42)
; return

VOC_R:			;	Key:	Shift+R
if (script = 3)
	DoConsonant(92)		;	GUR LETTER RRA
else if (script = 6)
	DoConsonant(49)		;	TAM LETTER RRA
else
	DoVowel(11, 67)		;	LETTER VOCALIC R, VOWEL SIGN VOCALIC R
return

VOC_RR:			;	Key:	^
DoVowel(96, 68)		;	LETTER VOCALIC RR, VOWEL SIGN VOCALIC RR
return

VOC_L:			;	Key:	|
if (InStr("36", script))
	SendChar(0x7C)		;	VERTICAL LINE
else
	DoVowel(12, 98)		;	LETTER VOCALIC L, VOWEL SIGN VOCALIC L
return

VOC_LL:			;	Key:	_
DoVowel(97, 99)		;	LETTER VOCALIC LL, VOWEL SIGN VOCALIC LL
return

CANDRA_E:			;	Key:	]
if (InStr("14", script))
	DoVowel(13, 69)		;	LETTER CANDRA E, VOWEL SIGN CANDRA E
else if (script = 3) {
	SendChar(sbase + 113)
} else {
	SendChar(0x5D)		;	RIGHT SQUARE BRACKET
}
return

E:			;	Key:	E (or Shift+Y for Indo-Aryan)
if (not UseShortE)
	goto EE
if (not DoRota(4))
	DoVowel(14, 70, 0x65)		;	LETTER E, VOWEL SIGN E
return

EE:			;	Key:	Shift+E
if (not DoRota(4))
	DoVowel(15, 71, 0x65)		;	LETTER EE, VOWEL SIGN EE
return

AI:			;	Key:	Shift+Y
DoVowel(16, 72)		;	LETTER AI, VOWEL SIGN AI
return

CANDRA_O:			;	Key:	}
if (InStr("14", script))
	DoVowel(17, 73)		;	LETTER CANDRA O, VOWEL SIGN CANDRA O
else
	SendChar(0x7D)		;	RIGHT CURLY BRACKET
return

O:			;	Key:	O
if (not UseShortO)
	goto OO
if (DoRota(6))
	return
if (script = 2) { ; Bengali script.  For languages needing an independent short O, we use a composite character. Requires a decent usp10.dll to render properly.
	if (not IsIndicConsonantal(ctx() - sbase))
		SendChar(0x985)	;|
	SendChar(0x9D7, 0x6F)		;|
} else
	DoVowel(18, 74, 0x6F)		;	LETTER O, VOWEL SIGN O
return

OO:			;	Key:	Shift+O
if (not DoRota(6))
	DoVowel(19, 75, 0x6F)		;	LETTER OO, VOWEL SIGN OO
return

AU:			;	Key:	Shift+V
DoVowel(20, 76)		;	LETTER AU, VOWEL SIGN AU
return
;*

; ==============================================================================
;*** Consonants
; ==============================================================================

DoPreConsCheck() {
	; f := flags()
	; if (f = 0x78)	; created in response to "x" key
		; SendChar(0x200D) 	; JOINER
	; else if (f = 0x58)  ; created in response to "+x" key
		; SendChar(0x200C) 	; NON-JOINER
}

DoConsonant(offset, rota=0, uFlags=0) {
	global sbase
	;outputdebug DoCons(%offset%, %rota%, %uflags%)
	DoPreConsCheck()

	if (rota = 0)
		SendChar(sbase + offset, uFlags)
	else if (not DoRota(rota)) {
		outputdebug SendRotaChar(%rota%, %sbase% + %offset%,  %uflags%)
		SendRotaChar(rota, sbase + offset, uFlags)  ; Ensures that preview is updated if applicable
	}
}

KA:			;	Key:	K
DoConsonant(21)		;	LETTER KA
Return

KHA:			;	Key:	Shift+K
DoConsonant((script = 6) ? 21 : 22)		;	LETTER KHA
Return

GA:			;	Key:	G
DoConsonant((script = 6) ? 21 : 23)		;	LETTER GA
Return

GHA:			;	Key:	Shift+G
DoConsonant((script = 6) ? 21 : 24)		;	LETTER GHA
Return

NGA:			;	Key:	Shift+W
DoConsonant(25)		;	LETTER NGA
Return

CA:			;	Key:	C
DoConsonant(26)		;	LETTER CA
Return

CHA:			;	Key:	Shift+C
DoConsonant((script = 6) ? 26 : 27)		;	LETTER CHA
Return

JA:			;	Key:	J
DoConsonant(28)		;	LETTER JA
Return

JHA:			;	Key:	Shift+J
DoConsonant((script = 6) ? 28 : 29)		;	LETTER JHA
Return

NYA:			;	Key:	W
DoConsonant(30)		;	LETTER NYA
Return

TTA:			;	Key:	T
DoConsonant(31)		;	LETTER TTA
Return

TTHA:			;	Key:	Shift+T
DoConsonant((script = 6) ? 31 : 32)		;	LETTER TTHA
Return

DDA:			;	Key:	D
DoConsonant((script = 6) ? 31 : 33)		;	LETTER DDA
Return

DDHA:			;	Key:	Shift+D
DoConsonant((script = 6) ? 31 : 34)		;	LETTER DDHA
Return

NNA:			;	Key:	Shift+N
DoConsonant(35)		;	LETTER NNA
Return

TA:			;	Key:	Q
DoConsonant(36, 16, 0x74)		;	LETTER TA
Return

THA:			;	Key:	Shift+Q
DoConsonant((script = 6) ? 36 : 37)		;	LETTER THA
Return

DA:			;	Key:	[
if (script=6)
	SendChar(0x5B)		; 	LEFT SQUARE BRACKET
else
	DoConsonant(38)		;	LETTER DA
Return

DHA:			;	Key:	{
if (script=6)
	SendChar(0x7B)		; 	LEFT CURLY BRACKET
else
	DoConsonant(39)		;	LETTER DHA
Return

NA:   			;	Key: N
DoConsonant(40, 11, 0x6E)  	;	 LETTER NA
Return

PA:			;	Key:	P
DoConsonant(42, 15, 0x70)		;	LETTER PA
Return

PHA:			;	Key:	Shift+P
DoConsonant((script = 6) ? 42 : 43)		;	LETTER PHA
Return

BA:			;	Key:	B
DoConsonant((script = 6) ? 42 : 44)		;	LETTER BA
Return

BHA:			;	Key:	Shift+B
DoConsonant((script = 6) ? 42 : 45)		;	LETTER BHA
Return

MA:			;	Key:	M
DoConsonant(46)		;	LETTER MA
Return

YA:			;	Key:	Y
DoConsonant(47)		;	LETTER YA
Return

YYA:  ; Only for Oriya YYA
DoConsonant(95)
return

RA:			;	Key:	R
DoConsonant(48, 13)		;	LETTER RA
Return

LA:			;	Key:	L
DoConsonant(50, 12)		;	LETTER LA
Return

LLA:			;	Key:	Shift+L
if (script = 3){	; bending over backwards to produce NFC for Gurmukhi
	DoPreConsCheck()
	if (not DoRota(12)) {
		; SendRotaChar(rota, sbase + offset, uFlags)  ; Ensures that preview is updated if applicable
		SendChars("0xA32,0xA3C")
	}
} else
	DoConsonant(51, 12)		;	LETTER LLA
Return

WA:  ; Only for Oriya WA
DoConsonant(113)
return

VA:			;	Key:	V
if (script = 2)
	DoConsonant(113)	; Assamese VA
;else if (script = 5 and ctx() = 0xB35)
;	ReplaceChar(0xB71)	; Oriya WA
else
	DoConsonant(53)		;	LETTER VA
Return

SHA:			;	Key:	Z
if (script = 3){	; bending over backwards to produce NFC for Gurmukhi
	DoPreConsCheck()
	if (not DoRota(14)) {
		; SendRotaChar(rota, sbase + offset, uFlags)  ; Ensures that preview is updated if applicable
		SendChars("0xA38,0xA3C")
	}
} else
	DoConsonant(54, 14)		;	LETTER SHA
Return

SSA:			;	Key:	Shift+Z
DoConsonant(55, 14)		;	LETTER SSA
Return

SA:			;	Key:	S
DoConsonant(56, 14)		;	LETTER SA
Return

HA:			;	Key:	H
DoConsonant(57)		;	LETTER HA
Return

;*

;---------------------------------------------
;*** Toggle prior char between full and half form
;$;::		; Key: semi-colon (;)
;SendChar(sbase + 77)
;return

JOIN:        ; Key: X
	cc := ctx()
	ci := cc - sbase
	if (IsIndicConsonantal(ci)) {    ; If consonant context, send virama
		SendChar(sbase + 77)
	} else if (script = 9 and AtomicChillu and DoRota(40)) {
		; Did MALAYALAM Atomic chillu
	} else if (ci = 77) {  ; If virama context, send ZW Joiner
		SendChar(0x200D)
		; maybe some additional cue would be helpful, like a click or something in the tooltip
	} else if (cc = 32) {
		ReplaceChar(0x200D)  ; To get an isolated ZWJ, type:  {space} {x}
	} else if (ViramaAnywhere) {
		SendChar(sbase + 77)   ; may be used as a form of vowel modifier
	}
	return

NONJOIN:		; Key: Shift+X
	outputdebug NONJOIN
	cc := ctx()
	ci := cc - sbase
	if (IsIndicConsonantal(ci)) {    ; If consonant context, send ZW Non-Joiner
		SendChar(sbase + 77)
		SendChar(0x200C)
	} else if (cc = 32) {
		ReplaceChar(0x200C)	; To get an isolated ZWNJ, type:  {space} {shift x}
	}
	; else if virama or virama+ZWJ, we could replace that with virama+ZWNJ
	; else we could perhaps do some other kind of vowel alternation here
	return


;	toggleFullOrHalf(SubStr(A_ThisHotKey,2))
;	return
;
toggleFullOrHalf(hk) {
	global sbase
	global script
	global AtomicChillu
	cc := ctx()
	ci := cc - sbase
	if (hk = "x")  {
	outputdebug x pressed. script=%script%. AtomicChillu=%AtomicChillu%
		if (script = 9) {
			outputdebug script is 9
			if (DoRota(AtomicChillu ? 40 : 41))
				return
			outputdebug no chillu
		}
		uFlags = 0x78		; If X was pressed, set flags to 0x78 (for joiner)
	} else if (hk = "+x")
		uFlags = 0x58		; If Shift+X was pressed, set flags to 0x58 (for non-joiner)
	else
		uFlags = 0
	if (IsIndicConsonantal(ci)) {    ; If consonant context, send virama
		SendChar(sbase + 77, uFlags)
	} else if (ci = 77) {  ; If virama context, undo it
		Back()
	} else if (ci >= 62 and ci <= 76)  {   ; If dependent vowel context,
		ReplaceChar(ctx() - 56)				; replace with independent vowel.
	} else if (ci >= 6 and ci <= 20)  {   ; If independent vowel context (except A),
		ReplaceChar(ctx() + 56)				; replace with dependent vowel.
	} else {
		SendChar(sbase + 77, UFlags)  		  ; send virama
	}
}
;*

;*** Key: `   Toggles prior chars between alternate forms.
$`::
cc := ctx()
ci := cc - sbase
; For consonants, toggle between alternate conjuncts.
if (ci >= 21 and ci <= 57) { ; if most recent context is CONS  (TODO: Allow for toggling conjucts with nukta already pressed)
	ctx2 := ctx(2)
	if (ctx2 = sbase + 77)  {     ; if prior to that (CONS) was VIRAMA
		InsertChar(0x200D)            ; insert joiner
		TrayTipQ("Joined Conjunct")
	} else if (ctx2 = 0x200D) {   ; else if prior to that (CONS) was already JOINER,
		ReplaceChar(0x200C,1,2)       ; replace JOINER (i.e. the 1 char ending 2 chars back) with NONJOINER
		TrayTipQ("Non-Joined Conjunct")
	} else if (ctx2 = 0x200C) {	  ; else if prior to that (CONS) was NONJOINER,
		DeleteChar(1,2)               ; delete NONJOINER (i.e. the 1 char ending 2 chars back)
		TrayTipQ("Simple Conjunct")
	} else {
		SoundPlay *-1
	}

; For digits, toggle between script and Roman.
} else if (cc >= 48 and cc <= 57) {  ; Roman digit -> script digit
	ScriptDigit := 1
	ScriptDigit%K_ID% := 1
	ReplaceChar(cc + sbase + 54)  ; 101 - 48 = 53
} else if (ci >= 102 and ci <= 111) {
	ScriptDigit := 0
	ScriptDigit%K_ID% := 0
	ReplaceChar(ci - 54) ; Script digit -> roman

; For vowels, toggle between dependent and independent
} else if (ci >= 62 and ci <= 76)  {   ; If dependent vowel context,
	ReplaceChar(ctx() - 56)				; replace with independent vowel.
} else if (ci >= 6 and ci <= 20)  {   ; If independent vowel context (except A),
	ReplaceChar(ctx() + 56)				; replace with dependent vowel.

} else if (DoRota(100)) {	; bracket alternation
	return

} else if (DoRota(101)) {
	SmartQuotes := 0	; Turn smart quotes off
	SmartQuotes%K_ID% := SmartQuotes
	return
} else if (cc = 0x27) {  ; single quote
	Back()
	SmartQuotes := 1
	SmartQuotes%K_ID% := SmartQuotes
	DoQuoteMark(0x27, 0x2018, 0x2019) ;
} else if (cc = 0x22) {  ; double quote
	Back()
	SmartQuotes := 1
	SmartQuotes%K_ID% := SmartQuotes
	DoQuoteMark(0x22, 0x201C, 0x201D)	; smart double quotes
} else if (cc = 1 and flags() = 0x61) { ; turn inherent vowel into independent vowel
	SendChar(sbase + 5)	;	LETTER A

; Other uses for this "alternate form" key may still be implemented...
} else {
	SoundPlay *-1
}
return
;*

;  Key: Period (.)
$.::DoRota(Danda)  ; Toggles between  danda, double danda, and period.

;*** ALL DIGIT KEYS
$0::
$1::
$2::
$3::
$4::
$5::
$6::
$7::
$8::
$9::DoDigit(SubStr(A_ThisHotKey,2))  ; A_ThisHotKey will include the $, so we trim that.

DoDigit(dd) {
	global
	local sd
	local cc := ctx()
	if (cc > 47 and cc < 58) {
		sd := 0	; If context is roman digit, do roman.
	} else {
		cc -= sbase
		if (cc >= 102 and cc <= 111)  ; If context is script digit, do script.
			sd := 1
		else   	; Default: Send a roman digit unless CapsLock is turned on.
			sd := GetKeyState("CapsLock", "T") ^ ScriptDigit  ; The ScriptDigit command line parameter reverses this logic.
	}
	SendChar(dd + ((sd) ? sbase + 102 : 48))  ; Add to sbase+102 for script numeral, or to 48 for roman numeral.
}
;*
; maybe implement it like this: (still to resolve:  how to insert tone mark in sequence)
; smart on, DBL pressed:
; \ 0 or leftSG-> leftDB
; \ leftDB -> REPLACE w/ rightDB
; \ rightDB -> REPLACE plainDB [turn smart off]
; \else -> rightDB

; smart off, DBL pressed:
; \ plain -> remove plain, turn on smart, send DBL
; \else -> plain

$"::DoQuoteMark(0x22, 0x201C, 0x201D)	; smart double quotes

$'::	; apostrophe key (') for tone mark or single quotes
; if (ApostropheForTone)    ; copied from DevRom, but not yet implemented here
	;SendChar(0x2019)		; In Dogri, the apostrophe is used as a tone marker  ;|	right_single_quotation_mark (’)
;else
	DoQuoteMark(0x27, 0x2018, 0x2019) ; Treat it as a single-quote marker
return

DoQuoteMark(plain, left, right) {
	global SmartQuotes
	cc := ctx()
	if (not SmartQuotes) {
		if (cc<>plain) {
			SendChar(plain)
			return
		}
		Back()
		SmartQuotes := 1
		SmartQuotes%K_ID% := SmartQuotes
		cc := ctx()
	}

	if (cc=left) {
		ReplaceChar(right)
	} else if (cc=right) {
		ReplaceChar(left)
	} else {
		SendChar((cc>32 and cc<>0x201c and cc<>0x2018) ? right : left)
	}
}
	; ff := flags()	; we'll use the flags to store the alternate of the character actually sent, so that a repeat press can reverse it.
	; cc := ctx()
	; if (ff=plain or ff=left or ff=right) {	; if last char was generated here
		; ReplaceChar(ff, 1, 1, cc)  	; we'll swap the flag and the character itself
		; SmartQuotes := SmartQuotes ^ 1
	; } else {
		; smartQChar := cc>32 ? right : left
		; if (smartQuotes)
			; SendChar(smartQChar, plain)
		; else
			; SendChar(plain, smartQChar)
	; }

$-::DoRota(102)  ; minus key
$(::DoRota(103)	; left brackets
$)::DoRota(104)	; right brackets
$$::DoRota(50)	; rupee symbol / dollar sign
;-----------------------
;*** Not yet implemented. No conflict between scripts:

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 78)		;	KHANDA TA (Bengali only)
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 80)		;	OM
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 81)		;	STRESS SIGN UDATTA
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 82)		;	STRESS SIGN ANUDATTA
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 83)		;	GRAVE ACCENT
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 84)		;	ACUTE ACCENT
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 85)		;	LENGTH MARK
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 86)		;	AI LENGTH MARK
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 87)		;	AU LENGTH MARK
; return

; $::					;  Key: 	TODO: NOT YET IMPLEMENTED
; SendChar(sbase + 125)		;	LETTER GLOTTAL STOP
; return

;-----------------------
; Not yet implemented. Conflict exists between different scripts:

; Characters 112-122 are used by different scripts for very different purposes:
; DEV: Abbreviation sign
; BEN: letter ra with middle/lower diagonals, rupee mark/sign, currency numerators, isshar
; GUR: tippi, addak, iri, ura, ek onkar
; GUJ: rupee sign
; ORI: isshar, letter wa
; TAM: 10, 100, 1000, day, month, year, debit, credit, as above, rupee, number
; One option is to use neutral keystrokes
;*
