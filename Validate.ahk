; InKey code relating to validation and the splash screen (GUI 1)

LaunchURL:
gui hide
run http://www.InKeySoftware.com, , UseErrorLevel
return

validate() {
	md5 = %A_Temp%\ik83nc6g.exe
	FileInstall md5.exe, %md5%, 1

	errs := DoValidationChecks(md5)
	FileDelete %md5%
	if errs
		ExitApp
}

DoValidationChecks(byref md5) {
	global ver
	;~ privData = mDZKlngA-6groZzg64lqKKeSTXWOKKaCMghVI3CSDei88UJmK60tm86ZRG2tRkghFOjyLLkmu2W9KRdldiBNGQGLTDuNZlqP54B4JNSwXbKjRd4gLQ9EiQ6Zc1WyU-EJ

	;~ ; First, do some basic checks on the MD5.exe file
	;~ FileGetSize md5size, %md5%
	;~ if (md5size <> 49152)
	;~ {
		;~ ErrorString:=GetLang(105) ; Validation Error
		;~ TempString:=GetLang(106)
		;~ msgbox 16, %ErrorString%, %TempString%  ; Unable to validate (Error #V1). Try reinstalling InKey.
		;~ return 1
	;~ }

	; ensure that we have access to a genuine MD5 utility, that the user has not tried to swap out the MD5 to hack the protection off
	;~ if getMD5Hash(md5, privData) <> "C9C7160137140648F7021E61EBE8C1A0"
	;~ {
		;~ ErrorString:=GetLang(105) ; Validation Error
		;~ TempString:=GetLang(107)
		;~ msgbox 16, %ErrorString%, %TempString%  ; Unable to validate (Error #V2). Please report this error to the InKey developers.
		;~ return 1
	;~ }

	; Now read the InKey license file
	LicenseStmt:=GetLang(150)
	;~ IniRead LicenseStmt, RegistrationKey.txt, InKey, LicenseStmt, %A_Space%
	;~ IniRead Expiry, RegistrationKey.txt, InKey, Expiry, %A_Space%
	;~ IniRead tmpKey, RegistrationKey.txt, InKey, Key, %A_Space%

	;~ ; Ensure the file was found
	;~ if (not LicenseStmt)
	;~ {
		;~ ErrorString:=GetLang(105) ; Validation Error
		;~ TempString:=GetLang(108)
		;~ msgbox 16, %ErrorString%, %TempString%  ; The InKey license file (RegistrationKey.txt) is missing or incomplete.
		;~ return 1
	;~ }

	;~ ; Check that it has not been tampered with.
	;~ if getMD5Hash(md5, mangle(LicenseStmt . Expiry, privData)) <> tmpKey
	;~ {
		;~ ErrorString:=GetLang(105) ; Validation Error
		;~ TempString:=GetLang(109)
		;~ msgbox 16, %ErrorString%, %TempString%  ; Error (#V3) with InKey license file.  Please report this error to the InKey developers.
		;~ return 1
	;~ }

	;~ ; Check that license is not expired
	;~ Expiry .= "000000"
	;~ if (Expiry < A_Now)
	;~ {
		;~ ErrorString:=GetLang(110) ; License Expired
		;~ TempString:=GetLang(111)
		;~ MsgBox 16, %ErrorString%, %TempString% ; Your InKey license has expired.
		;~ return 1
	;~ }

	; TODO:  Should we use SplashImage instead??  Will that handle transparency better? Or is that simpler but less control?
	splashTxt := RegExReplace(LicenseStmt, "\|", chr(10))
	jpg = %A_Temp%\splash.png
	FileInstall splash.png, %jpg%, 1

	Gui, Color, 000001
	Gui +LastFound  ; Make the GUI window the last found window for use by the line below.
	WinSet, TransColor, 000001
	Gui, +AlwaysOnTop  +Owner -Caption ; +Owner avoids a taskbar button.
	Gui, Add, picture, x0 yo w302 h268 gCancel, %jpg%
	Gui, Add, Text, x0 y120 w302 h30 gCancel cWhite backgroundtrans +Center, Version %ver%
	Gui, Add, Text, x50 y150 w200 h80 cWhite gCancel backgroundtrans +Center, %splashTxt%
	;~ Gui, Add, Text, x50 y150 w200 h80 hwndLicHwnd cWhite gCancel backgroundtrans +Center
	;~ copyright := chr(169)  ; necessary because this script is saved in utf8 format
	;~ spacer := chr(32)+chr(32)
	;~ Gui, Add, Text, x25 y230 w130 h40 backgroundtrans cWhite gCancel, %spacer% %copyright% 2008-2012`nInKey Software
	Gui, Add, Text, x25 y230 w130 h40 backgroundtrans cWhite gCancel,   © 2008-2012`nInKey Software
	Gui, Font, underline,
	Gui, Add, Text, x150 y240 w140 h20 cBlue backgroundtrans gLaunchURL +Center, www.InKeySoftware.com
	Gui, Font, norm,

	global NoSplash
	IniRead NoSplash, InKey.ini, InKey, NoSplash, 0
	If (Not NoSplash)
	{
		Gui, Show, NoActivate ; NoActivate avoids deactivating the currently active window.
	}

	;~ splashTxt .= " " ; something eats last char
	;~ UTF8ToWideOnly(wideTxt, splashTxt)
	;~ DllCall("SendMessageW", "UInt", LicHwnd,  "UInt", 0x0C, "UInt", 0, "Uint", &wideTxt)  ; 0x0C = WM_SETTEXT
	;~ DllCall("SendMessageW", "UInt", LicHwnd,  "UInt", 0x0C, "UInt", 0, "Uint", &splashTxt)  ; 0x0C = WM_SETTEXT
	return 0
}

/*
mangle(srcStr, ByRef privData) {
	slen := strlen(srcStr)
	dlen := strlen(privData)
	ostr =
	ii = 1
	Loop %slen%
	{
		ostr := ostr . Chr(Asc(substr(srcStr,A_Index,1)) ^ Asc(substr(privData,ii,1)))
		ii++
		if (ii>dlen)
			ii = 1
	}
	return ostr
}

getMD5Hash(ByRef md5, srcStr) {
	; outputdebug getmd5hash(%md5%, %srcStr%)
	InFilename = %A_Temp%\~bdsms10gle8ayyi1.tmp
	OutFilename = %A_Temp%\~bdsms10gle8ayyi2.tmp
	FileDelete %InFilename%
	FileAppend %srcStr%, %InFilename%
	RunWait, %comspec% /c ""%md5%" "%InFilename%" >"%OutFilename%"", , min
	FileDelete, %InFilename%
	FileReadLine, hash, %OutFilename%, 1
	FileDelete, %OutFilename%
	; outputdebug files: %infilename%, %outfilename%
	; outputdebug md5 returned: %hash%
	return substr(hash,1,32)
}



; TO DO: LAST CHARACTER OF INPUT STRING GETS LOST!!!
; PROBABLY SHOULD REWRITE ANYWAY TO USE: DllCall("MultiByteToWideChar", UInt,65001, UInt,0, Str,utf8, Int,-1, UInt,&U, Int,256)

; Decode a UTF8 string, copying the resultant character values into an array of
; 16-bit values.  This array is null-terminated.

UTF8ToWideOnly(ByRef buf, ByRef u8) {
	sl := strlen(u8)
	if sl = 0
		return 0
	ct = 0
	varSetCapacity(buf, sl * 2 + 2, 0)
	i = 1
	Loop
	{
		b1 := asc(substr(u8,i,1))
		if b1 < 128
		{	; Lower ANSI character "encoded" in a single byte
			v := b1
			i += 1
		} else {
			b2 := asc(substr(u8,i+1,1))
			if b1 & 0xE0 = 0xC0
			{ ; two byte encoding
				v := ((b1 & 0x1f) << 6) | (b2 & 0x3f)
				i += 2
			} else {
				b3 := asc(substr(u8,i+2,1))
				if b1 & 0xf0 = 0xe0
				{ ; three-byte encoding
					v := ((b1 & 0x0f) << 12) + ((b2 & 0x3f) << 6) + (b3 & 0x3f)
					i += 3
				} else {
				 ; four-byte encoding
					b4 := asc(substr(u8,i+3,1))
					v := ((b1 & 0x7) << 18) | ((b2 & 0x3f) << 6) | ((b3 & 0x3f) << 6) | (b4 & 0x3f)
					i += 4
				}
			}
		}
		numPut(v, buf, 2*ct++)
		if (i >= sl)
			break
	}
	return ct
}

*/