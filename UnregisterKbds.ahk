if not A_IsAdmin
{	DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """", str, A_WorkingDir, int, 1)
	ExitApp
}

DeleteAllInkeyKLIDs()
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
		MsgBox 0, Unregister InKey Keyboards, Successfully unregistered %numdel% keyboard(s):`n`n%deleted%
	else
		MsgBox 0, Unregister InKey Keyboards, No InKey keyboards were found.
}