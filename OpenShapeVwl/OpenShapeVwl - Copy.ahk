/* InKey script to provide a keyboard layout for Nigerian languages

 Version:   3.0
 Authors:    Andy Kellogg and Dan M

*/

;***** CHANGE LOG *****
; Ver 2.0  [AK] fixed cedilla to be NFD compliant
; Ver 2.0  [AK] adjusted hook v and m and saltillo
; Ver 2.0  [AK] adjusted keystroke order to match new Keyman (esp. tone)
; Ver 3.0  [DM] rewrite for InKey 0.900 functions
; Ver 3.0  [DM] prevent nasal from appearing on dotted b/d


;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.900
	  ; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	  ; It can be found near the top of the InKeyLib.ahki file.
	  ; It may be lower than the InKey version number.
	  ; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	  ; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 2  ; Causes uncaptured character keys to be included in the context too, with sensitivity to the state of the CAPS key

#include InKeyLib.ahki
;________________________________________________________________________________________________________________

OnLoadScript:

	return
;________________________________________________________________________________________________________________

OnLoadKeyboard:	; InKeyLib will call this subroutine the first time InKey calls on this script for a particular keyboard.
;			(The user may configure multiple keyboards from a single keyboard script, if the keyboard script
;			supports parameters.)  The parameter string associated with the current keyboard will be contained in
;			the global named K_Params.
;			Perform any one-time keyboard-specific initialization here, such as any calls to RegisterKbdRota().
;			Also, if you need it, the numeric identifier that InKey has assigned to the current keyboard will be
;			contained in the global named K_ID.  It may be useful to use this as an array index for storing
;			keyboard-specific values.  (This may be more efficient than re-processing the K_Param string each
;			time OnKeyboardInit is called.)

	; Determine whether to use smart quotes or chevrons.  The default is smart quotes
	UseSmartQuotes := GetParam("UseSmartQuotes", 1)

	; Determine which set of vowels to use
	VowelMode := GetParam("VowelMode", 1)
	if (VowelMode = 2) {  ; Underlined forms
		usingVowelMap := usingMap("a a̱ ə", "e e̱", "i i̱", "o o̱", "u u̱", "b ɓ", "d ɗ", "A A̱ Ə", "E E̱", "I I̱", "O O̱", "U U̱", "B Ɓ", "D Ɗ")
	} else if  (VowelMode = 3) {  ; Dotted forms
		usingVowelMap := usingMap("a ạ ə", "e ẹ", "i ị", "o ọ", "u ụ", "b ḅ", "d ḍ", "A Ạ Ə", "E Ẹ", "I Ị", "O Ọ", "U Ụ", "B Ḅ", "D Ḍ")
	} else {	; Open forms (default)
		usingVowelMap := usingMap("a ə", "e ɛ", "i ɨ ɪ", "o ɔ", "u ʊ", "b ɓ", "d ɗ", "A Ə", "E Ɛ", "I Ɨ", "O Ɔ", "U Ʊ", "B Ɓ", "D Ɗ")
	}
	return

;________________________________________________________________________________________________________________
; In the following mappings of keystrokes to Unicode characters to send, each keystroke code is prefixed with a
; dollar sign ($), telling InKey to act on the keystroke only if it has not been artificially generated by InKey itself.
; Some keystrokes are then prefixed with a plus sign (+), indicating the shifted form of the key.
; See the AutoHotKey documentation for a full description of the syntax for specifying hotkeys.

;** Consonant and Vowel Rota *******
$;::InCase(Replace("$F([\x{300}-\x{304}\x{30C}]*)") with("$R$1") usingVowelMap)
		or DoRota(0, RotaSets("c ç",	 "g ɣ", "h ɦ", "k ƙ", "m ɱ", "n ŋ ɲ", "s ʃ", "v ʋ", "y ƴ", "z ʒ"
												, "C Ç", "G Ɣ", "K Ƙ", "M Ɱ", "N Ŋ Ɲ", "S Ʃ", "V Ʋ", "Y Ƴ", "Z Ʒ"
												, "? ꞌ"				;Glottal Stop Chars
												, "$ ₦ £"))			;**** Other
		or SendText(";")


;** Tone Rotas *********************
$`::DoRota(4, chr(0x301) " " chr(0x300) " " chr(0x302) " " chr(0x30C) " " chr(0x304) " ")  ; extra space on the end of the rota so that  _not having the diacritic_ is part of the rota
	or InCase(After("[aəeɛiɨɪoɔuʊAƏEƐIƗOƆUƱmɱnŋɲMⱮNŊƝ][\x{331}\x{303}\x{323}]*") ThenSend(chr(0x301)))
	or Beep()  ; send no tone mark, as there's no context to add the tone mark to


;** Nasals *************************
$~::
$=::InCase(Replace("\x{303}(\p{M}*)") with("$1"))
		or InCase(After("[aəeɛiɨɪoɔuʊAƏEƐIƗOƆUƱ]\p{M}*") thenSend(Chr(0x303)))
		or Beep()

;** Original Quotation functionality ******************
; The problem with this is that the text is left with spaces between single and double quotes,
; which can result in wrapped text orphaning the outer quote mark. Isolated quote marks are bad practice.
; If a particular font does not show sufficient space between single and double quotes, a thin space
; can be inserted automatically during the typesetting process.
;~ $<::(not UseSmartQuotes and SendText("<"))
	;~ or InCase(After("“ ‘") thenSend(" “"))
	;~ or InCase(Replace("‘") with("“"))
	;~ or InCase(After("“") thenSend(" ‘") elseSend("‘"))

;~ $>::(not UseSmartQuotes and SendText(">"))
	;~ or InCase(After("” ’") thenSend(" ”"))
	;~ or InCase(Replace("’") with("”"))
	;~ or InCase(After("’ ”") thenSend(" ’"))
	;~ or InCase(Replace("”") with("’ ”") elseSend("’"))

;** Improved quotation functionality.
; Type a space where necessary to disambiguate break between single and double quotes, but no space is left in text.
$<::(not UseSmartQuotes and SendText("<"))
	or InCase(After("‘") Replace(" ") with("‘"))
	or InCase(Replace("‘") with("“") elseSend("‘"))

$>::(not UseSmartQuotes and SendText(">"))
	or InCase(After("’") Replace(" ") with("’"))
	or InCase(Replace("’") with("”") elseSend("’"))


;** Special Keys *******************
$!;::SendText(";")     ; send ;
$!`::SendChar(96)     ; send `
$!=::SendText("=")   ; send =
$!+~::SendText("~")   ; send ~
$!+<::SendText("<")    ; send <
$!+>::SendText(">")    ; send >
$!,::SendText("<")    ; send <
$!.::SendText(">")    ; send >
