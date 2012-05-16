/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\InKey\InKeyKeyboardInstaller.exe
Alt_Bin=C:\Program Files\AutoHotkey\Compiler\AutoHotkeySC.bin
No_UPX=1
Execution_Level=2
[VERSION]
Set_Version_Info=1
Company_Name=InKeySoftware
File_Description=InKey Keyboard Installer
File_Version=0.105.0.0
Inc_File_Version=0
Internal_Name=inkeykeyboardinstaller
Legal_Copyright=(c) 2008-2012 InKeySoftware
Original_Filename=InKeyKeyboardInstaller.ahk
Product_Name=InKey Keyboard Installer
Product_Version=1.0.96.0
[ICONS]
Icon_1=%In_Dir%\inkey.ico

* * * Compile_AHK SETTINGS END * * *
*/

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