;@Ahk2Exe-SetVersion 2.000
;@Ahk2Exe-SetName InKey Keyboard Installer
;@Ahk2Exe-SetDescription InKey Keyboard Installer
;@Ahk2Exe-SetCopyright Copyright (c) 2018-2015`, InKey Software
;@Ahk2Exe-SetCompanyName InKey Software
;@Ahk2Exe-SetMainIcon InKey.ico

#singleinstance force
#notrayicon

SetWorkingDir %A_ScriptDir%

if %0% = 0
{
	TitleString:=GetLang(94)  ; Select a keyboard file...
	TempString:=GetLang(95) . " (*.inkey; *.zip)" ; Keyboard files (*.inkey; *.zip)
	FileSelectFile, ZipPathFile, 3,, %TitleString%, %TempString%
	If ErrorLevel
		exit
}
else
{
	ZipPathFile = %1%
}
; outputdebug %A_ScriptFullPath% %ZipPathFile%

FileAppend %ZipPathFile%`n, InstallLog.txt
if (ErrorLevel) {
	if (A_IsAdmin) {
		MsgBox Unable to write to InKey folder: %A_ScriptDir%
		exitApp
	} else {
		Run *RunAs "%A_ScriptFullPath%" "%ZipPathFile%"
		ExitApp
	}
}

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
		exit
	}
	else
	{
		exit
	}

#include InstallOrUpdateKeyboard.ahk
#include Lang.ahk ; Internationalisation routines