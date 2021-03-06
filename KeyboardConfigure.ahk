; Keyboard Configuration GUI
; Version 1.0  6 November 2008

ConfigureKeyboard(kbd)
{
	global currentconfigurekbd

	if (currentconfigurekbd = kbd)
	{
		Gui, 5:Show
		return
	}

	if (currentconfigurekbd <> -1)
	{
		tmpString:=GetLang(115)
		MsgBox %tmpString%  ; You can only have one keyboard configuration window open at a time.  Sorry!
		return
	}

	currentconfigurekbd:=kbd

	SetWorkingDir %A_ScriptDir%

	gosub InitLocales

	tmpString:=GetLang(76)
	Gui, 5:Add, Text, x10 y5 w80 h40, %tmpString%  ; Layout Name:
	Gui, 5:Add, Edit, x100 y8 w150 h20 vLayoutNameGUI, % KBD_LayoutName%kbd%
	tmpString:=GetLang(77)
	Gui, 5:Add, Text, x10 y45 w80 h40, %tmpString%  ; Menu Text:
	Gui, 5:Add, Edit, x100 y48 w150 h20 vMenuText, % KBD_MenuText%kbd%
	tmpString:="(&& " . GetLang(78) . ")"
	Gui, 5:Add, Text, x270 y45 w160 h40, %tmpString%  ; (&& precedes shortcut key)
	tmpString:=GetLang(79)
	Gui, 5:Add, Text, x10 y85 w80 h40, %tmpString%  ; Hotkey:
	Gui, 5:Add, Edit, x100 y88 w150 h20 vHotkey, % KBD_Hotkey%kbd%
	Gui, 5:Add, Text, x270 y85 w160 h20, ^=CTRL, #=WIN, +=SHIFT
	Gui, 5:Add, Text, x320 y98 h20, !=ALT
	tmpString:=GetLang(80)
	Gui, 5:Add, Text, x10 y125 w80 h40, %tmpString%  ; Locale:

	; need to read the locale in case it is not supported by the current Windows version
	IniRead, IniKbdLang, % KBD_IniFile%kbd%, Keyboard, Lang, %A_Space%

	; Convert language code to language name
	tmpLangName1:=ConvertCodeToName(IniKbdLang)
	global LangNameGUI
	Gui, 5:Add, Edit, x100 y128 w150 h20 ReadOnly vLangNameGUI, %tmpLangName1%
	tmpString:=GetLang(81)
	Gui, 5:Add, Button, x270 y128 w140 h20 g5ChangeLocaleButton, %tmpString%  ; Change...

	global AltLangGUI
	global ChangeAltLocaleButton
	global AltLangName
	If KBD_AltLang%kbd% <>
	{
		AltLangName:=ConvertCodeToName(KBD_AltLang%kbd%)
		tmpString:=GetLang(82)
		Gui, 5:Add, Text, x10 y165 w80 h40, %tmpString%  ; Alt. Locale:
		Gui, 5:Add, Edit, x100 y168 w150 h20 ReadOnly vAltLangGUI, %AltLangName%
		tmpString:=GetLang(81)
		Gui, 5:Add, Button, x270 y168 w140 h20 vChangeAltLocaleButton g5ChangeAltLocaleButton, %tmpString%  ; Change...
	}
	else
	{
		tmpString:=GetLang(82)
		Gui, 5:Add, Text, x10 y165 w80 h40, %tmpString%  ; Alt. Locale:
		Gui, 5:Add, Edit, x100 y168 w150 h20 ReadOnly disabled1 vAltLangGUI,
		tmpString:=GetLang(81)
		Gui, 5:Add, Button, x270 y168 w140 h20 disabled1 vChangeAltLocaleButton g5ChangeAltLocaleButton, %tmpString%  ; Change...
	}

	tmpString:=GetLang(83)
	Gui, 5:Add, Text, x10 y205 w80 h40, %tmpString%  ; Icon:

	global IconPicGUI
	Gui, 5:Add, Picture, x70 y207 w20 h20 Border vIconPicGUI, % KbdIconFile%kbd%

	Icon := % KbdIconFile%kbd%
	StringGetPos, tmpPos1, Icon, \, R
	StringRight, Icon, Icon, StrLen(Icon) - tmpPos1 -1
	global IconGUI
	Gui, 5:Add, Edit, x100 y208 w150 h20 ReadOnly vIconGUI, %Icon%
	tmpString:=GetLang(81)
	Gui, 5:Add, Button, x270 y208 w140 h20 g5ChangeIconButton, %tmpString%  ; Change...

	keybdname :=% KBD_LayoutName%kbd%
	; global KBD_AhkFile%kbd%
	global currOptionsFile, configKbdBtnTxt
	currOptionsFile := KBD_CacheStem%kbd% . ".options"
	outputdebug currOptionsFile = %currOptionsFile%
	If (KBD_ConfigureGUI%kbd% or FileExist(currOptionsFile))
	{
		global ConfigGUI

		tmpString:=GetLang(87)
		StringLeft, TempChar, tmpString, 1
		if (TempChar <> "-")
		{
			tmpString:=" " . tmpString
		}
		configKbdBtnTxt:=GetLang(86) . " " . keybdname . tmpString . "..."  ; Configure %keybdname%-specific settings...
		;outputdebug configKbdBtnTxt = %configKbdBtnTxt%
		Gui, 5:Add, Button, x10 y250 w400 h25 g5ButtonRun, %configKbdBtnTxt%
	}

	LayoutFile := % KBD_DisplayCmd%kbd%
	If ((LayoutFile = "") or (LayoutFile = " "))
	{
		; do nothing
	}
	else
	{
		;StringGetPos, position, LayoutFile, \, R
		;StringRight, LayoutFile, LayoutFile, StrLen(LayoutFile) - position -1
		;Gui, 5:Add, Text, x10 y190 w80 h20, Layout File:
		;global DisplayCmd
		;Gui, 5:Add, Edit, x100 y188 w150 h20 ReadOnly vDisplayCmd, %LayoutFile%
		;Gui, 5:Add, Button, x270 y188 w140 h20, View...

		buttontext:=GetLang(84) . " " . keybdname . " " . GetLang(85) . "..." ; View %keybdname% keyboard layout...
		If (KBD_ConfigureGUI%kbd% or FileExist(currOptionsFile))
		{
			Gui, 5:Add, Button, x10 y+15 w400 h25 g5ButtonView, %buttontext%
		}
		else
		{
			Gui, 5:Add, Button, x10 y250 w400 h25 g5ButtonView, %buttontext%
		}
	}
	Gui, 5:Add, Button, x10 y+15 w400 h25 g5ButtonOpenIni, Open user configuration file ; TODO: add to lang file, and get translations
	tmpString:=GetLang(12)
	Gui, 5:Add, Button, x130 yp+50 w80 h25 g5ButtonOK, %tmpString%  ; OK
	tmpString:=GetLang(13)
	Gui, 5:Add, Button, x240 yp w80 h25 g5ButtonCancel, %tmpString%  ; Cancel
	tmpString:=keybdname . " " . GetLang(88)
	Gui, 5:Show, xCenter yCenter w430, %tmpString%  ; Configuration Options
	return
}

5ChangeLocaleButton:
Gui, 6:+Owner1
Gui 5:+Disabled
TempString:=GetLang(89)
Gui, 6:Add, Text, x10 y10 w160 h40, %TempString%  ; New Locale:
Gui, 6:Add, DropDownList, x180 y10 w200 vNewLocale, %LocaleList%
TempString:=GetLang(12)
Gui, 6:Add, Button, x80 y50 w100 h25 g6ButtonOK, %TempString%  ; OK
TempString:=GetLang(13)
Gui, 6:Add, Button, x220 yp w100 h25 g6ButtonCancel, %TempString%  ; Cancel
TempString:=GetLang(90)
Gui, 6:Show, Center, %TempString%  ; Change Locale...
return

6ButtonCancel:
6GuiClose:
NewLocale=
Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui, 6:Destroy
return

6ButtonOK:
Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui, 6:Submit
Gui, 6:Destroy
tmpLangName:=NewLocale
GuiControl, 5:, LangNameGUI, %NewLocale%
tmpPos:=InStr(AltLocaleList, tmpLangName)
If tmpPos=0
{
	GuiControl, 5:Enable, AltLangGUI
	GuiControl, 5:Enable, ChangeAltLocaleButton
	TempString:=GetLang(75)
	msgbox, %TempString% ; You need to choose an alternate locale as well.
}
else
{
	GuiControl, 5:, AltLangGUI, ; blank contents of alt lang since it is no longer required
	GuiControl, 5:Disable, AltLangGUI
	GuiControl, 5:Disable, ChangeAltLocaleButton
}
return

5ChangeAltLocaleButton:
Gui, 7:+Owner1
Gui, 5:+Disabled
TempString:=GetLang(91)
Gui, 7:Add, Text, x10 y10 w160 h40, %TempString%  ; New Alt. Locale:
Gui, 7:Add, DropDownList, x180 y10 w200 vNewAltLocale, %AltLocaleList%
TempString:=GetLang(12)
Gui, 7:Add, Button, x80 y50 w100 h25 g7ButtonOK, %TempString%  ; OK
TempString:=GetLang(13)
Gui, 7:Add, Button, x220 yp w100 h25 g7ButtonCancel, %TempString%  ; Cancel
TempString:=GetLang(92)
Gui, 7:Show, Center, %TempString%  ; Change Alt. Locale...
return

7ButtonCancel:
7GuiClose:
NewAltLocale=
Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui, 7:Destroy
return

7ButtonOK:
Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
Gui, 7:Submit
Gui, 7:Destroy
AltLangName:=NewAltLocale
GuiControl, 5:, AltLangGUI, %NewAltLocale%
return

5ChangeIconButton:
OldDirectory:=A_WorkingDir . "\" . KBD_Folder%currentconfigurekbd%
TempString:=GetLang(93)  ; Select an icon file...
FileSelectFile, NewIconFile, 3, %OldDirectory%, %TempString%, Icon files (*.ico)
If NewIconFile<>
{
	GuiControl, 5:, IconGUI, %NewIconFile%
	GuiControl, 5:Focus, IconGUI
	Send {End}
	GuiControl, 5:, IconPicGUI, %NewIconFile%
}
return

5ButtonView:
RunDisplayCmd := GetAHKCmd(KBD_DisplayCmd%currentconfigurekbd%) . KBD_DisplayCmd%currentconfigurekbd%
Run %RunDisplayCmd%
return

5ButtonOpenIni:
RunDisplayCmd := "notepad """ KBD_IniFile%currentconfigurekbd% """"
Run %RunDisplayCmd%
return

5ButtonRun:
Gui, 5:+Disabled
if (FileExist(currOptionsFile)) {
	Gosub DoKbdOptions
} else {
	RunGUIFilename:= GetAHKCmd(KBD_ConfigureGUI%currentconfigurekbd%) . KBD_Folder%currentconfigurekbd% . "\" . KBD_ConfigureGUI%currentconfigurekbd%
	RunWait %RunGUIFilename%
}
Gui, 5:-Disabled
Gui, 5:Show
return

5GuiClose:
5ButtonCancel:
currentconfigurekbd=-1
Gui, 5:Destroy
return

5ButtonOK:
Gui, 5:Submit
GuiControlGet, CheckEnabled, 5:Enabled, AltLangGUI
Gui, 5:Destroy

; write out standard .kbd.ini entries
IniWrite, %LayoutNameGUI%, % KBD_IniFile%currentconfigurekbd%, Keyboard, LayoutName
IniWrite, %MenuText%, % KBD_IniFile%currentconfigurekbd%, Keyboard, MenuText
IniWrite, %Hotkey%, % KBD_IniFile%currentconfigurekbd%, Keyboard, Hotkey
NewLang:=ConvertNameToCode(LangNameGUI)
IniWrite, %NewLang%, % KBD_IniFile%currentconfigurekbd%, Keyboard, Lang
If (CheckEnabled)
{
	AltLang:=ConvertNameToCode(AltLangGUI)
	IniWrite, %AltLang%, % KBD_IniFile%currentconfigurekbd%, Keyboard, AltLang
}
else
	IniDelete, % KBD_IniFile%currentconfigurekbd%, Keyboard, AltLang

; need to copy files to keyboard folder, and change path info for filenames
FileCopy, %IconGUI%, % KBD_Folder%currentconfigurekbd%, 1
StringGetPos, tmpPos, IconGUI, \, R
if Errorlevel=0
	StringRight, IconGUIshort, IconGUI, StrLen(IconGUI) - tmpPos -1
else
	IconGUIShort:=IconGUI
IniWrite, %IconGUIShort%, % KBD_IniFile%currentconfigurekbd%, Keyboard, Icon

;FileCopy, %DisplayCmd%, % KBD_Folder%kbd%, 1
;StringGetPos, position, DisplayCmd, \, R
;if Errorlevel=0
;	StringRight, DisplayCmdShort, DisplayCmd, StrLen(DisplayCmd) - position -1
;else
;	DisplayCmdShort:=DisplayCmd
;IniWrite, %DisplayCmdShort%, % KBD_IniFile%kbd%, Keyboard, DisplayCmd

;If KBD_ConfigureGUI%kbd%<>
;{
;	FileCopy, %ConfigGUI%, % KBD_Folder%kbd%, 1
;	StringGetPos, position, ConfigGUI, \, R
;	if Errorlevel=0
;		StringRight, ConfigGUIShort, ConfigGUI, StrLen(ConfigGUI) - position -1
;	else
;		ConfigGUIShort:=ConfigGUI
;	IniWrite, %ConfigGUIShort%, % KBD_IniFile%kbd%, Keyboard, ConfigureGUI
;}

; only need to do a reload if the keyboard being configured is currently enabled
if (currentconfigurekbd <= numKeyboards)
{
	gosub DoReload
}
currentconfigurekbd=-1
return

DoKbdOptions:
	FileRead options, % currOptionsFile
	numOpts := 0

	while (StrLen(options) > 1) {
		if (RegExMatch(options, "Oi)^( +)- (checkbox|keystroke):\s*\r?\n((?:\1\s+.*\r?\n)+)", match)) {
			; outputdebug % "option matched: " match.value(0)
			options := substr(options, match.Len(0)+1)
			fldCtrl := match.Value(2)
			if (fldCtrl = "keystroke")
				continue
			subFlds := match.Value(3)
			fldName := ""
			fldLabel := ""
			if (RegExMatch(subFlds, "Oi) name:\s+(.*?)\r?\n", match)) {
				fldName := match.Value(1)
			}
			fldDef := 0
			if (RegExMatch(subFlds, "Oi) default:\s+(.*?)\r?\n", match)) {
				fldDef := match.Value(1)
			}
			if (RegExMatch(subFlds, "Oi) label:\s+(.*?)\r?\n", match)) {
				fldLabel := match.Value(1)
			}
			numOpts += 1
			OPT_Name%numOpts% := fldName
			OPT_Label%numOpts% := fldLabel
			OPT_Ctrl%numOpts% := fldCtrl
			; outputdebug % "read from ini:" KBD_IniFile%currentconfigurekbd%
			IniRead OPT_Val%numOpts%, % KBD_IniFile%currentconfigurekbd%, Options, %fldName%, %fldDef%		; TODO: maybe fldDef may need chars escaped or like %A_Space%???
			; outputdebug % "init: " OPT_Name%numOpts% "=" OPT_Val%numOpts%
			continue
		}

		MsgBox WARNING: Options not parsed:`n%options%
		break
	}
	Gui, 8:+Owner1
	Gui 5:+Disabled
	oo := 1
	while (oo <= numOpts) {
		if (OPT_Ctrl%oo% = "checkbox") {
			isChecked := "Checked" . (OPT_Val%oo% ? 1 : 0)
			Gui, 8:Add, Checkbox, %isChecked% vOPT_Val%oo%, % OPT_Label%oo%
		}
		oo += 1
	}
	TempString:=GetLang(12)
	Gui, 8:Add, Button, g8ButtonOK, %TempString%  ; OK
	TempString:=GetLang(13)
	Gui, 8:Add, Button, x+10 g8ButtonCancel, %TempString%  ; Cancel
	Gui, 8:Show, Center, %configKbdBtnTxt%
return


8ButtonCancel:
8GuiClose:
	Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
	Gui, 8:Destroy
return

8ButtonOK:
	Gui, 5:-Disabled  ; Re-enable the main window (must be done prior to the next step).
	Gui, 8:Submit
	oo := 1
	while (oo <= numOpts) {
		IniWrite % OPT_Val%oo%, % KBD_IniFile%currentconfigurekbd%, Options, % OPT_Name%oo%
		oo += 1
	}
	Gui, 8:Destroy
return
