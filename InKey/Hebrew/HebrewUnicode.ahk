/*	InKey script to provide a keyboard layout for Hebrew Unicode

	Keyboard:	Hebrew Unicode
	Version:    1.0 BETAa
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


OnLoadScript:
InChars=0x5b7,0x5b6,0x5b4,0x5bb,0x5b8,0x5b5
StringSplit, Vowels, InChars, `,
return
;________________________________________________________________________________________________________________

$`:: SendChar(0x20AC)	;| €
$+`:: SendChar(0x20AA)	;| ₪
$!`:: SendChar(0x24)	;| $

$!1:: SendChar(0x5BD)	;| ֽ
$!+1:: SendChar(0x597)	;| ֗

$@:: SendChar(0x598)	;| ֘
$!2:: SendChar(0x5A2)	;| ֢
$!+2:: SendChar(0x5AE)	;| ֮

$#:: SendChar(0x5A8)	;| ֨
$!3:: SendChar(0x596)	;| ֖
$!+3:: SendChar(0x599)	;| ֙

$$:: SendChar(0x59C)	;| ֜
$!4:: SendChar(0x5A5)	;| ֥
$!+4:: SendChar(0x5A0)	;| ֠

$%:: SendChar(0x59E)	;| ֞
$!5:: SendChar(0x5A6)	;| ֦
$!+5:: SendChar(0x5A9)	;| ֩

$!6:: SendChar(0x5AD)	;| ֭
$^::
cc := ctx()
if (cc = 0x5E1)
{
	ReplaceChar(0x5E9)	;| ש
	SendChar(0x5C1)	;| ׁ
}
else
	SendChar(0x5E)	;| ^
return
$!+6:: SendChar(0x59F)	;| ֟

$&:: SendChar(0x5AC)	;| ֬
$!7:: SendChar(0x5A3)	;| ֣
$!+7:: SendChar(0x5A1)	;| ֡

$+8:: SendChar(0x59D)	;| ֝
$!8:: SendChar(0x59B)	;| ֛
$!+8:: SendChar(0x595)	;| ֕

$!9:: SendChar(0x5A7)	;| ֧
$!+9:: SendChar(0x593)	;| ֓

$!0:: SendChar(0x5AA)	;| ֪
$!+0:: SendChar(0x5AF)	;| ֯

$-:: SendChar(0x5BE)	;| ־
$+-:: SendChar(0x2013)	;| –
$!-:: SendChar(0x2014)	;| —
$!+-:: SendChar(0x5BF)	;| ֿ

$=::
cc := ctx()
if (cc = 0x5B7)
	ReplaceChar(0x5B8)	;| ָ
else if (cc = 0x5B6)
	ReplaceChar(0x5B5)	;| ֵ
else if (cc = 0x5B9)
	ReplaceChar(0x5B9)	;| ֹ
else
	SendChar(0x5BC)	;| ּ
return
$+::
cc := ctx()
if (cc = 0x5E1)
{
	ReplaceChar(0x5E9)	;| ש
	SendChar(0x5C2)	;| ׂ
}
else
	SendChar(0x2B)	;| +
return
$!=:: SendChar(0x591)	;| ֑
$!+=:: SendChar(0x25CC)	;| ◌

$q:: SendChar(0x5E7)	;| ק
$+q:: SendChar(0x597)	;| ֗

$w::
cc := ctx()
if (cc = 0x5B9)
{
	ReplaceChar(0x5D5)	;| ו
	SendChar(0x5B9)	;| ֹ
}
else
	SendChar(0x5D5)	;| ו
return

$e::
CheckForPrecedingVowel()
SendChar(0x5B6)	;| ֶ
return
$+e::
CheckForPrecedingVowel()
SendChar(0x5B5)	;| ֵ
return
$!+e:: SendChar(0x5B1)	;| ֱ

$r:: SendChar(0x5E8)	;| ר

$t::
cc := ctx()
if (cc = 0x2E)
	ReplaceChar(0x5D8)	;| ט
else
	SendChar(0x5EA)	;| ת
return

$y:: SendChar(0x5D9)	;| י
$+y:: SendChar(0x59F)	;| ֟

$u::
CheckForPrecedingVowel()
SendChar(0x5BB)	;| ֻ
return

$i::
CheckForPrecedingVowel()
SendChar(0x5B4)	;| ִ
return

$o::
cc := ctx()
dd := ctx(2)
if (cc = 0x5D5)
{
	ReplaceChar(0x5D5)	;| ו
	SendChar(0x5BA)	;| ֺ
}
else if ((cc = 0x5BC) and (dd = 0x5D5))
	SendChar(0x5BA)	;| ֺ
else
	SendChar(0x5B9)	;| ֹ
return
$+o::
cc := ctx()
if (cc = 0x5D5)
{
	ReplaceChar(0x5D5)	;| ו
	SendChar(0x5BA)	;| ֺ
}
else
	SendChar(0x5B9)	;| ֹ
return
$!o:: SendChar(0x5C7)	;| ׇ
$!+o:: SendChar(0x5B3)	;| ֳ

$p:: SendChar(0x5E4)	;| פ
$+p:: SendChar(0x5E3)	;| ף
$!+p:: SendChar(0x34F)	; CGJ

$!+[:: SendChar(0x594)	;| ֔

$!]:: SendChar(0x59A)	;| ֚
$!+]:: SendChar(0x592)	;| ֒

$+\:: SendChar(0x5C0)	;| ׀
$!\:: SendChar(0x5A4)	;| ֤
$!+\:: SendChar(0x5AB)	;| ֫

$a::
CheckForPrecedingVowel()
SendChar(0x5B7)	;| ַ
return
$+a::
CheckForPrecedingVowel()
SendChar(0x5B8)	;| ָ
return
$!a:: SendChar(0x5C7)	;| ׇ
$!+a:: SendChar(0x5B2)	;| ֲ

$s::
cc := ctx()
if (cc = 0x2E)
	ReplaceChar(0x5E6)	;| צ
else
	SendChar(0x5E1)	;| ס
return
$+s:: SendChar(0x5E9)	;| ש

$d:: SendChar(0x5D3)	;| ד

$f::
SendChar(0x5E9)	;| ש
SendChar(0x5C2)	;| ׂ
return

$g:: SendChar(0x5D2)	;| ג

$h::
cc := ctx()
if (cc = 0x2E)
	ReplaceChar(0x5D7)	;| ח
else
	SendChar(0x5D4)	;| ה
return

$j::
SendChar(0x5E9)	;| ש
SendChar(0x5C1)	;| ׁ
return

$k:: SendChar(0x5DB)	;| כ
$+k:: SendChar(0x5DA)	;| ך

$l:: SendChar(0x5DC)	;| ל

$`;::
cc := ctx()
if (cc = 0x5B7)
	ReplaceChar(0x5B2)	;| ֲ
else if (cc = 0x5B6)
	ReplaceChar(0x5B1)	;| ֱ
else if (cc = 0x5B9)
	ReplaceChar(0x5B3)	;| ֳ
else
	SendChar(0x5B0)	;| ְ
return
$+`;:: SendChar(0x5F4)	;| ״
$!`;:: SendChar(0x3B)	;| ;
$!+`;:: SendChar(0x5C3)	;| ׃

$':: SendChar(0x2019)	;| ’
$+':: SendChar(0x201D)	;| ”
$!':: SendChar(0x5C5)	;| ׅ
$!+':: SendChar(0x5C4)	;| ׄ

$z:: SendChar(0x5D6)	;| ז

$x:: SendChar(0x5D7)	;| ח

$c:: SendChar(0x5E6)	;| צ
$+c:: SendChar(0x5E5)	;| ץ

$v:: SendChar(0x5D8)	;| ט

$b:: SendChar(0x5D1)	;| ב

$n:: SendChar(0x5E0)	;| נ
$+n:: SendChar(0x5DF)	;| ן
$!n:: SendChar(0x5C6)	;| ׆

$m:: SendChar(0x5DE)	;| מ
$+m:: SendChar(0x5DD)	;| ם
$!m:: SendChar(0x200C)	; ZWNJ
$!+m:: SendChar(0x200D)	; ZWJ

$<:: SendChar(0x5E2)	;| ע
$!,:: SendChar(0xAB)	;| »
$!+,:: SendChar(307)	;| ֹ

$>:: SendChar(0x5D0)	;| א
$!.:: SendChar(0xBB)	;| «
$!+.:: SendChar(0x308)	;| ̈

$!/:: SendChar(0x5F3)	;| ׳
$!+/:: SendChar(0x5F4)	;| ״

$!Space:: SendChar(0x2009)	;|  
$!+Space:: SendChar(0xA0)	;|

CheckForPrecedingVowel() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %Vowels0%
	{
		if (cc = Vowels%a_index%)
			{
				SendChar(0x34F)
				return
			}
	}
	return
}