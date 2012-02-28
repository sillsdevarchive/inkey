SCbin = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.bin
SCtmp = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.tmp
a2e = "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe"
;a2e = c:\progra~1\AutoHotkey\Compiler\AHK2EXE.exe
base =

Compile(base . "InKeyKeyboardInstaller.ahk", base . "inkey\InKeyKeyboardInstaller.exe", base . "inkey.ico")
return

Compile(in, out, icon, res="") {
	global
	; FileGetTime inTime, %in%
	; outputdebug infile  %intime%: %in%
	; if (FileExist(out)) {
		; FileGetTime outTime, %out%
		; outputdebug outfile %outtime%: %out%
		; if (%intime% < %outtime%) {
			; return
		; }
	; }
	; outputdebug need to compile

	if (res) {
		filemove %SCbin%, %SCtmp%
		filemove %res%, %SCbin%
		;msgbox errorlevel = %errorlevel%
	}

	;msgbox RunWait %a2e% /in "%in%" /out "%out%" /icon "%ico%" /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3Mr" /NoDecompile

	; cmd = %a2e% /in "%in%" /out "%out%" /icon "%ico%"
	; fileappend %cmd%`n, %bat%
	;RunWait %a2e% /in "%in%" /out "%out%" /icon "%ico%" /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3MrpP" /NoDecompile
	if (icon)
		iconstr := "/icon " . icon
	else
		iconstr := ""
;	RunWait %a2e% /in "%in%" /out "%out%" %iconstr% /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3Mr" /NoDecompile
	RunWait %a2e% /in "%in%" /out "%out%" %iconstr%


	if (res) {
		filemove %SCbin%, %res%
		filemove %SCtmp%, %SCbin%
	}
}

