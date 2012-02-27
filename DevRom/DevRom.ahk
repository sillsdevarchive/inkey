/* AutoHotKey Script to provide a keyboard layout that [rather slavishly]
	follows the layout (and quirks) of the DevRomU.KMN Keyman layout,
	with a few enhancements.

	This script is primarily for users who are already accustomed to the DevRom layout.
	(It does not take advantage of newer keying techniques made feasible by InKey.)

 PARAMETERS:  (User-selected options for a keyboard.)
   SwapSHA=1	Swap SHA (z) and SSA (S) keys from original DevRom layout
   ScriptDigit=1 	Use Devanagari digits rather than Western digits by default.
   SwapHalfH=1	Swap x and shift+x behavior after h, for languages that
			prefer ह्‌ to ह्‍
   UseLLA=1		For languages that don't need LLA (ळ), shift+L can give a
			shortcut for lo-R (e.g in क्र) otherwise obtained by typing  ; r
   smartQuotes=1	Use Smart (double) quotes by default.  (Press " again to toggle this.)
   ApostropheForTone=1	Use the apostrophe key (') for a tone mark (’)
   OnlyDeadKeyForVowels=1  Only generate Independent form of vowel after 'q' deadkey

Other differences from DevRomU.KMN:
- Typing the q key to obtain an independent vowel is now mostly optional, as the vowel will
  automatically be independent unless typed after a consonant or nukta (़).  In cases in which
  you need an independent vowel after a consonant (e.g. गए), type the q (e.g. gqe) , or use an
  InKey context-clearing key (such as Ins or End) instead of q.
- The state of the CapsLock key will toggle between script and roman digits.
- A digit will always follow the script of an immediately preceding digit.
(e.g Press Right-Alt to get the first digit, then no need to hold it after that.)
- Due to a tweak for Kangri, DevRom.KMN had no way to produce ह्‍ ( 93C, 200D),
   which other lgs. presumably need.  Here you can type the shift+x to get the opposite
   form.  (Default is specified with the SwapHalfH parameter.)
- Visarga (ः) can alternatively be obtained by typing :::
- Candra E and O can be obtained by typing candra (Ctrl+Alt+5) after
  E/Ekar and O/Okar (phonology-centric), in addition to after AA/Aakar (shape-centric).
- Given InKey's convenient language-switching shortcuts, DevRomU's use of
  shift+q to activate roman text is unneccesary, so not implemented here.
 -We even implemented DevRomU.KMN's "flying reph" behavior, fixing the bug that kept it from
  working on cases of nukta without vowel (e.g. र्ल़), and keeping it from spitting out latin R
  in cases where the context didn't match any of the options, instead preparing the reph to go on the
  next consonant to be typed.
 -For some reason, DevRomU.KMN intentially does not allow you to type an @.
  We have left this "feature" unimplemented.
  -You can type n;y to get NYA and g;y to get GYA.  (nxy/nY and gxy/gY will still get the "half-char-plus-YA" forms)
  -Any characters that previously required Ctrl+Alt key combinations can now be obtained by easier methods.

	Keyboard:		DevRom Unicode
	Version:			0.5
	Date Modified:		2008-11-18
	History:			Created by SAG

Note: Anything after a semi-colon is just a comment.
Comments in this file that identify the unicode characters were automatically generated.

HISTORY:
2008-11-19 DRM Updated to eliminate the need for Ctrl+Alt combinations
2009-03-03 RDE & DRM: Added option to *require* deadkey before full vowels.

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

; First, we'll set the options according to the parameter string.  (As this is not a multi-instance script, we can do this here in the OnLoadScript subroutine.)
	SwapSHA := GetParam("SwapSHA", 1) ; whether to swap SHA (z) and SSA (S) keys
	ScriptDigit := GetParam("ScriptDigit", 0) ;  whether to use script digits by default (and CapsLock for Roman digits)
	SwapHalfH := GetParam("SwapHalfH", 0) ; for Kangri, the default 'x' behavior for post-h is non-joining
	UseLLA := GetParam("UseLLA", 1) ; for languages that don't need LLA (ळ), shift+L can give a shortcut for lo-R (e.g in क्र) normally obtained by typing  ; r
	SmartQuotes := GetParam("SmartQuotes", 0)
	ApostropheForTone := GetParam("ApostropheForTone", 0)
	OnlyDeadKeyForVowels := GetParam("OnlyDeadKeyForVowels", 0)

; Now we can register the rotas.
RegisterRota(1, "। . ॥	…"
;|	। . ॥		 0964 |  002E |  0965		 devanagari_danda |  full_stop |  devanagari_double_danda
;|	…		 2026		 horizontal_ellipsis
	, 0x964)	;|	devanagari_danda (।)

; RI keyed as r;i
RegisterRota(2, "र्	ृ")
;|	र्		 0930 094D		 devanagari_letter_ra devanagari_sign_virama
;|	ृ		 0943		 devanagari_vowel_sign_vocalic_r

; syllabic RI keyed as qr;i
RegisterRota(3, "र्	ऋ")
;|	र्		 0930 094D		 devanagari_letter_ra devanagari_sign_virama
;|	ऋ		 090B		 devanagari_letter_vocalic_r

; Alternate keying for ksHa as k;z.  You could also type it at k;S or simply Z
RegisterRota(4, "क्	क्ष"
;|	क्		 0915 094D		 devanagari_letter_ka devanagari_sign_virama
;|	क्ष		 0915 094D 0937		 devanagari_letter_ka devanagari_sign_virama devanagari_letter_ssa
	, 0x936)	;|	devanagari_letter_sha (श)

; Add candra mark to create candra E and O, or press twice to create OM.
RegisterRota(5, "ा ॉ	ए ऍ	ो ॉ	आ ऑ	ओ ऑ	े ॅ	ॅ ॐ"
;|	ा ॉ		 093E |  0949		 devanagari_vowel_sign_aa |  devanagari_vowel_sign_candra_o
;|	ए ऍ		 090F |  090D		 devanagari_letter_e |  devanagari_letter_candra_e
;|	ो ॉ		 094B |  0949		 devanagari_vowel_sign_o |  devanagari_vowel_sign_candra_o
;|	आ ऑ		 0906 |  0911		 devanagari_letter_aa |  devanagari_letter_candra_o
;|	ओ ऑ		 0913 |  0911		 devanagari_letter_o |  devanagari_letter_candra_o
;|	े ॅ		 0947 |  0945		 devanagari_vowel_sign_e |  devanagari_vowel_sign_candra_e
	, 0x945, 0, 0, 3) ;|	devanagari_vowel_sign_candra_e (ॅ)

; Pressing colon key.  If you use ः more often than ऽ, just swap their order in this rota.
RegisterRota(6, ": ऽ ः	::"
;|	: ऽ ः		 003A |  093D |  0903		 colon |  devanagari_sign_avagraha |  devanagari_sign_visarga
;|	::		 003A 003A		 colon colon
	, 0x3A) ;|	colon (:)

; Pressing minus key
RegisterRota(7, "- ­ – —	——", 0x2D)
;|	- ­ – —		 002D |  00AD |  2013 |  2014		 hyphen-minus |  soft_hyphen |  en_dash |  em_dash
;|	——		 2014 2014		 em_dash em_dash
RegisterRota(8, "[	⌊", 0x5B) ;|	left_square_bracket ([)
;|	[		 005B		 left_square_bracket
;|	⌊		 230A		 left_floor
RegisterRota(9, "]	⌋", 0x5D) ;|	right_square_bracket (])
;|	]		 005D		 right_square_bracket
;|	⌋		 230B		 right_floor

; Pressing Y key:   n;y for NYA, g;y for GYA (and nxy and gxy as alternatives to nY and gY)
RegisterRota(10, "न् ञ	न्‍ न्य	ग् ज्ञ	ग्‍ ग्य", 0x92F, 0, 0, 1)

; Pressing GreaterThan key (>) for nukta and abbreviation symbol
RegisterRota(11, "़ ॰", 0x93C)

return

;=================================================================================================

;*** BkSp / Sp / Tab
; $Backspace::UndoLast()
; $Space::DoSpace()
; $Tab::DoTab()
; $Enter::DoEnter()
;*

;*** Some general-purpose functions we utilize.
; More efficient than using a store.  More maintainable than embedding conditions directly in the code.
IsConsonant(c) {
	return (c >= 0x915 and c <= 0x939)	;|	devanagari_letter_ka (क)  devanagari_letter_ha (ह)
}

IsConsOrNukta(c) {
	return (IsConsonant(c) or c=0x93C)	;|	devanagari_sign_nukta (़)
}

IsMatra(c) {
	return (c >= 0x93E and c <= 0x94C)	;|	devanagari_vowel_sign_aa (ा)  devanagari_vowel_sign_au (ौ)
}
;*

;*** VOWELS

$q::SendChar(1, 1)	; Deadkey 1: For forcing independent vowels

DoVowel(syl, dep) {
	global OnlyDeadKeyForVowels
	outputdebug ODKFV = "%OnlyDeadKeyForVowels%"
	if (OnlyDeadKeyForVowels)
		SendChar(flags() = 1 ? syl : dep)
	else
		SendChar(IsConsOrNukta(ctx()) ? dep : syl)
}

$a::
if (ctx() = 0x905)		; just as with DevRom, a syllabic A followed by 'a' gives syllabic AA
	ReplaceChar(0x906)	;|	devanagari_letter_aa (आ)
else
	DoVowel(0x905, 0x93E)		;|	devanagari_letter_a (अ)  devanagari_vowel_sign_aa (ा)
return

$i::
cc3 := ctx(3)
DoRota(IsConsOrNukta(cc3) ? 2 : 3) ; Check for r;i shortcut for ऋ / ृ
	or DoVowel(0x907, 0x93F) ;|	devanagari_letter_i (इ)  devanagari_vowel_sign_i (ि)
return

$+a::DoVowel(0x906, 0x93E)	;|	devanagari_letter_aa (आ)  devanagari_vowel_sign_aa (ा)
$+i::DoVowel(0x908, 0x940)	;|	devanagari_letter_ii (ई)  devanagari_vowel_sign_ii (ी)
$u::DoVowel(0x909, 0x941)	;|	devanagari_letter_u (उ)  devanagari_vowel_sign_u (ु)
$+u::DoVowel(0x90A, 0x942)	;|	devanagari_letter_uu (ऊ)  devanagari_vowel_sign_uu (ू)
$e::DoVowel(0x90F, 0x947)	;|	devanagari_letter_e (ए)  devanagari_vowel_sign_e (े)
$+e::DoVowel(0x910, 0x948)	;|	devanagari_letter_ai (ऐ)  devanagari_vowel_sign_ai (ै)
$o::DoVowel(0x913, 0x94B)	;|	devanagari_letter_o (ओ)  devanagari_vowel_sign_o (ो)
$+o::DoVowel(0x914, 0x94C)	;|	devanagari_letter_au (औ)  devanagari_vowel_sign_au (ौ)
$+h::DoRota(5)		; Shift+H adds candra.  Two of them makes OM.   (ॐ)
$^!l::DoVowel(0x90B, 0x943)	; Old DevRom keys for devanagari_letter_vocalic_r (ऋ)  devanagari_vowel_sign_vocalic_r (ृ).  You can also use r;i
;*

;*** CONSONANTS
$k::SendChar(0x915)		;|	devanagari_letter_ka (क)
$+k::SendChar(0x916)		;|	devanagari_letter_kha (ख)
$g::SendChar(0x917)		;|	devanagari_letter_ga (ग)
$+g::SendChar(0x918)		;|	devanagari_letter_gha (घ)
$+m::SendChar(0x919)		;|	devanagari_letter_nga (ङ)
$c::SendChar(0x91A)		;|	devanagari_letter_ca (च)
$+c::SendChar(0x91B)		;|	devanagari_letter_cha (छ)
$j::SendChar(0x91C)		;|	devanagari_letter_ja (ज)
$+j::SendChar(0x91D)		;|	devanagari_letter_jha (झ)
$^!n::SendChar(0x91E)		;|	devanagari_letter_nya (ञ)
$f::SendChar(0x91F)		;|	devanagari_letter_tta (ट)
$+f::SendChar(0x920)		;|	devanagari_letter_ttha (ठ)
$v::SendChar(0x921)		;|	devanagari_letter_dda (ड)
$+v::SendChar(0x922)		;|	devanagari_letter_ddha (ढ)
$+n::SendChar(0x923)		;|	devanagari_letter_nna (ण)
$t::SendChar(0x924)		;|	devanagari_letter_ta (त)
$+t::SendChar(0x925)		;|	devanagari_letter_tha (थ)
$d::SendChar(0x926)		;|	devanagari_letter_da (द)
$+d::SendChar(0x927)		;|	devanagari_letter_dha (ध)
$n::SendChar(0x928)		;|	devanagari_letter_na (न)
$p::SendChar(0x92A)		;|	devanagari_letter_pa (प)
$+p::SendChar(0x92B)		;|	devanagari_letter_pha (फ)
$b::SendChar(0x92C)		;|	devanagari_letter_ba (ब)
$+b::SendChar(0x92D)		;|	devanagari_letter_bha (भ)
$m::SendChar(0x92E)		;|	devanagari_letter_ma (म)
$r::SendChar(0x930)		;|	devanagari_letter_ra (र)
$l::SendChar(0x932)		;|	devanagari_letter_la (ल)
$w::SendChar(0x935)		;|	devanagari_letter_va (व)
$h::SendChar(0x939)		;|	devanagari_letter_ha (ह)
$+w::SendChars("0x926,0x94D,0x935")	; Shortcut for dwa ;|	devanagari_letter_da (द)  devanagari_sign_virama (्)  devanagari_letter_va (व)

$y::DoRota(10)	; for NYA, GYA, etc.
$^!2::		; old DevRom keys for GYA
$^!j::SendChars("0x91C,0x94D,0x91E")	;|	devanagari_letter_ja (ज)  devanagari_sign_virama (्)  devanagari_letter_nya (ञ)
$+y::SendChars("0x94D,0x92F")		; shortcut for join -ya  ;|	devanagari_sign_virama (्)  devanagari_letter_ya (य)

$s::SendChar(0x938)		;|	devanagari_letter_sa (स)
$+z::SendChars("0x915,0x94D,0x937")	; shortcut for ksHa ;|	devanagari_letter_ka (क)  devanagari_sign_virama (्)  devanagari_letter_ssa (ष)
$+s::SendChar(SwapSHA ? 0x936 : 0x937)		;|	devanagari_letter_ssa (ष)
$z::
if (SwapSHA)
	SendChar(0x937)
else
	DoRota(4)			; Alternate keying for ksHa as k;z.
return

$+l::
if (UseLLA)
	SendChar(0x933)	;|	devanagari_letter_lla (ळ)
 else
	SendChars("0x94D,0x930")	;|	devanagari_sign_virama (्)  devanagari_letter_ra (र)
return
;*

;*** MISC:

$+`;::DoRota(6)  ; Colon key => rota: colon, avagraha, visarga
$^!h::SendChar(0x93D)		; Old DevRom key for devanagari_sign_avagraha (ऽ)
$^!;::SendChar(0x903)		; Old DevRom key for devanagari_sign_visarga (ः)

$`::SendChar(0x901)		;|	devanagari_sign_candrabindu (ँ)
$~::SendChar(0x902)		;|	devanagari_sign_anusvara (ं)

$.::DoRota(1)			; Key: Period (.)
$^!3::SendChar(0x2026)		; Old DevRom key for horizontal_ellipsis (…)

$>::DoRota(11)			; Key: RightWedge (>)	rota: devanagari_sign_nukta (़)  and devanagari_abbreviation_sign (॰)
$^!0::SendChar(0x970)		; Old DevRom key for devanagari_abbreviation_sign (॰)
$^![::SendChar(0x93C)		; Old DevRom key for devanagari_sign_nukta (़)

$;::SendChar(0x94D)		; Key: semi-colon (;)   => devanagari_sign_virama (्)

$x::        ; Key: X
swap := (ctx()=0x939 ? SwapHalfH : 0)	 	;|	devanagari_letter_ha (ह)
SendChar(0x94D)	;|	devanagari_sign_virama (्)
SendChar(swap ? 0x200C : 0x200D) 	 ;|	zero_width_non-joiner (‌)  zero_width_joiner (‍)
return

$+x::		; Key: Shift+X
swap := (ctx()=0x939 ? SwapHalfH : 0)	 	;|	devanagari_letter_ha (ह)
SendChar(0x94D)	;|	devanagari_sign_virama (्)
SendChar(swap ? 0x200D : 0x200C) 	 ;|	zero_width_joiner (‍)  zero_width_non-joiner (‌)
return

$+r::DoReph()		; Key: Shift +R   - quirkiest part of DevRom, the flying reph typed in written (not phonetic) order.
	; You can always get a flying reph by typing r ; before the consonant.
	; DevRom also allows you to obtain a flying reph by typing R _after_ the syllable.
	; e.g. कर्ल़ि can be typed kl>iR or kl>Ri or klR>i.

DoReph() {
	c1 := ctx()
	if (IsConsonant(c1))
		return InsertChars("0x930,0x94D", 0, 1)	;|	devanagari_letter_ra (र)  devanagari_sign_virama (्)
	c2 := ctx(2)
	if (IsConsonant(c2) and (IsMatra(c1) or c1=0x93C))  ; Cons + (matra or nukta)
		return InsertChars("0x930,0x94D", 0, 2)
	c3 := ctx(3)
	if (IsConsonant(c3) and c2=0x93C and IsMatra(c1)) ; Cons + nukta + matra
		return InsertChars("0x930,0x94D", 0, 3)
	SendChars("0x930,0x94D")
}
;*
;---------------------------------------------

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

$>!0::
$>!1::
$>!2::
$>!3::
$>!4::
$>!5::
$>!6::
$>!7::
$>!8::
$>!9::DoDigit(SubStr(A_ThisHotKey,0), 1)  ; A_ThisHotKey will include the $>!, so we trim that.

DoDigit(dd, reverse=0) {
	global ScriptDigit
	cc := ctx()
	if (cc > 47 and cc < 58) {
		sd := 0	; If context is roman digit, do roman.
	} else {
		if (cc >= 0x966 and cc <= 0x96F)  ;|	devanagari_digit_zero (०)  devanagari_digit_nine (९)
			sd := 1	; If context is script digit, do script.
		else   	; Default: Send a roman digit unless CapsLock is turned on.
			sd := GetKeyState("CapsLock", "T") ^ ScriptDigit ^ reverse  ; The ScriptDigit command line parameter reverses this logic.
	}
	SendChar((sd ? 0x966 : 48) + dd)
}
;*

; Misc keys, not particularly Devanagari related
$-::DoRota(7)	; Minus key, produces various hyphens/dashes
$[::DoRota(8)  ; type [[ for ⌊ left_floor
$]::DoRota(9)	; type ]] for ⌋ right_floor

$"::DoQuoteMark(0x22, 0x201C, 0x201D)	; smart double quotes

$'::	; apostrophe key (') for tone mark or single quotes
if (ApostropheForTone)
	SendChar(0x2019)		; In Dogri, the apostrophe is used as a tone marker  ;|	right_single_quotation_mark (’)
else
	DoQuoteMark(0x27, 0x2018, 0x2019) ; Treat it as a single-quote marker
return

DoQuoteMark(plain, left, right) {
	global SmartQuotes
	ff := flags()	; we'll use the flags to store the alternate of the character actually sent, so that a repeat press can reverse it.
	cc := ctx()
	if (ff=plain or ff=left or ff=right) {	; if last char was generated here
		ReplaceChar(ff, 1, 1, cc)  	; we'll swap the flag and the character itself
		SmartQuotes := SmartQuotes ^ 1
	} else {
		smartQChar := cc>32 ? right : left
		if (smartQuotes)
			SendChar(smartQChar, plain)
		else
			SendChar(plain, smartQChar)
	}
}
