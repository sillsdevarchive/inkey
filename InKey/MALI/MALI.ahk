/*	InKey script to provide a keyboard layout for MALI modified from GENERIC.

	Keyboard:	MALI
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
; The above lines are needed to begin an InKey
;    or AHK = (Auto Hot Key) description file
; This file was created by Daniel Brubaker for InKey Feb 2014
; The accents follow the vowels and are combined if possible

; We want each assigned key to give its own symbol whenever typed after /, so 1st InCase(Map(/ *)) does this.

; In French we want the straight Apostrophy to become U+2019 (fancy single right quote) for spell checking, this is the 1st 5 "InCase" 's.
$'::
InCase(Map("/ '")) ; returns original character after /
InCase(After("qu") thenSend("qu’"))
 || InCase(After("Qu") thenSend("Qu’"))
 || InCase(After("rd") thenSend("rd’"))
 || InCase(After(" l") thenSend(" l’"))
 || InCase(After(" d") thenSend(" d’"))

; The comma "," normally always has a space after it AND it is easy to find and type on both French and QWERTY keyboards. It was therefore chosen to be the key that changes many things when something OTHER than a space follows it.
; These special characters are made first so that accents can go on them further down
$,::InCase(Map("/ ,", "' ʼ '",  "a ə æ",  "e ɛ",  "i ɩ ɨ",  "o ɔ œ",  "u ʋ ʌ",  "A Ə Æ Ǝ", "E Ɛ", "I Ɩ", "O Ɔ Œ", "U Ʋ",  "r «", "R »",  "s ‹ ʃ ’", "S ›",  "t ‘ ʧ", "T ’",  "p “", "P ”",  "f œ", "F €",  "k ©", "K …",  "l ʼ",  "L ☺",  "v †", "V ‡",  "h Ɂ", "H §",  "x ɡ", "X ɑ",  "z ʒ", "Z Ʒ",  "g ɣ °", "G Ɣ",  "b ɓ", "B Ɓ",  "d ɗ ʤ", "D Ɗ",  "y ƴ ∞", "Y Ƴ",  "c ç ✓", "C Ç",  "0 Ø",  "n ŋ", "N Ŋ",  "j ɲ", "J Ɲ",  "< ‹ « <", "> › » >"))
 || Send(",")  ; if a SPACE or anything else is typed after the comma


;~ InCase(Map("/ ,")) ; returns original character after /
;~ InCase(Map("' ʼ '", ; the straight apostrophy goes to U+02BC (modifier letter) for Africa, or if hit twice becomes straight again
		 ;~ "a ə æ",   ; a becomes schwa when typed once, and ae when typed twice
		 ;~ "e ɛ",     ; e becomes espilon or open e
		 ;~ "i ɩ ɨ",   ; i becomes iota or barred i when typed twice
		 ;~ "o ɔ œ",   ; o becomes open o or oe when typed twice
		 ;~ "u ʋ ʌ",   ; u becomes fancy u or upsidedown v when typed twice
		 ;~ "A Ə Æ Ǝ", "E Ɛ", "I Ɩ", "O Ɔ Œ", "U Ʋ", ; Same thing for CAPITAL letters
		 ;~ "r «", "R »",   ; gives the French double quotes left and right
		 ;~ "s ‹ ʃ ’", "S ›", ; gives the French single quotes left and right, plus the esh symbol when typed twice
		 ;~ "t ‘ ʧ", "T ’", ; gives the Am single fancy quotes left and right, plus the t esh symbol when typed twice
		 ;~ "p “", "P ”",   ; gives the Am double fancy quotes left and right
		 ;~ "f œ", "F €",   ; gives oe  OR the CAP F gives the Euro sign
		 ;~ "k ©", "K …",   ; gives the Copyright symbol, CAP 3 points (elipsis)
		 ;~ "l ʼ",          ; forces a U+02BC or combining apostrophy
		 ;~ "L ☺",          ; a smiley face, a needed symbol in all my keyboards!
		 ;~ "v †", "V ‡",   ; Cross and double cross used to mark Dictionary words in Paratext
		 ;~ "h Ɂ", "H §",   ; glottal and section sign (found on all French keyboards)
		 ;~ "x ɡ", "X ɑ",   ; literacy g and literacy a (both not fancy)
		 ;~ "z ʒ", "Z Ʒ",   ; ezh and Ezh, Songhai writes these with a caron over the z
		 ;~ "g ɣ °", "G Ɣ", ; gamma and Gamma, needed for Tamacheq
		 ;~ "b ɓ", "B Ɓ",   ; implosive b's needed for Fufulde
		 ;~ "d ɗ ʤ", "D Ɗ", ; implosive d's needed for Fufulde, plus d ezh
		 ;~ "y ƴ ∞", "Y Ƴ", ; implosive y's needed for Fufulde, plus infinity
		 ;~ "c ç ✓", "C Ç", ; c cidilla's needed in French, plus Check mark
		 ;~ "0 Ø",          ; Null sign or empty set needed in FieldWorks
		 ;~ "n ŋ", "N Ŋ",   ; eng and Eng
		 ;~ "j ɲ", "J Ɲ",   ; enya and Enya
		 ;~ "< ‹ « <", "> › » >")) ; another intuitive way to type the French quotes, single (once) and double (twice), or wedges (3 times)
  ;~ || Send(",")  ; if a SPACE or anything else is typed after the comma

; Combining tilda is searched for and made first. This lets the combined letter be found that can then take another accent on top of it.
$=::
InCase(Map("/ =")) ; returns original character after /
InCase(Replace("$F([aeiounAEIOUN])") with("$R") usingMap("a ã", "e ẽ", "i ĩ", "o õ", "u ũ", "n ñ", "A Ã", "E Ẽ", "I Ĩ", "O Õ", "U Ũ" "N Ñ")) ; this puts the combined tilda over what it can go over as one character
 || InCase(After("[əæɛɩɨɔœʋʌɲŋƏƎÆƐƖƆŒƲƝŊ]") thenSend(Char(0x303))) ; Adds decomposed tilda U+0303
 || Send("=")  ; simplest return to normal

; Acute accent (High tone) over all vowels, including the composed nasal vowels, and including over decomposed nasal vowels
$4::
InCase(Map("/ 4")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a á", "e é", "i í", "o ó", "u ú", "n ń", "m ḿ", "A Á", "E É", "I Í", "O Ó", "U Ú" "N Ń", "M Ḿ")) ; adds combining acute
 || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x301))) ; adds decomposed acute
  || InCase(After(Char(0x303)) thenSend(Char(0x301))) ; adds decomposed acute over decomposed tilda
  || Send("4") ; simplest return to normal

; Grave accent (Low tone) over all vowels, including the composed nasal vowels, and including over decomposed nasal vowels
$7::
InCase(Map("/ 7")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a à", "e è", "i ì", "o ò", "u ù", "A À", "E È", "I Ì", "O Ò", "U Ù")) ; adds combining grave accent
 || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x300))) ; adds decomposed grave
  || InCase(After(Char(0x303)) thenSend(Char(0x300))) ; adds decomposed grave over decomposed tilda
  || Send("7") ; simplest return to normal

; Circumflex accent ^ (High Low tone) over all vowels, including the composed nasal vowels, and including over decomposed nasal vowels
$9::
InCase(Map("/ 9")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a â", "e ê", "i î", "o ô", "u û", "A Â", "E Ê", "I Î", "O Ô", "U Û")) ; adds combining circumflex accent
 || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x302))) ; adds decomposed circumflex
  || InCase(After(Char(0x303)) thenSend(Char(0x302))) ; adds decomposed circumflex over decomposed tilda
  || Send("9") ; simplest return to normal

; Caron accent that looks like a raised v
$+::
InCase(Map("/ +")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a ǎ", "e ě", "i ǐ", "o ǒ", "u ǔ", "n ň", "s š", "z ž", "A Ǎ", "E Ě", "I Ǐ", "O Ǒ", "U Ǔ" "N Ň", "S Š", "Z Ž")) ; adds combining caron accent even over s, z, and n
  || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x30C))) ; adds decomposed caron
  || InCase(After(Char(0x303)) thenSend(Char(0x30C))) ; adds decomposed caron over decomposed tilda
  || Send("+") ; simplest return to normal

; Macron accent = Mid tone ā
$5::
InCase(Map("/ 5")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a ā", "e ē", "i ī", "o ō", "u ū", "A Ā", "E Ē", "I Ī", "O Ō", "U Ū")) ; adds combining macron accent
  || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x304))) ; adds decomposed macron
  || InCase(After(Char(0x303)) thenSend(Char(0x304))) ; adds decomposed macron over decomposed tilda
  || Send("5") ; simplest return to normal

; Combining Diaeresis or 2 dots over ä
$%::
InCase(Map("/ %")) ; returns original character after /
InCase(Replace("$F([aeiounmAEIOUNM])") with("$R") usingMap("a ä", "e ë", "i ï", "o ö", "u ü", "A Ä", "E Ë", "I Ï", "O Ö", "U Ü")) ; adds combining diaeresis accent
  || InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲ]") thenSend(Char(0x308))) ; adds decomposed diaeresis, but never goes over decomposed tilda
  || Send("%") ; simplest return to normal

; Combining vertical line below
$&::
InCase(Map("/ &")) ; returns original character after /
InCase(After("[ãẽĩõũñəæɛɩɨɔœʋʌÃẼĨÕŨÑƏƎÆƐƖƆŒƲdghstwxz]") thenSend(Char(0x329))) ; includes some Arab consonnants
  || InCase(After(Char(0x303)) thenSend(Char(0x329))) ; adds decomposed vertical line below under decomposed tilda
  || Send("&") ; simplest return to normal
; this is needed for 2 characters in Minyanka

; Need three more house keeping things before we are done
; qh => Non-Breaking Hyphen, qs => No-Break Space, qm => Em Dash
; also need combined breve over a and A for Tamacheq
$q::
InCase(Map("/ q")) ; returns original character after /
InCase(Replace("h") with(Char(0x2011))) ; Non-breaking Hyphen
 || InCase(Replace("s") with(Char(0xA0))) ; No-Break Space
 || InCase(Replace("m") with(Char(0x2014))) ; Em Dash
 || InCase(Replace("a") with(Char(0x103))) ; a with breve
 || InCase(Replace("A") with(Char(0x102))) ; CAP A with breve

; Extras for Dan only - Email addresses I often use
$p::InCase(After("0") thenSend("dnbrubaker@yahoo.com"))
	|| Send("p")
$g::InCase(After("0") thenSend("gretadao@yahoo.com"))
	|| Send("g")
$h::InCase(After("0") thenSend("happyhannah50@aol.com"))
	|| Send("h")

; End of keyboard
