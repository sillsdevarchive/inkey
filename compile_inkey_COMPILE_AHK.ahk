;SCbin = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.bin
;SCtmp = c:\progra~1\AutoHotkey\Compiler\AutoHotkeySC.tmp
a2e = "C:\Program Files (x86)\AutoHotkeyL\Compiler\Compile_AHK.exe"
;a2e = c:\progra~1\AutoHotkey\Compiler\AHK2EXE.exe
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

Compile(base . "inkey.ahk")
; Compile(base . "indic-DEMO.ahk", base . "inkey\Indic-DEMO.exe", "", base . "Indic-RES.bin")
; Compile(base . "indic-WinScript.ahk", base . "inkey\Indic-WinScript.exe", "", base . "Indic-RES.bin")
; Compile(base . "IPA-DEMO.ahk", base . "inkey\IPA-DEMO.exe", base . "Inkey\IPA.ico")
MsgBox 4, , Run InKey now?
ifmsgbox yes
	Run %base%Inkey\inkey.exe, %base%inkey
return

Compile(in) {
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

	;if (res) {
	;	filemove %SCbin%, %SCtmp%
	;	filemove %res%, %SCbin%
	;	;msgbox errorlevel = %errorlevel%
	;}

	;msgbox RunWait %a2e% /in "%in%" /out "%out%" /icon "%ico%" /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3Mr" /NoDecompile

	; cmd = %a2e% /in "%in%" /out "%out%" /icon "%ico%"
	; fileappend %cmd%`n, %bat%
	;RunWait %a2e% /in "%in%" /out "%out%" /icon "%ico%" /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3MrpP" /NoDecompile
	;if (icon)
	;	iconstr := "/icon " . icon
	;else
	;	iconstr := ""
;	RunWait %a2e% /in "%in%" /out "%out%" %iconstr% /pass "iVRHFx0r9i6i1ri9_r7-elDkW7tef20NSX_YuXWXNGIwTz8cgAkOPMGZI_O3Mr" /NoDecompile
	sourcefile = %A_ScriptDir%\%in%
	RunWait %a2e% /auto "%sourcefile%"

	;if (res) {
	;	filemove %SCbin%, %res%
	;	filemove %SCtmp%, %SCbin%
	;}
}

