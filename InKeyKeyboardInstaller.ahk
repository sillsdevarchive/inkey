;@Ahk2Exe-SetVersion 2.000
;@Ahk2Exe-SetName InKey Keyboard Installer
;@Ahk2Exe-SetDescription InKey Keyboard Installer
;@Ahk2Exe-SetCopyright Copyright (c) 2018-2015`, InKey Software
;@Ahk2Exe-SetCompanyName InKey Software
;@Ahk2Exe-SetMainIcon InKey.ico

#notrayicon

SetWorkingDir %A_ScriptDir%

; Find the appropriate InKey.ini
InKeyINI := (FileExist("StoreUserSettingsInAppData.txt") and FileExist(A_AppData . "\InKeySoftware\InKey.ini"))
			? A_AppData . "\InKeySoftware\InKey.ini" : "InKey.ini"

; Read the GUILang code
IniRead GUILang, %InKeyINI%, InKey, GUILang, en

; Restart as Admin if we don't have permission to write to InKey folder
FileAppend ., InstallLog.txt
if (ErrorLevel) {
	if (A_IsAdmin) {
		MsgBox Unable to write to InKey folder: %A_ScriptDir%
		exitApp 2
	} else {
		if %0% = 0
			RunWait *RunAs "%A_ScriptFullPath%"
		else
			RunWait *RunAs "%A_ScriptFullPath%" "%1%"
		ExitApp %ErrorLevel%
	}
}

if %0% = 0
{
	ZipPathFile := GetFileName()
}
else
{
	ZipPathFile = %1%
}
noKill := 0
if (ZipPathFile = "/noKill") {
	noKill := 1
	ZipPathFile := GetFileName()
}

; outputdebug %A_ScriptFullPath% %ZipPathFile%

KeyboardName := ZipPathFile

StringReplace, KeyboardName, KeyboardName, `",, All ; remove "s
StringReplace, KeyboardName, KeyboardName, .zip ; remove .zip at end
StringReplace, KeyboardName, KeyboardName, .inkey ; remove .inkey at end
StringGetPos, pos, KeyboardName, \, R ; find position of last \
length := StrLen(KeyboardName)
StringRight, KeyboardFolder, KeyboardName, % length-pos-1 ; get foldername%

IfExist, %KeyboardFolder%
{
	WelcomeMessage := GetLang(96) . " " . KeyboardFolder ; Do you want to update this keyboard?
}
else
{
	WelcomeMessage := GetLang(97) . " " . KeyboardFolder ; Do you want to install this keyboard?
}
WelcomeMessage .= chr(13) chr(10) "=> " A_ScriptDir

TitleString:=GetLang(98) ; InKey Keyboard Installer
MsgBox, 8244, %TitleString%, %WelcomeMessage%
IfMsgBox Yes
{
	errorcheck:=installorupdatefromzip(ZipPathFile)
	if errorcheck<>0
		outputdebug Error encountered during keyboard install/update: %errorcheck%
	if errorcheck = 0
	{
		TempString:=GetLang(99) ; Installation complete.
		MsgBox,, %TitleString%, %TempString%
		if (noKill)
			exitApp 0

		; if InKey is currently running then need to reload InKey
		SetTitleMatchMode Regex
		DetectHiddenWindows On
		ifwinexist i)inkey.exe ahk_class AutoHotkey
		{
			PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
			PostMessage, 0x112, 0xF060  ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
			WinClose i)inkey.exe ahk_class AutoHotkey
			WinWaitClose i)inkey.exe ahk_class AutoHotkey
			ifwinexist i)inkey.exe ahk_class AutoHotkey
				msgbox There was a problem with restarting InKey.
			else
				Run inkey.exe
		}
	}
	exitApp %errorcheck%
}
else
{
	exitApp 3
}

installorupdatefromzip(ZipPathFile) {
	local errorcheck
	local NewLang
	local Pos
	local TempString

	errorcheck = 0
	updatingkeyboard = false

	; set temporary unzip folder
	Random ExtractDir
	ExtractDir := A_Temp . "\inkeyUnpack" . ExtractDir . ".tmp"
	; delete temporary folder (if it exists)
	SetWorkingDir, %A_Temp%
	IfExist, Unzip
		FileRemoveDir, Unzip, 1

	SetWorkingDir, %A_ScriptDir%

	ExternalZipPathFile := Chr(34) . ZipPathFile . Chr(34)
	ExternalExtractDir := Chr(34) . ExtractDir . Chr(34)

	IfNotExist, 7za.exe
	{
		TempString:=GetLang(101)
		MsgBox, %TempString%  ; File missing in InKey folder. Please reinstall InKey.
		errorcheck = 1
		return errorcheck
	}

	RunWait, 7za.exe x -y -o%ExternalExtractDir% %ExternalZipPathFile%,,hide

	; outputdebug ExtractDir = %ExtractDir%
	Loop Files, %ExtractDir%\*.*, D
	{
		KeyboardDir := ExtractDir . "\" . A_LoopFile
		DestinationDir := A_ScriptDir . "\" . A_LoopFile
		outputdebug FileCopyDir, %KeyboardDir%, %DestinationDir%, 1
		FileCopyDir, %KeyboardDir%, %DestinationDir%, 1
		If ErrorLevel
		{
			TempString:=GetLang(104)
			MsgBox %TempString% ; There was a problem with copying files to the InKey folder!
			; delete temp folder
			SetWorkingDir, %A_Temp%
			; FileRemoveDir, ExtractDir, 1
			SetWorkingDir, %A_ScriptDir%
			errorcheck = 5
			return errorcheck
		}
	}

	; delete temp folder
	SetWorkingDir, %A_Temp%
	; FileRemoveDir, ExtractDir, 1
	SetWorkingDir, %A_ScriptDir%


	return errorcheck
}

GetFileName() {
	TitleString:=GetLang(94)  ; Select a keyboard file...
	TempString:=GetLang(95) . " (*.inkey; *.zip)" ; Keyboard files (*.inkey; *.zip)
	FileSelectFile, ZipPathFile, 3,, %TitleString%, %TempString%
	If ErrorLevel
		ExitApp 1
	return ZipPathFile
}

#include Lang.ahk ; Internationalisation routines