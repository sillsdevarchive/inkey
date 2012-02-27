; Russian Unicode Options Configuration GUI
; Version 1.1  19 November 2008

#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Exit without Saving, ExitWithoutSaving
Menu, Tray, Add, Save and Exit, SaveAndExit
Menu, Tray, Icon, RussianPhoneticUnicode.ico

IniRead, K_Params, Russian Phonetic Unicode InKey.kbd.ini, Keyboard, Params, %A_Space%

;*** This section is copied directly from RussianPhoneticUnicode.ahk.  Updates there should be copied here, too.
Phonetic := GetParam("Phonetic", 0)
;*

Gui, Add, Checkbox, Checked%Phonetic% vPhonetic, Use the phonetic keyboard layout instead of the standard Russian Windows layout
Gui, Add, Button, x140 y40 w80 h25, OK
Gui, Add, Button, x250 y40 w80 h25, Cancel
Gui, Show, xCenter yCenter w450, Russian (Phonetic) Unicode Configuration Options
return

ExitWithoutSaving:
GuiClose:
ButtonCancel:
Gui, Destroy
ExitApp

ButtonOK:
SaveAndExit:
Gui, Submit
Gui, Destroy
Params = Phonetic=%Phonetic%
IniWrite, %Params%, Russian Phonetic Unicode InKey.kbd.ini, Keyboard, Params
ExitApp

; This function is copied from InKeyLib.ahki.
; Retrieves the value of a named parameter (as parsed from the K_Params global variable).
GetParam(paramName, defaultVal = 0) {
	global K_Params
	if RegExMatch(K_Params, "i)(?<=\b" . paramName . "=)\S+", v)
		return v
	return defaultVal
}