/*
------------------------------------------------------------------------
InKeySendU module, based largely on SendU module: http://autohotkey.try.hu/SendU/SendU.ahk

InKey's modifications:
-modified to preserve hidden icons
-Modes renamed to 1, 2, and 3 for user-interface purposes
-Sending modes for each app are stored in AppList.txt and UserAppList.txt


------------------------------------------------------------------------

SendU module for sending Unicode characters
http://www.autohotkey.com

------------------------------------------------------------------------

Version: 0.0.11 2008-03-03
License: GNU General Public License
Author: FARKAS Máté <http://fmate14.try.hu/> (My given name is Máté)

Tested Platform:  Windows XP/Vista
Tested AutoHotkey Version: 1.0.47.04
Lastest version: http://autohotkey.try.hu/SendU/SendU.ahk
Location in AutoHotkey forum: http://www.autohotkey.com/forum/viewtopic.php?t=25566

Contributors:
	* Laszlo Hars <www.Hars.US>
		original SendU function, _SendU_UnicodeChar function
		and some bugfixes
	* Shimanov
		original SendU function
	* Piz
		Fixed goto issues
		http://www.autohotkey.com/forum/viewtopic.php?p=182218#182218

------------------------------------------------------------------------

If you would like help to me...
Please correct my english misspellings...

------------------------------------------------------------------------
*/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PUBLIC GLOBAL VARIABLES FOR LOCALIZE
; See the _SendU_Load_Locale() function!

; PRIVATE GLOBAL VARIABLES
; _SendU_*** : unicode number -> utf8 character

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PUBLIC FUNCTIONS

SendCh( Ch ) ; Character number code, for example 97 (or 0x61) for 'a'
{

; global showmode
; dansmode := SendU_Mode()
; if showmode
	; ToolTip %dansmode%, 1, 1, 2

	Ch += 0
	if ( Ch < 0 ) {
		; What do you want???
		return
	} else if ( Ch < 33 ) {
		; http://en.wikipedia.org/wiki/Control_character#How_control_characters_map_to_keyboards
		Char = ;
		if ( Ch == 32 ) {
			Char = {Space}
		} else if ( Ch == 9 ) {
			Char = {Tab}
		} else if ( Ch > 0 && Ch <= 26 ) {
			Char := "^" . Chr( Ch + 64 )
		} else if ( Ch == 27 ) {
			Char = ^{VKDB}
		} else if ( Ch == 28 ) {
			Char = ^{VKDC}
		} else if ( Ch == 29 ) {
			Char = ^{VKDD}
		} else {
			SendU( Ch )
			return
		}
		Send %Char%
	} else if ( Ch < 129 ) {
		; ASCII characters
		Char := "{" . Chr( Ch ) . "}"
		Send %Char%
	} else {
		; Unicode characters
		SendU( Ch )
	}
}


SendU( UC )
{
SetFormat IntegerFast, d  ;drm
	UC += 0
	if ( UC <= 0 )
		return

	mode := SendU_Mode()

	; DRM: This section added because SendInput messes up when Ctrl or Alt is still pressed.
	outputdebug SendU(%uc%), mode=%mode%
	if (GetKeyState("Alt") or GetKeyState("Ctrl")) {
		_SendU_Clipboard(UC)
		return
	}
	ralt := 0
	if (GetKeyState("RAlt")) {
		ralt := 1
		Send {RAlt Up}
	}


	if ( mode = "d" ) { ; dynamic
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
; tooltip d-%mode%,1,1,2
	}

	if ( mode = "i" )
		_SendU_Input(UC)
	else if ( mode = "c" ) ; clipboard
		_SendU_Clipboard(UC)
	else if ( mode = "a" ) { ; {ASC nnnn}
		if ( UC < 256 )
			UC := "0" . UC
		Send {ASC %UC%}
	} else { ; input
		_SendU_Input(UC)
	}

	; if (ralt = 1)
		; Send {RAlt Down}
}

SendU_utf8_string( str )
{
	mode := SendU_Mode()
	if ( mode = "d" ) { ; dynamic
		WinGet, pn, ProcessName, A
		mode := _SendU_Dynamic_Mode( pn )
	}

	if ( mode = "c" ) ; clipboard
		_SendU_Clipboard( str, 1 )
	else if ( mode = "a" ) { ; {ASC nnnn}
		codes := _SendU_Utf_To_Codes( str, "_" )
		Loop, parse, codes, _
		{
			UC := A_LoopField
			if ( UC < 256 )
				UC := "0" . UC
			Send {ASC %UC%}
		}
	} else {
		codes := _SendU_Utf_To_Codes( str, "_" )
		Loop, parse, codes, _
		{
			_SendU_Input(A_LoopField)
		}
	}
}

SendU_Mode( newMode = -1 )
{
	static mode := "i"
	if ( newMode == "d" || newMode == "i" || newMode == "a" || newMode == "c" )
		mode := newMode
	return mode
}

SendU_Clipboard_Restore_Mode( newMode = -1 )
{
	static mode := 1
	if ( newMode == 1 || newMode == 0 ) ; Enable, disable
		mode := newMode
	else if ( newMode == 2 ) ; Toggle
		mode := 1 - mode
	return mode
}

SendU_Try_Dynamic_Mode()
{
	; get processname and current mode
	WinGet, processName, ProcessName, A
	mode := _SendU_GetMode( processName )
	outputdebug Old mode: %mode%
	; get the new mode
	if ((mode == "i") or (mode == "d"))
		mode = a
	else if ( mode == "a" )
		mode = c
	else
		mode = i

	if (mode == "i")
		nummode=1
	else if (mode == "a")
		nummode=2
	else if (mode == "c")
		nummode=3

	outputdebug New mode: %mode%, Code: %nummode%

	; output tooltip
	_SendU_Dynamic_Mode_Tooltip( processName, mode )
	_SendU_SetMode( processName, mode )
	_SendU_Dynamic_Mode( "", 1 ) ; Clears the PrevProcess variable

	; update UserAppList.txt
;	IfNotExist, %A_WorkingDir%\UserAppList.txt
;	{
;		; create a blank file
;		FileAppend,, %A_WorkingDir%\UserAppList.txt
;	}

	; check to see if file is empty
;	FileRead, Str, %A_WorkingDir%\UserAppList.txt
;	If (Str == "")
;	{
		; blank file, so simply output the first entry
;		newentry := Chr(34) . processName . Chr(34) . "," . nummode
;		FileAppend, %newentry%, %A_WorkingDir%\UserAppList.txt
;	}
;	else
;	{
		; delete old file
;		FileDelete, %A_WorkingDir%\UserAppList.txt
;		entryadded := false
;		firstentry := true

		; loop through file contents looking to see if entry already exists
;		Loop, Parse, Str, `n, `r
;		{
;			Loop, Parse, A_LoopField, CSV
;			{
;				CSV_%A_Index% := A_LoopField
;			}
;			If ( CSV_1 == processName )
;			{
				; write out new mode for existing entry
;				if (firstentry)
;				{
;					updateentry := Chr(34) . processName . Chr(34) . "," . nummode
;					firstentry := false
;				}
;				else
;				{
;					updateentry := Chr(10) . Chr(34) . processName . Chr(34) . "," . nummode
;				}
;				FileAppend, %updateentry%, %A_WorkingDir%\UserAppList.txt
;				entryadded := true
;			}
;			else
;			{
				; write out line of file
;				if (firstentry)
;				{
;					oldentry := Chr(34) . CSV_1 . Chr(34) . "," . Chr(34) . CSV_2 . Chr(34)
;					firstentry := false
;				}
;				else
;				{
;					oldentry := Chr(10) . Chr(34) . CSV_1 . Chr(34) . "," . Chr(34) . CSV_2 . Chr(34)
;				}
;				FileAppend, %oldentry%, %A_WorkingDir%\UserAppList.txt
;			}
;		}
;		If (not entryadded) then
;		{
;			if (firstentry)
;			{
;				newentry := Chr(34) . processName . Chr(34) . "," . nummode
;				firstentry := false
;			}
;			else
;			{
;				newentry := Chr(10) . Chr(34) . processName . Chr(34) . "," . nummode
;			}
;			FileAppend, %newentry%, %A_WorkingDir%\UserAppList.txt
;		}
;	}
	return
}

SendU_Init( mode = "d" )
{
	SendU_Mode( mode )
	_SendU_Load_Locale()
	_SendU_Load_Dynamic_Modes()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PRIVATE FUNCTIONS


_SendU_Input( UC )
{
		; Original SendU function written by Shimanov and Laszlo
	; http://www.autohotkey.com/forum/topic7328.html
	static buffer := "#"
	if buffer = #
	{
		VarSetCapacity( buffer, 56, 0 )
		DllCall("RtlFillMemory", "uint",&buffer,"uint",1, "uint", 1)
		DllCall("RtlFillMemory", "uint",&buffer+28, "uint",1, "uint", 1)
	}
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+6, "uint",4,"uint",0x40000|UC) ;KEYEVENTF_UNICODE
	DllCall("ntdll.dll\RtlFillMemoryUlong","uint",&buffer+34,"uint",4,"uint",0x60000|UC) ;KEYEVENTF_KEYUP|

	if not A_IconHidden
		Menu, Tray, Icon,,, 1 ; Freeze the icon
	Suspend On ; SendInput conflicts with scan codes (SC)!
	DllCall("SendInput", UInt,2, UInt,&buffer, Int,28)  ; non-zero return does not necessarily mean success
	Suspend Off
	if not A_IconHidden
		Menu, Tray, Icon,,, 0 ; Unfreeze the icon

	return
}

_SendU_Utf_To_Codes( utf8, separator = "," ) {
	; Return (comma) separated Unicode numbers of UTF-8 input STRING
	; Written by Laszlo Hars and FARKAS Mate (fmate14)
	static U := "#"
	static res
	if ( U == "#" ) {
		VarSetCapacity(U,   256 * 2)
		VarSetCapacity(res, 256 * 4)
	}
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,256)
	res := ""
	pointer := &U
	Loop, 256
	{
		h := (*(pointer+1)<<8) + *(pointer)
		if ( h == 0 )
			break
		if ( res )
			res .= separator
		res .= h
		pointer += 2
	}
	Return res
}

SendU_Utf_To_CodesPub( utf8, separator = "," ) {
	; Return (comma) separated Unicode numbers of UTF-8 input STRING
	; Written by Laszlo Hars and FARKAS Mate (fmate14)
	static U := "#"
	static res
	if ( U == "#" ) {
		VarSetCapacity(U,   256 * 2)
		VarSetCapacity(res, 256 * 4)
	}
	DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,256)
	res := ""
	pointer := &U
	Loop, 256
	{
		h := (*(pointer+1)<<8) + *(pointer)
		if ( h == 0 )
			break
		if ( res )
			res .= separator
		res .= h
		pointer += 2
	}
	Return res
}

; --------------------- functions for clipboard mode ----------------------------

_SendU_Clipboard( UC, isUtfString = 0 )
{
	Critical
	restoreMode := SendU_Clipboard_Restore_Mode()
	if ( isUtfString ) {
		utf := UC
	} else {
		utf := _SendU_GetVar( UC )
		if not utf
		{
			utf := _SendU_UnicodeChar( UC )
			_SendU_SetVar( UC, utf )
		}
	}
	if restoreMode
		_SendU_SaveClipboard()
	;Transform Clipboard, Unicode, %utf%  ; no longer available in AHKL
	Clipboard = %utf%
	ClipWait
	Send +{Ins}
	Sleep, 50 ; see http://www.autohotkey.com/forum/viewtopic.php?p=159301#159306
	if restoreMode {
		_SendU_Last_Char_In_Clipboard( Clipboard )
		SetTimer, _SendU_restore_Clipboard, -3000
	}
	Critical, Off
}

_SendU_RestoreClipboard()
{
	_SendU_SaveClipboard(1)
}

_SendU_SaveClipboard( restore = 0 )
{
	static cb
	if ( !restore && _SendU_Last_Char_In_Clipboard() == "" )
		cb := ClipboardALL
	else
		Clipboard := cb
}

_SendU_Last_Char_In_Clipboard( newChar = -1 )
{
	static ch := ""
	if ( newChar <> -1 )
		ch := newChar
	return ch
}

_SendU_UnicodeChar( UC )  ; Return the Utf-8 char from the Unicode numeric code (UC, in decimal format)
{
	VarSetCapacity(UText, 8, 0)
	NumPut(UC, UText, 0, "UShort")
	outputdebug UC: %UC%, UText: %UText%
	return %UText%

	; the following procedure is no longer necessary, but left in just in case...
	; first get the size
	returnsize := DllCall("WideCharToMultiByte"
		, "UInt", 65001  ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0      ; dwFlags
		, "Str",  UText  ; LPCWSTR lpWideCharStr
		, "Int",  -1     ; cchWideChar: size in WCHAR values: Len or -1 (= null terminated)
		, "Str",  0      ; LPSTR lpMultiByteStr
		, "Int",  0      ; cbMultiByte: Len or 0 (= get required size / allocate!)
		, "UInt", 0      ; LPCSTR lpDefaultChar
		, "UInt", 0)     ; LPBOOL lpUsedDefaultChar

	; allocate space for return string
	VarSetCapacity(AText, returnsize, 0)

	; now do the conversion
	DllCall("WideCharToMultiByte"
		, "UInt", 65001  ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
		, "UInt", 0      ; dwFlags
		, "Str",  UText  ; LPCWSTR lpWideCharStr
		, "Int",  -1     ; cchWideChar: size in WCHAR values: Len or -1 (= null terminated)
		, "Str",  AText  ; LPSTR lpMultiByteStr
		, "Int",  returnsize      ; cbMultiByte: Len or 0 (= get required size / allocate!)
		, "UInt", 0      ; LPCSTR lpDefaultChar
		, "UInt", 0)     ; LPBOOL lpUsedDefaultChar

	return %UText%
}

; --------------------- functions for dynamic mode ----------------------------

_SendU_Get_Mode_Name( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetVar( "Mode_Name_" . mode )
	if ( m == "" )
		m := _SendU_GetVar( "Mode_Name_0" )
	return m
}

_SendU_Get_Mode_Type( mode )
{
	if ( mode == "c" && SendU_Clipboard_Restore_Mode() )
		mode = r
	m := _SendU_GetVar( "Mode_Type_" . mode )
	if ( m == "" )
		m := _SendU_GetVar( "Mode_Type_0" )
	return m
}

_SendU_Dynamic_Mode_Tooltip( processName = -1, mode = -1 )
{
	tt := _SendU_getVar("DYNAMIC_MODE_TOOLTIP")
	if not tt
		return
	if ( processName = -1 || mode == -1 ) {
		WinGet, processName, ProcessName, A
		mode := _SendU_GetMode( processName )
	}
	WinGetTitle, title, A
	StringReplace, tt,tt, $processName$, %processName%, A
	StringReplace, tt,tt, $title$, %title%, A
	StringReplace, tt,tt, $mode$, %mode%, A
	StringReplace, tt,tt, $modeType$, % _SendU_Get_Mode_Type( mode ), A
	StringReplace, tt,tt, $modeName$, % _SendU_Get_Mode_Name( mode ), A
	ToolTip, %tt%
	SetTimer, _SendU_Remove_Tooltip, 2000
}

_SendU_Dynamic_Mode( processName, clearPrevProcess = -1 )
{
;	static prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj" ; Nothing
	static mode := "d"
;	if ( clearPrevProcess == 1 )
;		prevProcess := "fOyj9b4f79YmA7sZRBrnDbp75dGhiauj" ; Nothing
;	if ( processName == prevProcess )
;		return mode
;	prevProcess := processName
;	mode := _SendU_GetMode( processName )
;	if ( mode == "" )
;		mode = i
	return mode
}

; http://www.autohotkey.com/forum/topic17838.html
_SendU_SetMode( sKey, sItm )
{
;	static pdic := 0
;	if ( pdic == 0 )
;		_SendU_Get_Dictionary( pdic )
;	pKey := SysAllocString(sKey)
;	VarSetCapacity(var1, 8 * 2, 0)
;	EncodeInteger(&var1 + 0, 8)
;	EncodeInteger(&var1 + 8, pKey)
;	pItm := SysAllocString(sItm)
;	VarSetCapacity(var2, 8 * 2, 0)
;	EncodeInteger(&var2 + 0, 8)
;	EncodeInteger(&var2 + 8, pItm)
;	DllCall(VTable(pdic, 8), "Uint", pdic, "Uint", &var1, "Uint", &var2)
;	SysFreeString(pKey)
;	SysFreeString(pItm)
}

; http://www.autohotkey.com/forum/topic17838.html
_SendU_GetMode( sKey )
{
;	static pdic := 0
;	if ( pdic == 0 )
;		_SendU_Get_Dictionary( pdic )
;	outputdebug pdic: %pdic%
;	pKey := SysAllocString(sKey)
;	VarSetCapacity(var1, 8 * 2, 0)
;	EncodeInteger(&var1 + 0, 8)
;	EncodeInteger(&var1 + 8, pKey)
;	DllCall(VTable(pdic, 12), "Uint", pdic, "Uint", &var1, "intP", bExist)
;	If bExist
;	{
;		VarSetCapacity(var2, 8 * 2, 0)
;		DllCall(VTable(pdic, 9), "Uint", pdic, "Uint", &var1, "Uint", &var2)
;		pItm := DecodeInteger(&var2 + 8)
;		Unicode2Ansi(pItm, sItm)
;		SysFreeString(pItm)
;	}
;	SysFreeString(pKey)
;	outputdebug sKey: %sKey%, bExist: %bExist%, pItm: %pItm%, sItm: %sItm%
;	Return sItm
}

_SendU_Get_Dictionary( ByRef mypdic )
{
;	static pdic := 0
;	if ( pdic == 0 ) {
;		; http://www.autohotkey.com/forum/topic17838.html
;		CoInitialize()
;		CLSID_Dictionary := "{EE09B103-97E0-11CF-978F-00A02463E06F}"
;		IID_IDictionary := "{42C642C1-97E1-11CF-978F-00A02463E06F}"
;		pdic := CreateObject(CLSID_Dictionary, IID_IDictionary)
;		DllCall(VTable(pdic, 18), "Uint", pdic, "int", 1) ; Set text mode, i.e., Case of Key is ignored. Otherwise case-sensitive defaultly.
;	}
;	mypdic := pdic
;	outputdebug Dictionary created: %mypdic%
}

_SendU_Load_Dynamic_Modes()
{
; NOTE:
; d=dynamic (auto-pick mode)
; i=static (mode 1)
; a=simulates ALT+numpad sequence (mode 2)
; c=clipboard (mode 3)
;	IfExist, %A_WorkingDir%\AppList.txt
;	{
;		FileRead, Str, %A_WorkingDir%\AppList.txt
;		Loop, Parse, Str, `n, `r
;		{
;			Loop, Parse, A_LoopField, CSV
;			{
;				CSV_%A_Index% := A_LoopField
;			}
;			if ( CSV_2 == "2" )
;			{
;				_SendU_SetMode( CSV_1, "a" )
;			}
;			if ( CSV_2 == "3" )
;			{
;				_SendU_SetMode( CSV_1, "c" )
;			}
;		}
;	}
;	else
;	{
;		TempString:=GetLang(112) . "`n" . GetLang(113) . "`n" . GetLang(114) ; Warning! The file AppList.txt is missing.`nSome programs may not receive Unicode characters correctly.`nPlease reinstall InKey.
;		MsgBox, %TempString%
;	}
;	IfExist, %A_WorkingDir%\UserAppList.txt
;	{
;		FileRead, Str, %A_WorkingDir%\UserAppList.txt
;		Loop, Parse, Str, `n, `r
;		{
;			Loop, Parse, A_LoopField, CSV
;			{
;				CSV_%A_Index% := A_LoopField
;			}
;			if ( CSV_2 == "2" )
;			{
;				_SendU_SetMode( CSV_1, "a" )
;			}
;			if ( CSV_2 == "3" )
;			{
;				_SendU_SetMode( CSV_1, "c" )
;			}
;		}
;	}
}
; --------------------- other functions ----------------------------

_SendU_SetVar( var, value )
{
	global
	_SendU_%var% := value
}

_SendU_GetVar( var )
{
	global
	return _SendU_%var% . ""
}

_SendU_Default_Value( var, value )
{
	global
	if ( _SendU_%var% . "" == "" )
		_SendU_%var% := value
}

_SendU_Load_Locale()
{
;		TempString:=GetLang(62) . " $processName$`n($title$)`n" . GetLang(63) . " $modeName$ - $modeType$"
;		_SendU_Default_Value("DYNAMIC_MODE_TOOLTIP", TempString) ; Setting mode for... to...

;		TempString:=GetLang(64)  ; Method 1
;		_SendU_Default_Value("Mode_Name_i", TempString)	; SendInput
;		TempString:=GetLang(65) ; Clipboard
;		_SendU_Default_Value("Mode_Name_c", TempString)
;		TempString:=GetLang(66)  ; Method 3
;		_SendU_Default_Value("Mode_Name_r", TempString)  ; Restore Clipboard
;		TempString:=GetLang(67)  ; Method 2
;		_SendU_Default_Value("Mode_Name_a", TempString)	; Alt+Numbers
;		TempString:=GetLang(68) ; Automatic
;		_SendU_Default_Value("Mode_Name_d", TempString)  ; dynamic
;		TempString:=GetLang(69) ; Unknown
;		_SendU_Default_Value("Mode_Name_0", TempString)

;		TempString:=GetLang(70) ; the fastest mode
;		_SendU_Default_Value("Mode_Type_i", TempString)
;		TempString:=GetLang(71) ; clears the clipboard
;		_SendU_Default_Value("Mode_Type_c", TempString)
;		TempString:=GetLang(72) ; slowest, but some apps need it
;		_SendU_Default_Value("Mode_Type_r", TempString)
;		TempString:=GetLang(73) ; second best, if it works
;		_SendU_Default_Value("Mode_Type_a", TempString)
;		TempString:=GetLang(74) ; automatic mode selection
;		_SendU_Default_Value("Mode_Type_d", TempString)
;		TempString:=GetLang(75) ; unknown mode
;		_SendU_Default_Value("Mode_Type_0", TempString)
	; }
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LABELS AND INCLUDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__SendU_Labels_And_Includes__This_Is_Not_A_Function()
{
	return

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; LABELS for internal use

	_SendU_Remove_Tooltip:
		SetTimer, _SendU_Remove_Tooltip, Off
		ToolTip
	return

	_SendU_Restore_Clipboard:
		Critical
		if ( _SendU_Last_Char_In_Clipboard() == Clipboard )
			_SendU_RestoreClipboard()
		_SendU_Last_Char_In_Clipboard( "" )
		Critical, Off
	return

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; LABELS for public use

	_SendU_Try_Dynamic_Mode:
	_SendU_Change_Dynamic_Mode:
		SendU_Try_Dynamic_Mode()
	return

	_SendU_Toggle_Clipboard_Restore_Mode:
		SendU_Clipboard_Restore_Mode( 2 )
		_SendU_Dynamic_Mode_Tooltip()
	return

}

#include CoHelper.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END OF SENDU MODULE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
