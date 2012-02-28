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
	privData = mDZKlngA-6groZzg64lqKKeSTXWOKKaCMghVI3CSDei88UJmK60tm86ZRG2tRkghFOjyLLkmu2W9KRdldiBNGQGLTDuNZlqP54B4JNSwXbKjRd4gLQ9EiQ6Zc1WyU-EJ

	; First, do some basic checks on the MD5.exe file
	FileGetSize md5size, %md5%
	if (md5size <> 49152)
	{
		ErrorString:=GetLang(105) ; Validation Error
		TempString:=GetLang(106)
		msgbox 16, %ErrorString%, %TempString%  ; Unable to validate (Error #V1). Try reinstalling InKey.
		return 1
	}

	; ensure that we have access to a genuine MD5 utility, that the user has not tried to swap out the MD5 to hack the protection off
	if getMD5Hash(md5, privData) <> "C9C7160137140648F7021E61EBE8C1A0"
	{
		ErrorString:=GetLang(105) ; Validation Error
		TempString:=GetLang(107)
		msgbox 16, %ErrorString%, %TempString%  ; Unable to validate (Error #V2). Please report this error to the InKey developers.
		return 1
	}

	; Now read the InKey license file
	IniRead LicenseStmt, RegistrationKey.txt, InKey, LicenseStmt, %A_Space%
	IniRead Expiry, RegistrationKey.txt, InKey, Expiry, %A_Space%
	IniRead Key, RegistrationKey.txt, InKey, Key, %A_Space%

	; Ensure the file was found
	if (not LicenseStmt)
	{
		ErrorString:=GetLang(105) ; Validation Error
		TempString:=GetLang(108)
		msgbox 16, %ErrorString%, %TempString%  ; The InKey license file (RegistrationKey.txt) is missing or incomplete.
		return 1
	}

	; Check that it has not been tampered with.
	if getMD5Hash(md5, mangle(LicenseStmt . Expiry, privData)) <> Key
	{
		ErrorString:=GetLang(105) ; Validation Error
		TempString:=GetLang(109)
		msgbox 16, %ErrorString%, %TempString%  ; Error (#V3) with InKey license file.  Please report this error to the InKey developers.
		return 1
	}

	; Check that license is not expired
	Expiry .= "000000"
	if (Expiry < A_Now)
	{
		ErrorString:=GetLang(110) ; License Expired
		TempString:=GetLang(111)
		MsgBox 16, %ErrorString%, %TempString% ; Your InKey license has expired.
		return 1
	}

	splashTxt := RegExReplace(LicenseStmt, "\|", chr(10))
	jpg = %A_Temp%\splash.png
	FileInstall splash.png, %jpg%, 1

	Gui, Color, 000001
	Gui +LastFound  ; Make the GUI window the last found window for use by the line below.
	WinSet, TransColor, 000001
	Gui, +AlwaysOnTop  +Owner -Caption ; +Owner avoids a taskbar button.
	Gui, Add, picture, x0 yo w302 h268 gCancel, %jpg%
	Gui, Add, Text, x0 y120 w302 h30 gCancel cWhite backgroundtrans +Center, Version %ver%
	Gui, Add, Text, x50 y150 w200 h80 hwndLicHwnd cWhite gCancel backgroundtrans +Center
	copyright := chr(169)  ; necessary because this script is saved in utf8 format
	spacer := chr(32)+chr(32)
	Gui, Add, Text, x25 y230 w130 h40 backgroundtrans cWhite gCancel, %spacer% %copyright% 2008-2011`nInKey Software
	Gui, Font, underline,
	Gui, Add, Text, x150 y240 w140 h20 cBlue backgroundtrans gLaunchURL +Center, www.InKeySoftware.com
	Gui, Font, norm,

	IniRead NoSplash, InKey.ini, InKey, NoSplash, 0
	If (Not NoSplash)
	{
		Gui, Show, NoActivate ; NoActivate avoids deactivating the currently active window.
	}

	splashTxt .= " " ; something eats last char
	UTF8ToWide(wideTxt, splashTxt)
	DllCall("SendMessageW", "UInt", LicHwnd,  "UInt", 0x0C, "UInt", 0, "Uint", &wideTxt)  ; 0x0C = WM_SETTEXT
	return 0
}

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
