SCbin = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.bin
a2e = "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
base =

Compile(base . "InKeyKeyboardInstaller.ahk", base . "inkeyLive\InKeyKeyboardInstaller.exe", base . "inkey.ico")
MsgBox done
return

Compile(in, out, icon) {
	global
	if (icon)
		iconstr := "/icon " . icon
	else
		iconstr := ""
	RunWait %a2e% /in "%in%" /out "%out%" /bin %SCbin% /mpress 1 %iconstr%
}

