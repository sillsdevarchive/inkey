/*
   Simplified Roman Transliteration Keyboard for InKey
   Originally written for Keyman by David Phillips
   Converted for InKey by Jim Kornelsen Dec 2009

  This keyboard program uses a simplified set of keys
  for typing Roman accents diacritics

NAME "Indic Roman Transliteration"
BITMAP "Romantranslit.bmp"
*/

; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.092
	  ; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	  ; It can be found near the top of the InKeyLib.ahki file.
	  ; It may be lower than the InKey version number.
	  ; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	  ; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 1  ; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki
;_______________________________________________________________________________

OnLoadScript:	; InKeyLib will call this subroutine just once, when the script is first loaded, for any script initialization.
;		Perform any script-wide initialization here, such as calls to RegisterRota().

; Key: Single Quote ( ' )	- non-looping rota for acute vowels
rota =
( C
	\	'	;] ↚	 005C |  0027	 reverse_solidus |  apostrophe
	a	á	;] ↚	 0061 |  00E1	 latin_small_letter_a |  latin_small_letter_a_with_acute
	e	é	;] ↚	 0065 |  00E9	 latin_small_letter_e |  latin_small_letter_e_with_acute
	i	í	;] ↚	 0069 |  00ED	 latin_small_letter_i |  latin_small_letter_i_with_acute
	o	ó	;] ↚	 006F |  00F3	 latin_small_letter_o |  latin_small_letter_o_with_acute
	u	ú	;] ↚	 0075 |  00FA	 latin_small_letter_u |  latin_small_letter_u_with_acute
	A	Á	;] ↚	 0041 |  00C1	 latin_capital_letter_a |  latin_capital_letter_a_with_acute
	E	É	;] ↚	 0045 |  00C9	 latin_capital_letter_e |  latin_capital_letter_e_with_acute
	I	Í	;] ↚	 0049 |  00CD	 latin_capital_letter_i |  latin_capital_letter_i_with_acute
	O	Ó	;] ↚	 004F |  00D3	 latin_capital_letter_o |  latin_capital_letter_o_with_acute
	U	Ú	;] ↚	 0055 |  00DA	 latin_capital_letter_u |  latin_capital_letter_u_with_acute
	s	ś	;] ↚	 0073 |  015B	 latin_small_letter_s |  latin_small_letter_s_with_acute
)
RegisterRota(0, rota, 0x27, 0, 0x27)	;|	apostrophe (')  apostrophe (')

; Key: Backtick ( ` )	- non-looping rota for grave vowels
rota =
( C
	\	``	;] ↚	 005C |  0060 0060	 reverse_solidus |  grave_accent grave_accent
	a	à
	;] ↚	 0061 |  00E0	 latin_small_letter_a |  latin_small_letter_a_with_grave
	e	è	;] ↚	 0065 |  00E8	 latin_small_letter_e |  latin_small_letter_e_with_grave
	i	ì	;] ↚	 0069 |  00EC	 latin_small_letter_i |  latin_small_letter_i_with_grave
	o	ò	;] ↚	 006F |  00F2	 latin_small_letter_o |  latin_small_letter_o_with_grave
	u	ù	;] ↚	 0075 |  00F9	 latin_small_letter_u |  latin_small_letter_u_with_grave
	A	À	;] ↚	 0041 |  00C0	 latin_capital_letter_a |  latin_capital_letter_a_with_grave
	E	È	;] ↚	 0045 |  00C8	 latin_capital_letter_e |  latin_capital_letter_e_with_grave
	I	Ì	;] ↚	 0049 |  00CC	 latin_capital_letter_i |  latin_capital_letter_i_with_grave
	O	Ò	;] ↚	 004F |  00D2	 latin_capital_letter_o |  latin_capital_letter_o_with_grave
	U	Ù	;] ↚	 0055 |  00D9	 latin_capital_letter_u |  latin_capital_letter_u_with_grave
)
RegisterRota(1, rota)	;|
; RegisterRota(1, rota, 0x60, 0, 0x60)	;|	grave_accent (`)  grave_accent (`)

; Key: Circumflex ( ^ )	- non-looping rota for circumflex vowels
rota =
( C
	\	^	;] ↚	 005C |  005E	 reverse_solidus |  circumflex_accent
	a	â	;] ↚	 0061 |  00E2	 latin_small_letter_a |  latin_small_letter_a_with_circumflex
	e	ê	;] ↚	 0065 |  00EA	 latin_small_letter_e |  latin_small_letter_e_with_circumflex
	i	î	;] ↚	 0069 |  00EE	 latin_small_letter_i |  latin_small_letter_i_with_circumflex
	o	ô	;] ↚	 006F |  00F4	 latin_small_letter_o |  latin_small_letter_o_with_circumflex
	u	û	;] ↚	 0075 |  00FB	 latin_small_letter_u |  latin_small_letter_u_with_circumflex
	A	Â	;] ↚	 0041 |  00C2	 latin_capital_letter_a |  latin_capital_letter_a_with_circumflex
	E	Ê	;] ↚	 0045 |  00CA	 latin_capital_letter_e |  latin_capital_letter_e_with_circumflex
	I	Î	;] ↚	 0049 |  00CE	 latin_capital_letter_i |  latin_capital_letter_i_with_circumflex
	O	Ô	;] ↚	 004F |  00D4	 latin_capital_letter_o |  latin_capital_letter_o_with_circumflex
	U	Û	;] ↚	 0055 |  00DB	 latin_capital_letter_u |  latin_capital_letter_u_with_circumflex
)
RegisterRota(2, rota, 0x5E, 0, 0x5E)	;|	circumflex_accent (^)  circumflex_accent (^)

; Key: Tilde ( ~ )	- non-looping rota for nasalized vowels
rota =
( C
	\	~	;] ↚	 005C |  007E	 reverse_solidus |  tilde
	a	ã	;] ↚	 0061 |  00E3	 latin_small_letter_a |  latin_small_letter_a_with_tilde
	e	ẽ	;] ↚	 0065 |  1EBD	 latin_small_letter_e |  latin_small_letter_e_with_tilde
	i	ĩ	;] ↚	 0069 |  0129	 latin_small_letter_i |  latin_small_letter_i_with_tilde
	o	õ	;] ↚	 006F |  00F5	 latin_small_letter_o |  latin_small_letter_o_with_tilde
	u	ũ	;] ↚	 0075 |  0169	 latin_small_letter_u |  latin_small_letter_u_with_tilde
	A	Ã	;] ↚	 0041 |  00C3	 latin_capital_letter_a |  latin_capital_letter_a_with_tilde
	E	Ẽ	;] ↚	 0045 |  1EBC	 latin_capital_letter_e |  latin_capital_letter_e_with_tilde
	I	Ĩ	;] ↚	 0049 |  0128	 latin_capital_letter_i |  latin_capital_letter_i_with_tilde
	O	Õ	;] ↚	 004F |  00D5	 latin_capital_letter_o |  latin_capital_letter_o_with_tilde
	U	Ũ	;] ↚	 0055 |  0168	 latin_capital_letter_u |  latin_capital_letter_u_with_tilde
	s	š	;] ↚	 0073 |  0161	 latin_small_letter_s |  latin_small_letter_s_with_caron
	n	ñ	;] ↚	 006E |  00F1	 latin_small_letter_n |  latin_small_letter_n_with_tilde
)
RegisterRota(3, rota, 0x7E, 0, 0x7E)	;|	tilde (~)  tilde (~)

; Key: Double quote ( " )	- non-looping rota for dieresis vowels
rota =
( C
	\	"	;] ↚	 005C |  0022	 reverse_solidus |  quotation_mark
	a	ä	;] ↚	 0061 |  00E4	 latin_small_letter_a |  latin_small_letter_a_with_diaeresis
	e	ë	;] ↚	 0065 |  00EB	 latin_small_letter_e |  latin_small_letter_e_with_diaeresis
	i	ï	;] ↚	 0069 |  00EF	 latin_small_letter_i |  latin_small_letter_i_with_diaeresis
	o	ö	;] ↚	 006F |  00F6	 latin_small_letter_o |  latin_small_letter_o_with_diaeresis
	u	ü	;] ↚	 0075 |  00FC	 latin_small_letter_u |  latin_small_letter_u_with_diaeresis
	A	Ä	;] ↚	 0041 |  00C4	 latin_capital_letter_a |  latin_capital_letter_a_with_diaeresis
	E	Ë	;] ↚	 0045 |  00CB	 latin_capital_letter_e |  latin_capital_letter_e_with_diaeresis
	I	Ï	;] ↚	 0049 |  00CF	 latin_capital_letter_i |  latin_capital_letter_i_with_diaeresis
	O	Ö	;] ↚	 004F |  00D6	 latin_capital_letter_o |  latin_capital_letter_o_with_diaeresis
	U	Ü	;] ↚	 0055 |  00DC	 latin_capital_letter_u |  latin_capital_letter_u_with_diaeresis
)
RegisterRota(4, rota, 0x22, 0, 0x22)	;|	quotation_mark (")  quotation_mark (")
;|	)  quotation_mark (		 0029 |  |  0071 0075 006F 0074 0061 0074 0069 006F 006E 005F 006D 0061 0072 006B |  0028		 right_parenthesis |  |  latin_small_letter_q latin_small_letter_u latin_small_letter_o latin_small_letter_t latin_small_letter_a latin_small_letter_t latin_small_letter_i latin_small_letter_o latin_small_letter_n low_line latin_small_letter_m latin_small_letter_a latin_small_letter_r latin_small_letter_k |  left_parenthesis

; Key: Dash ( - )	- non-looping rota for long vowels
rota =
( C
	\	-	;] ↚	 005C |  002D	 reverse_solidus |  hyphen-minus
	a	ā	;] ↚	 0061 |  0101	 latin_small_letter_a |  latin_small_letter_a_with_macron
	e	ē	;] ↚	 0065 |  0113	 latin_small_letter_e |  latin_small_letter_e_with_macron
	i	ī	;] ↚	 0069 |  012B	 latin_small_letter_i |  latin_small_letter_i_with_macron
	o	ō	;] ↚	 006F |  014D	 latin_small_letter_o |  latin_small_letter_o_with_macron
	u	ū	;] ↚	 0075 |  016B	 latin_small_letter_u |  latin_small_letter_u_with_macron
	A	Ā	;] ↚	 0041 |  0100	 latin_capital_letter_a |  latin_capital_letter_a_with_macron
	E	Ē	;] ↚	 0045 |  0112	 latin_capital_letter_e |  latin_capital_letter_e_with_macron
	I	Ī	;] ↚	 0049 |  012A	 latin_capital_letter_i |  latin_capital_letter_i_with_macron
	O	Ō	;] ↚	 004F |  014C	 latin_capital_letter_o |  latin_capital_letter_o_with_macron
	U	Ū	;] ↚	 0055 |  016A	 latin_capital_letter_u |  latin_capital_letter_u_with_macron
	s	ş	;] ↚	 0073 |  015F	 latin_small_letter_s |  latin_small_letter_s_with_cedilla
	n	ṉ	;] ↚	 006E |  1E49	 latin_small_letter_n |  latin_small_letter_n_with_line_below
	t	ṯ	;] ↚	 0074 |  1E6F	 latin_small_letter_t |  latin_small_letter_t_with_line_below
)
RegisterRota(5, rota, 0x22, 0, 0x22)	;|	quotation_mark (")  quotation_mark (")
;|	)  quotation_mark (		 0029 |  |  0071 0075 006F 0074 0061 0074 0069 006F 006E 005F 006D 0061 0072 006B |  0028		 right_parenthesis |  |  latin_small_letter_q latin_small_letter_u latin_small_letter_o latin_small_letter_t latin_small_letter_a latin_small_letter_t latin_small_letter_i latin_small_letter_o latin_small_letter_n low_line latin_small_letter_m latin_small_letter_a latin_small_letter_r latin_small_letter_k |  left_parenthesis

; Key: Period ( . )	- non-looping rota for underdot consonants
rota =
( C
	\	.	;] ↚	 005C |  002E	 reverse_solidus |  full_stop
	t	ṭ	;] ↚	 0074 |  1E6D	 latin_small_letter_t |  latin_small_letter_t_with_dot_below
	d	ḍ	;] ↚	 0064 |  1E0D	 latin_small_letter_d |  latin_small_letter_d_with_dot_below
	n	ṇ	;] ↚	 006E |  1E47	 latin_small_letter_n |  latin_small_letter_n_with_dot_below
	r	ṛ	;] ↚	 0072 |  1E5B	 latin_small_letter_r |  latin_small_letter_r_with_dot_below
	s	ṣ	;] ↚	 0073 |  1E63	 latin_small_letter_s |  latin_small_letter_s_with_dot_below
	m	ṃ	;] ↚	 006D |  1E43	 latin_small_letter_m |  latin_small_letter_m_with_dot_below
	h	ḥ	;] ↚	 0068 |  1E25	 latin_small_letter_h |  latin_small_letter_h_with_dot_below
	l	ḷ	;] ↚	 006C |  1E37	 latin_small_letter_l |  latin_small_letter_l_with_dot_below
)
RegisterRota(6, rota, 0x2E, 0, 0x2E)	;|	full_stop (.)  full_stop (.)

; Key: Greater than ( > )	- non-looping rota for underdot consonants
rota =
( C
	\	>	;] ↚	 005C |  003E	 reverse_solidus |  greater-than_sign
	n	ṅ	;] ↚	 006E |  1E45	 latin_small_letter_n |  latin_small_letter_n_with_dot_above
	m	ṁ	;] ↚	 006D |  1E41	 latin_small_letter_m |  latin_small_letter_m_with_dot_above
	y	ẏ	;] ↚	 0079 |  1E8F	 latin_small_letter_y |  latin_small_letter_y_with_dot_above
)
RegisterRota(7, rota, 0x3E, 0, 0x3E)	;|	greater-than_sign (>)  greater-than_sign (>)

 ; Key: Capital M ( M )	- non-looping rota for chandra bindu consonants
rota =
( C
	\	M	;] ↚	 005C |  004D	 reverse_solidus |  latin_capital_letter_m
	n	̐	;] ↚	 006E |  0310	 latin_small_letter_n |  combining_candrabindu
	m	̐	;] ↚	 006D |  0310	 latin_small_letter_m |  combining_candrabindu
)
RegisterRota(8, rota, 0x4D, 0x4D)	;|	latin_capital_letter_m (M)  latin_capital_letter_m (M)

 ; Key: Zero ( 0 )	- non-looping rota for undercircle consonants
rota =
( C
	\	0	;] ↚	 005C |  0030	 reverse_solidus |  digit_zero
	l	̥	;] ↚	 006C |  0325	 latin_small_letter_l |  combining_ring_below
	r	̥	;] ↚	 0072 |  0325	 latin_small_letter_r |  combining_ring_below
)
RegisterRota(9, rota, 0x30, 0x30)	;|	digit_zero (0)  digit_zero (0)

RegisterRota(10, "\ =	l ̄", 0x3D, 0, 0, 1)	;|	equals_sign (=)
;|	\ =		 005C |  003D		 reverse_solidus |  equals_sign
;|	l ◌̄		 006C |  0304		 latin_small_letter_l |  combining_macron
RegisterRota(11, "\ #	l ̃", 0x23, 0, 0, 1)	;|	number_sign (#)
;|	\ #		 005C |  0023		 reverse_solidus |  number_sign
;|	l ◌̃		 006C |  0303		 latin_small_letter_l |  combining_tilde
RegisterRota(12, "Y Z	C D", 0x21, 0, 0, 1)	;|	exclamation_mark (!)
;|	Y Z		 0059 |  005A		 latin_capital_letter_y |  latin_capital_letter_z
;|	C D		 0043 |  0044		 latin_capital_letter_c |  latin_capital_letter_d

Return
;*   END OnLoadScript Subroutine

$'::DoRota(0)
$`::DoRota(1)
$^::DoRota(2)
$~::DoRota(3)
$"::DoRota(4)	; " (shift + ')
$-::DoRota(5)
$.::DoRota(6)
$>::DoRota(7)
$+m::DoRota(8)	; M (shift + m)
$0::DoRota(9)
$=::DoRota(10)
$#::DoRota(11)
$!::DoRota(12)

return
