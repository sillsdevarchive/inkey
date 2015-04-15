#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Exit without Saving, ExitWithoutSaving
Menu, Tray, Add, Save and Exit, SaveAndExit
Menu, Tray, Icon, UndrdtVwl.bmp

IniRead, K_Params, UnderDot.kbd.ini, Keyboard, Params, %A_Space%

;*** This section is copied directly from NigUnderDot.ahk.  Updates there should be copied here, too.
UseSmartQuotes := GetParam("UseSmartQuotes", 1)
;*

Gui, Add, Checkbox, Checked%UseSmartQuotes% vUseSmartQuotes, Use smartquotes instead of << and >>
Gui, Add, Button, x140 y40 w80 h25, OK
Gui, Add, Button, x250 y40 w80 h25, Cancel
Gui, Show, xCenter yCenter w450, Keyboard Smartquotes Configuration
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
Params = UseSmartQuotes=%UseSmartQuotes%
IniWrite, %Params%, UnderDot.kbd.ini, Keyboard, Params
ExitApp

; This function is copied from InKeyLib.ahki.
; Retrieves the value of a named parameter (as parsed from the K_Params global variable).
GetParam(paramName, defaultVal = 0) {
	global K_Params
	if RegExMatch(K_Params, "i)(?<=\b" . paramName . "=)\S+", v)
		return v
	return defaultVal
}