/*InKey Script to provide a context-sensitive keyboard layout for IPA

	Keyboard:	IPA Unicode
	Version:	2.0
	Authors:	Benjamin of NLCI, and Dan of SAG.
	Official Distributionː	http://inkeysoftware.com

	You are free to modify this script for your own purposes.
	Please retain the above authorship details as appropriate.

HISTORY:
2008-08-13  0.1  Created by NLCI and SAG, to mimic SIL's IPAUni12.KMN layout
2008-09-01  1.0  Shortcuts for ligatures added
2008-10-14  1.01 Comments in continuation sections adjusted to avoid AHK's bug.
2008-10-28  1.02 K_MinimumInKeyLibVersion specified
2008-11-19  1.03 Make use of default hotkeys (requires InKeyLib 0.092)
2009-03-01  1.04 The ampersand (&) key now joins/splits these chars when typed after them: 	ʣ ʤ ʥ ʦ ʧ ʨ ʩ ʪ ʫ ɮ
2009-11-10  1.05 This keyboard now outputs only NFD forms, in order to keep FieldWorks apps from misbehaving.
2011-04-07  1.06 Updated to use CAPSLOCK-sensitive context
2013-02-13  2.00 Updated to use InKey 0.900 API. (More readable)
								Also, combining diacritic keys now only apply after \p{L}\p{M}*, so you get the key's actual character more
								naturally in other contexts.

*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.900
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
Return

;----------------------------------------------------------------------------------------------
; IPA Function Keys:

;----------------------------------------------------------------------------------------------
; The digits have the most complex usage pattern, used for level contours, stem tones, rotas, and the digits themselves.

$0::InCase(After("[\x{2E5}-\x{2E9}]") thenSend(Char(0x2E9)))		       ; Continue a left stem contour
		or  InCase(After("[\x{A712}-\x{A716}]") thenSend(Char(0xA712)))		; Continue a right stem contour
		or  InCase(Map("#→˩", "&→꜒", "̊→̏"))			            ;    # → 2E9,   & → A712, 30A → 30F
		or  Send("0")

$1::InCase(Replace("##") with(Char(0xF1F1)))  				                    ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F1)))		; Continue a level pitch contour
		or  InCase(After("[\x{2E5}-\x{2E9}]") thenSend(Char(0x2E8)))		; Continue a left stem contour
		or  InCase(After("[\x{A712}-\x{A716}]") thenSend(Char(0xA713)))		; Continue a right stem contour
		or  InCase(Map("#→˨", "&→꜓", "̊→̀", "̌→᷈", "̄→᷆", "́→̂"))    ;  #→2E8, &→A713, 030A→0300, 030C→1DC8, 0304→1DC6, 0301→0302
		or  Send("1")

$2::InCase(Replace("##") with(Char(0xF1F2)))                                 ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F2)))		; Continue a level pitch contour
		or  InCase(After("[\x{2E5}-\x{2E9}]") thenSend(Char(0x2E7)))		; Continue a left stem contour
		or  InCase(After("[\x{A712}-\x{A716}]") thenSend(Char(0xA714)))		; Continue a right stem contour
		or  InCase(Map("#→˧", "&→꜔", "̊→̄", "̀→᷅", "́→᷇"))   ; #→02E7,  &→A714,  030A→0304,  0300→1DC5,  0301→1DC7
		or  Send("2")

$3::InCase(Replace("##") with(Char(0xF1F3)))                                    ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F3)))		; Continue a level pitch contour
		or InCase(After("[\x{2E5}-\x{2E9}]") thenSend(Char(0x2E6)))		; Continue a left stem contour
		or InCase(After("[\x{A712}-\x{A716}]") thenSend(Char(0xA715)))		; Continue a right stem contour
		or InCase(Map("#→˦", "&→꜕", "̊→́", "̀→̌", "̄→᷄", "̂→᷉"))  ;  #→02E6, &→A715, 030A→0301, 0300→030C, 0304→1DC4, 0302→1DC9
		or Send("3")

$4::InCase(Replace("##") with(Char(0xF1F4)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F4)))		; Continue a level pitch contour
		or  InCase(After("[\x{2E5}-\x{2E9}]") thenSend(Char(0x2E5)))		; Continue a left stem contour
		or  InCase(After("[\x{A712}-\x{A716}]") thenSend(Char(0xA716)))		; Continue a right stem contour
		or  InCase(Map("#→˥", "&→꜖", "̊→̋"))		                     ;  #→02E5,, &→A716, 030A→030B
		or Send("4")

$5::InCase(Replace("##") with(Char(0xF1F5)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F5)))		; Continue a level pitch contour
		or Send("5")

$6::InCase(Replace("##") with(Char(0xF1F6)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F6)))		; Continue a level pitch contour
		or Send("6")

$7::InCase(Replace("##") with(Char(0xF1F7)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F7)))		; Continue a level pitch contour
		or Send("7")

$8::InCase(Replace("##") with(Char(0xF1F8)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F8)))		; Continue a level pitch contour
		or Send("8")

$9::InCase(Replace("##") with(Char(0xF1F9)))                                  ; Begin a level pitch contour after ##
		or InCase(After("[\x{F1F1}-\x{F1F9}]") thenSend(Char(0xF1F9)))		; Continue a level pitch contour
		or Send("9")


;----------------------------------------------------------------------------------------------
; The non-digits are more straightforward:

; Key: Equals (=)   -This rota is the all-purpose "can't-remember-the-keystroke" rota.
; The first alternate mimics the behavior of IPAUni12.kmn, but otherwise we are free to order alternates as seems best.
$=::InCase(Map("\→=", "̟→+↺", "̪→{↺", "ˈ→}↺", "̠→_↺", "ː→:↺", "̃→~↺", "̈→*↺", "̊→@↺", "̥→%↺", "̩→$↺", "#→‿↺", ".→‖↺", "ǃ→ǂ→!↺", "?→ʔ→ʕ→ʡ→ʢ↺", "a→ɑ→ɐ→æ→ᴂ→α→ᶏ→ᶐ→ᴀ↺", "ae→æ→ᴂ→aə", "A→ᴂ", "b→β→ɓ→ᶀ→ᵬ↺", "B→ʙ↺", "c→ç→ƈ→ɕ↺", "d→ð→ɗ→ɖ→ȡ→ᶑ→ᶁ→ᵭ↺", "OE→ɶ", "E→ɘ→ɶ→œ→ᴇ↺", "oe→œ→oə", "e→ə→ɜ→ɛ→ʚ→œ→ᶒ→ᶓ→ᶔ→ᶕ→ɘ↺", "f→ɸ→ᶂ→ᵮ↺", "g→ɣ→ɡ→ɠ→ᶃ↺", "G→ɢ→ʛ↺", "h→ɥ→ħ→ɦ→ђ→ɧ↺", "H→ʜ↺", "i→ɪ→ɩ→ɨ→ᵼ→ᵻ→ᶖ↺", "I→ɨ↺", "j→ɟ→ʄ→ʝ↺", "k→ƙ→ᶄ↺", "l→ɬ→ɮ→ɭ→ȴ→ɺ→ʎ→ᶅ→ɫ↺", "L→ʟ→ɺ↺", "m→ɱ→ᶆ→ᵯ↺", "n→ɲ→ŋ→ɳ→ȵ→ᶇ→ᵰ→Ŋ↺", "N→ɴ→Ŋ↺", "O→ɵ→ɤ→ɞ↺", "o→ɒ→ø→ɔ→ᶗ↺", "p→ʘ→ƥ→ᶈ→ᵱ↺", "q→ʠ↺", "Q→ʡ→ʢ↺", "R→ʀ→ʁ↺", "r→ɹ→ɾ→ɽ→ɻ→ᶉ→ᵲ→ᵳ↺", "s→ʃ→σ→ʂ→ᶊ→ᵴ→ᶘ→ᶋ↺", "S→ᶘ↺", "t→θ→ʇ→ƭ→ʈ→ȶ→ᵵ↺", "T→ʇ↺", "u→ɯ→ʉ→ᵾ→ʌ→ʊ→ɷ→ʉ→ᵾ→ᶙ↺", "U→ʉ↺", "v→ʋ→ⱱ→ᶌ↺", "w→ʍ→ɰ→ⱳ↺", "x→χ→ᶍ↺", "y→ʏ→ɥ→ʯ↺", "Y→ʯ↺", "lz→ɮ→lʒ", "z→ʒ→ᶚ→ʑ→ʐ→ᶎ→ᵶ→ɿ→ʅ↺", "Z→ᶚ↺"))
	or Send("=")

; right wedge ( > ) - A general set of alternate forms
$>::InCase(Map("\→>", "#→ꜛ→↗↺", "ǃ→ǁ↺", "=→\x{2192}", "A→ᴂ↺", "a→ɐ↺", "b→ɓ↺", "c→ƈ↺", "d→ɗ↺", "E→ɶ↺", "e→ɜ↺", "G→ʛ↺", "g→ɠ↺", "H→ɧ↺", "h→ħ↺", "I→ᵼ↺", "j→ʄ↺", "k→ƙ↺", "L→ɺ↺", "l→ɮ↺", "m→ɱ↺", "n→ŋ↺", "N→Ŋ↺", "O→ɤ↺", "o→ø↺", "p→ƥ↺", "q→ʠ↺", "R→ʁ↺", "r→ɾ↺", "s→σ↺", "t→ƭ↺", "u→ʌ↺", "U→ᵾ↺", "w→ɰ↺", "z→ʑ↺"))
	or Send(">")

; left wedge ( < )  - A general set of alternate forms
$<::InCase(Map("\→<", "#→ꜜ→↘↺", ".→|↺", "?→ʕ↺", "ǃ→ǀ↺", "=→\x{34F}↺", "a→æ↺", "c→ɕ↺", "d→ɖ↺", "e→ɛ↺", "E→œ↺", "g→ɡ↺", "h→ɦ↺", "I→ᵻ↺", "j→ʝ↺", "l→ɭ↺", "L→ʎ↺", "n→ɳ↺", "o→ɔ↺", "O→ɞ↺", "Q→ʢ↺", "r→ɽ↺", "R→ɻ↺", "s→ʂ↺", "t→ʈ↺", "u→ʊ↺", "v→ⱱ↺", "w→ⱳ↺", "y→ɥ↺", "z→ʐ↺"))  ;     = → 034F (combining grapheme joiner)
	or Send("<")

; vertical bar ( | ) - - A general set of alternate forms
$|::InCase(Map("\→|", "A→ᴀ↺", "a→α↺", "d→ȡ↺", "E→ᴇ↺", "e→ʚ↺", "h→ђ↺", "i→ɩ↺", "l→ȴ↺", "n→ȵ↺", "T→ʇ↺", "t→ȶ↺", "u→ɷ↺", "Y→ʯ↺", "y→ʮ↺", "Z→ʅ↺", "z→ɿ↺"))
	or Send("|")

; Key: Circumflex ( ^ )  - For superscripting
$^::InCase(Map("\→^", "0→⁰↺", "1→¹↺", "2→²↺", "3→³↺", "4→⁴↺", "5→⁵↺", "6→⁶↺", "7→⁷↺", "8→⁸↺", "9→⁹↺", "-→⁻↺", "+→⁺↺", "=→⁼↺", "ʕ→ˤ↺", "ʔ→ˀ↺", "b→ᵇ↺", "β→ᵝ↺", "c→ᶜ↺", "ɕ→ᶝ↺", "d→ᵈ↺", "ð→ᶞ↺", "f→ᶠ↺", "g→ᵍ↺", "ɡ→ᶢ↺", "ɣ→ˠ↺", "h→ʰ↺", "ɦ→ʱ↺", "ɥ→ᶣ↺", "ħ→↺", "j→ʲ↺", "ʝ→ᶨ↺", "ɟ→ᶡ↺", "k→ᵏ↺", "l→ˡ↺", "ɭ→ᶩ↺", "ʟ→ᶫ↺", "m→ᵐ↺", "ɱ→ᶬ↺", "n→ⁿ↺", "ɲ→ᶮ↺", "ŋ→ᵑ↺", "ɳ→ᶯ↺", "ɴ→ᶰ↺", "p→ᵖ↺", "ɸ→ᶲ↺", "r→ʳ↺", "ɹ→ʴ↺", "ɻ→ʵ↺", "ʁ→ʶ↺", "s→ˢ↺", "ʂ→ᶳ↺", "ʃ→ᶴ↺", "t→ᵗ↺", "ɰ→ᶭ↺", "v→ᵛ↺", "ʋ→ᶹ↺", "w→ʷ↺", "x→ˣ↺", "z→ᶻ↺", "ʑ→ᶽ↺", "ʐ→ᶼ↺", "ʒ→ᶾ↺", "θ→ᶿ↺", "ʎ→↺", "a→ᵃ↺", "ɐ→ᵄ↺", "ɑ→ᵅ↺", "ɒ→ᶛ↺", "æ→↺", "ᴂ→ᵆ↺", "e→ᵉ↺", "ə→ᵊ↺", "ɛ→ᵋ↺", "ɜ→ᶟ↺", "ɘ→↺", "i→ⁱ↺", "ɨ→ᶤ↺", "ɪ→ᶦ↺", "o→ᵒ↺", "ø→↺", "œ→↺", "ɶ→↺", "ɵ→ᶱ↺", "ɔ→ᵓ↺", "u→ᵘ↺", "ʉ→ᶶ↺", "y→ʸ↺", "ʏ→↺", "ɯ→ᵚ↺", "ɤ→↺", "ɞ→↺", "ʌ→ᶺ↺", "ʊ→ᶷ↺", "(→⁽↺", ")→⁾↺"))
	or Send("^")

; Key: Tilde ( ~ )
; this is a non-looping rota, to match IPAUni12.kmn functionality (probably unneccesarily closely)
$~::InCase(Map("\→~", "b̃→ᵬ", "d̃→ᵭ", "f̃→ᵮ", "l̃→ɫ", "m̃→ᵯ", "ñ→ᵰ", "p̃→ᵱ", "r̃→ᵲ", "ɾ̃→ᵳ", "s̃→ᵴ", "t̃→ᵵ", "z̃→ᵶ"))
	or Send(Char(0x303))

; Key: Ampersand ( & )  - For tying ties or for combining/splitting affricates.
$&::InCase(Map("\→&", "#→͡", "̊→͜", "dz→ʣ", "dʒ→ʤ", "dʑ→ʥ", "ts→ʦ", "tʃ→ʧ", "tɕ→ʨ", "fŋ→ʩ", "ls→ʪ", "lz→ʫ", "lʒ→ɮ"))
	or Send("&")

; Key: left curly bracket ( { ) - For Dental/Apical/Laminal/Lingulabial/Fricative
${::InCase(Map("\x{32A}→\x{33A}→\x{33B}→\x{33C}→\x{323}", "\→{"))		; combining_bridge_below |  combining_inverted_bridge_below |  combining_square_below |  combining_seagull_below |  combining_dot_below
	or InCase(After("\p{L}\p{M}*") thenSend(Char(0x32A)))
	or Send("{")

; Key: Right Curly bracket ( } ) - For stress / fortis-lenis.  May be word initial; Not a diacritic.
$}::InCase(Map("→\x{02C8}→\x{02CC}→\x{0348}→\x{1DC2}→}", "\→}"))

; Key: right_square_bracket	( ] ) - By default puts own key out first.  Non-looping.
$]::InCase(Map("→]→ʼ→̚→ʻ"))	; 005D |  02BC |  031A |  02BB		 right_square_bracket |  modifier_letter_apostrophe |  combining_left_angle_above |  modifier_letter_turned_comma

; Key: left square_bracket	( [ ) - By default puts own key out first. Non-looping.
$[::InCase(Map("→[→ʽ→˞"))		; 005B |  02BD |  02DE		 left_square_bracket |  modifier_letter_reversed_comma |  modifier_letter_rhotic_hook

; Key: asterisk ( * )
$*::InCase(Map("\→*", "\x{308}→\x{33d}→\x{306}→\x{307}→\x{310}"))		; combining_diaeresis |  combining_x_above |  combining_breve |  combining_dot_above |  combining_candrabindu
		or InCase(After("\p{L}\p{M}*") thenSend(Char(0x308)) elseSend("*"))

; plus sign ( + )   advanced / raised / +ATR / more rounded
$+::InCase(Map("\→+", "\x{31F}→\x{31D}→\x{318}→\x{339}"))		;  ◌̟ ◌̝ ◌̘ ◌̹		combining_plus_sign_below |  combining_up_tack_below |  combining_left_tack_below |  combining_right_half_ring_below
		or InCase(After("\p{L}\p{M}*") thenSend(Char(0x31F)) elseSend("+"))

; underscore ( _ )	  ; retracted / lowered / -ATR / less rounded / open vowel
$_::InCase(Map("\→_", "\x{320}→\x{31E}→\x{319}→\x{31C}→\x{327}"))		;|	◌̠ ◌̞ ◌̙ ◌̜ ◌̧		 combining_minus_sign_below |  combining_down_tack_below |  combining_right_tack_below |  combining_left_half_ring_below |  combining_cedilla
		or InCase(After("\p{L}\p{M}*") thenSend(Char(0x320)) elseSend("_"))

; percent (%) for below diacritics and palatal hooks
$%::InCase(Map("b̤→ᶀ", "d̤→ᶁ", "f̤→ᶂ", "g̤→ᶃ", "k̤→ᶄ", "l̤→ᶅ", "m̤→ᶆ", "n̤→ᶇ", "p̤→ᶈ", "r̤→ᶉ", "s̤→ᶊ", "ʃ̤→ᶋ", "v̤→ᶌ", "x̤→ᶍ", "z̤→ᶎ"))  ; dieresis to palatal hooks	(This is a non-looping rota.)
		or InCase(Map("\ %", "\x{325}→\x{32C}→\x{324}" ))		; ◌̥ ◌̬ ◌̤		 combining_ring_below |  combining_caron_below |  combining_diaeresis_below
		or InCase(After("\p{L}\p{M}*") thenSend(Char(0x325)) elseSend("%"))

; Key: dollar sign ( $ )   ; syllabic / non-syllabic / creaky-voiced / retroflex hook
$$::InCase(Map("a̰→ᶏ", "ɑ̰→ᶐ", "ɗ̰→ᶑ", "ḛ→ᶒ", "ɛ̰→ᶓ", "ɜ̰→ᶔ", "ə̰→ᶕ", "ḭ→ᶖ", "ɔ̰→ᶗ", "ʃ̰→ᶘ", "ṵ→ᶙ", "ʒ̰→ᶚ"))  ; tilde below  --> retroflex hooks (This is a non-looping rota.)
		or InCase(Map("\ $", "\x{329}→\x{32F}→\x{330}" ))		;|	◌̩ ◌̯ ◌̰		 combining_vertical_line_below |  combining_inverted_breve_below |  combining_tilde_below
		or InCase(After("\p{L}\p{M}*") thenSend(Char(0x329)) elseSend("$"))

; Key: Colon ( : )
$+;::InCase(Map("ːː→ː→ˑ↺", "\→:") elseSend("ː"))	; modifier_letter_triangular_colon (x2) |  modifier_letter_triangular_colon |  modifier_letter_half_triangular_colon

; Key: exclamation point
$!::InCase(After("\") thenSend("!") elseSend(Char(0x1C3)))   	; latin_letter_retroflex_click (ǃ)

; Key: AT symbol ( @ )
$@::InCase(Map("→\x{30A}→@", "\→@"))   ; combining_ring_above (◌̊)

