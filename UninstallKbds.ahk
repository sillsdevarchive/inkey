if not A_IsAdmin
{
	RunWait *RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
	ExitApp
}

SetWorkingDir %A_ScriptDir%

; if InKey is currently running then need to close it
SetTitleMatchMode Regex
DetectHiddenWindows On
ifwinexist i)inkey.exe ahk_class AutoHotkey
{
	PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
	PostMessage, 0x112, 0xF060  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
	WinClose i)inkey.exe ahk_class AutoHotkey
	WinWaitClose i)inkey.exe ahk_class AutoHotkey
	ifwinexist i)inkey.exe ahk_class AutoHotkey
		msgbox There was a problem with exiting InKey.`nPlease exit InKey before proceeding.
}

DeleteAllInkeyKLIDs()

; Delete all keyboard folders
MsgBox 4, Uninstall Keyboards, Delete keyboard folders from %A_ScriptDir%?
IfMsgBox Yes
{
	Loop *.*, 2
	{
		isKbd := 0
		Loop %A_LoopFileName%\*.kbd.ini, 1
		{
			isKbd := 1
		}
		if (isKbd) {
			FileRemoveDir %A_LoopfileName%, 1
		}
	}
}

; Delete user settings
MsgBox 4, Uninstall Keyboards, Delete settings you have customized for your keyboards?
IfMsgBox Yes
{
	FileRemoveDir % A_AppData . "\InKeySoftware", 1
}

; Remove Cached files
InKeyCacheDir = %A_Temp%\InkeyCache
FileRemoveDir %InKeyCacheDir%
return

DeleteAllInkeyKLIDs() {
	; Loop backwards through the Keyboard Layout KLIDs, deleting the InKey keyboards
	numdel := 0
	deleted := ""
	Loop HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts, 2 ; 2=retrieve subkeys (not values)
	{	if (SubStr(A_LoopRegName, 1, 4) = "0000")	; Stop when we reach the 0000nnnn entries.
			break
		RegRead InKeyVal, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, InKey ; See if it has an "InKey" value
		if (InKeyVal) {
			RegRead ltext, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout Text
			numdel++
			deleted .= chr(9) . ltext . chr(10)
			RegDelete HKLM, %A_LoopRegSubKey%\%A_LoopRegName%
		}
	}
	if (numdel)
		MsgBox 0, Uninstall InKey Keyboards, Successfully removed %numdel% keyboard(s) from the registry:`n`n%deleted%
	else
		MsgBox 0, Uninstall InKey Keyboards, No InKey keyboards were found in the registry.
}