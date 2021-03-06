/*	InKey script to provide a keyboard layout for GENERIC.

	Keyboard:	GENERIC
	Version:	1.0
	Author:
	Official Distribution:	http://inkeysoftware.com

	You are free to modify this script for your own purposes. Please give credit as appropriate.

Remarks:

HISTORY:
*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.094
	; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	; It can be found near the top of the InKeyLib.ahki file.
	; It may be lower than the InKey version number.
	; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 2	; Causes uncaptured character keys to be included in the context too.  CONTEXT SENSITIVE

#include InKeyLib.ahki

OnLoadScript:	; This section is executed when this InKey script is first loaded.

	return

; _______________________________________________________


;~ ; Very simple keyboard with no reordering
;~ $1::Send("①")
;~ $2::Send("②")
;~ $3::Send("③")
;~ $4::Send("④")
;~ $5::Send("⑤")

;~ ; Keyboard with reordering such that sequential digits are always resorted into the order: ①②③④⑤
;~ $1::InCase(Replace("[②③④⑤]+") With("①$0")) or Send("①")
;~ $2::InCase(Replace("[③④⑤]+") With("②$0"))  or Send("②")
;~ $3::InCase(Replace("[④⑤]+") With("③$0")) or Send("③")
;~ $4::InCase(Replace("[⑤]+") With("④$0")) or Send("④")
;~ $5::Send("⑤")

;~ ; Keyboard with context-dependent reordering.
;~ ; Above sort order applies EXCEPT in sequences following the letter 'b', where order is: ⑤④③②①
$1::InCase(After("b[⑤④③②①]*") ThenSend("①"))
  or InCase(Replace("[②③④⑤]+") With("①$0"))
  or Send("①")

$2::InCase(After("b[⑤④③②]*") Replace("①*") With("②$0"))
  or InCase(Replace("[③④⑤]+") With("②$0"))
  or Send("②")

$3::InCase(After("b[⑤④③]*") Replace("[②①]*") With("③$0"))
  or InCase(Replace("[④⑤]+") With("③$0"))
  or Send("③")

$4::InCase(After("b[⑤④]*") Replace("[③②①]*") With("④$0"))
  or InCase(Replace("[⑤]+") With("④$0"))
  or Send("④")

$5::InCase(After("b[⑤]*") Replace("[④③②①]*") With("⑤$0"))
  or Send("⑤")



$=::InCase(LoopMap("h→ɥ→ħ→ɦ↺", "y→ɥ→ʏ↺"))

$`::InCase(Replace("\b([^aeiou ]+)(\S+)") with("$2$1ay"))
		or  InCase(After("\b[aeiou]\S+") thenSend("way"))
		or Beep()
