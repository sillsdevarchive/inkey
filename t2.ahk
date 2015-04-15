;SendChar(0xD834)
;SendChar(0xDD03)
;return
;क𝀀񐰀

;$6::SendText("𝄃")
#include iSendU.ahk	; InKey's customized version of the SendU module

; Send a character (up to character 0xFFFF only)
; To send an SMP character, call SendChar16 once for each character in the surrogate pair. i.e. UTF-16
SendChar16(c) {
	;~ DllCall("QueryPerformanceCounter", "Int64*", sctCounterBefore)
	setformat integerfast, H
	c += 0
	a := "{U+" . substr(c,3,4) . "}"
	SendInput %a%
	r := 1
	;MsgBox %c%
	;~ DllCall("QueryPerformanceCounter", "Int64*", sctCounterAfter)
	;~ DllCall("QueryPerformanceFrequency", "Int64 *", f)
	;~ x := (sctCounterAfter - sctCounterBefore) * 1000 / f
	;~ outputdebug SendCh(%c%) took %x% ms
	return r
}

SendChar(ch, uFlags=0) {
	;SetFormat integer, d
	;~ v := ch + 0
	;outputdebug SendChar: %ch% (%v%), %uFlags%
	if (ch <= 0xffff) {
		if (ch>1) {
			SendChar16(ch)
			;outputdebug sendch(%ch%)
		}
	} else {  ; SMP character. Convert to surrogate pair
		SetFormat integer, hex
		ch -= 0x10000
		SendChar16(0xd800 | (ch >> 10))
		SendChar16(0xdc00 | (ch & 0x3ff))
	}
}

$e::SendChar16(0x0915)

$f::SendCh(0x0915)

$g::SendRaw क

$h::SendInput {U+0915}

$i::
SendChar16(0xD800)
SendChar16(0xDC00)
return

$j::
SendCh(0xD800)
SendCh(0xDc00)
return

$k::SendRaw 𐀀

$m::SendInput {U+d834}{U+dd1e}

$n::SendChar(0x1d11e)

$x::
c := Chr(0xd834) . chr(0xdd1e)
Critical
ClipSaved := ClipboardAll   ; Save the entire clipboard to a variable of your choice.

Clipboard := c
ClipWait
Send +{Ins}
Sleep, 50 ; see http://www.autohotkey.com/forum/viewtopic.php?p=159301#159306

Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
ClipSaved =   ; Free the memory in case the clipboard was very large.
Critical, Off
return

$a::
VarSetCapacity(SendUbuf, 28, 0)     ;set variable size for SendInputक
NumPut(1, SendUbuf, 0, "Char")      ;format the variable for SendInput

HexCode=0x0915
NumPut(0x40000, SendUbuf, 6)
NumPut(HexCode, SendUbuf, 6, "Short")
result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
OutputDebug result = %result%
SetFormat integer, hex
loop 28 {
	i := A_Index - 1
	c := NumGet(SendUBuf, i, "UChar")
	OutputDebug [%i%]: %c%
}
return

$b::
VarSetCapacity(SendUbuf, 28, 0)     ;set variable size for SendInput
NumPut(1, SendUbuf, 0, "Char")      ;format the variable for SendInput
Ucode=0915
Send {LAlt Down}{NumpadAdd}%Ucode%{LAlt Up}
return

$c::
VarSetCapacity(SendUbuf, 28, 0)     ;set variable size for SendInput
NumPut(1, SendUbuf, 0, "Char")      ;format the variable for SendInput
HexCode=0x0915
NumPut(0x60000, SendUbuf, 6)
NumPut(HexCode, SendUbuf, 6, "Short")
result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
OutputDebug result = %result%
return

$+a::
VarSetCapacity(SendUbuf, 56, 0)     ;set variable size for SendInput𝀀񗠀
NumPut(1, SendUbuf, 0, "Char")      ;format the variable for SendInput
NumPut(1, SendUbuf, 28, "Char")      ;format the variable for SendInput

HexCode=0xd834
NumPut(0x40000, SendUbuf, 6)
NumPut(HexCode, SendUbuf, 6, "Short")
NumPut(0x40000, SendUbuf, 34)
NumPut(0xdd1e, SendUbuf, 34, "Short")

result := DllCall("SendInput", "uint", 2, "uint", &SendUbuf, "int", 28)
OutputDebug result = %result%
SetFormat integer, hex
loop 56 {
	i := A_Index - 1
	c := NumGet(SendUBuf, i, "UChar")
	OutputDebug [%i%]: %c%
}
return

$y::
; Switch the active window's keyboard layout/language to English:
;~ PostMessage, 0x50, 0, 0x4090409,, A  ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
PostMessage, 0x302, 0, 0,, A  ; 0x50 is WM_INPUTLANGCHANGEREQUEST.

;~ PostMessage 0x0302, 0, 0,, A
;~ Run Notepad
;~ WinWait Untitled - Notepad
;~ PostMessage, 0xC, 0, "New Notepad Title"  ; 0XC is WM_SETTEXT
;~ MsgBox done
return

$^q::ExitApp
