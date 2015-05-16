SCbin = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.bin
a2e = "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
base =

; Kill InKey.exe
SetTitleMatchMode Regex
DetectHiddenWindows On
ifwinexist i)inkey.exe ahk_class AutoHotkey
{
	PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
	PostMessage, 0x112, 0xF060  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
}
WinClose i)inkey.exe ahk_class AutoHotkey
WinWaitClose i)inkey.exe ahk_class AutoHotkey
ifwinexist i)inkey.exe ahk_class AutoHotkey
	msgbox still there

Compile(base . "inkey.ahk", base . "inkeyLive\InKey.exe", base . "inkey.ico")
FileCopy %base%InKeyLib.ahki, %base%InkeyLive, 1
FileCopy %base%InKey License.ahki, %base%InkeyLive, 1
FileCopy %base%InKey.ini, %base%InkeyLive, 1

MsgBox 4, , Run InKey now?
ifmsgbox yes
	Run %base%InkeyLive\inkey.exe, %base%inkey
return

Compile(in, out, icon) {
	global
	if (icon)
		iconstr := "/icon " . icon
	else
		iconstr := ""
	RunWait %a2e% /in "%in%" /out "%out%" /bin %SCbin% /mpress 1 %iconstr%
}

