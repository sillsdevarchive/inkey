; DevRom Options Configuration GUI
; Version 1.2  18 November 2008

#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Exit without Saving, ExitWithoutSaving
Menu, Tray, Add, Save and Exit, SaveAndExit
Menu, Tray, Icon, deva.ico

IniRead, K_Params, DevRom.kbd.ini, Keyboard, Params, %A_Space%

/*
   SwapSHA=1	Swap SHA (z) and SSA (S) keys from original DevRom layout
   ScriptDigit=1 	Use Devanagari digits rather than Western digits by default.
   SwapHalfH=1	Swap x and shift+x behavior after h, for languages that
			prefer ह्‌ to ह्‍
   UseLLA=1		For languages that don't need LLA (ळ), shift+L can give a
			shortcut for lo-R (e.g in क्र) otherwise obtained by typing  ; r
   smartQuotes=1	Use Smart (double) quotes by default.  (Press " again to toggle this.)
   ApostropheForTone=1	Use the apostrophe key (') for a tone mark (’)
   OnlyDeadKeyForVowels=1  Only generate Independent form of vowel after 'q' deadkey
*/

;*** This section is copied directly from DevRom.ahk.  Updates there should be copied here, too.
	SwapSHA := GetParam("SwapSHA", 1) ; whether to swap SHA (z) and SSA (S) keys
	ScriptDigit := GetParam("ScriptDigit", 0) ;  whether to use script digits by default (and CapsLock for Roman digits)
	SwapHalfH := GetParam("SwapHalfH", 0) ; for Kangri, the default 'x' behavior for post-h is non-joining
	UseLLA := GetParam("UseLLA", 1) ; for languages that don't need LLA (ळ), shift+L can give a shortcut for lo-R (e.g in क्र) normally obtained by typing  ; r
	SmartQuotes := GetParam("SmartQuotes", 0)
	ApostropheForTone := GetParam("ApostropheForTone", 0)
	OnlyDeadKeyForVowels := GetParam("OnlyDeadKeyForVowels", 0)
;*

Gui, Add, Checkbox, Checked%SwapSHA% vSwapSHA, Swap SHA (z) and SSA (S) keys
Gui, Add, Checkbox, Checked%ScriptDigit% vScriptDigit, Use Devanagari digits rather than Western digits by default
Gui, Add, Checkbox, Checked%SwapHalfH% vSwapHalfH, Swap x and shift+x behavior after h
Gui, Add, Checkbox, Checked%UseLLA% vUseLLA, Use LLA.  (For languages that don't need LLA, shift+L can give a shortcut for lo-R)
Gui, Add, Checkbox, Checked%SmartQuotes% vSmartQuotes, Use Smart (double) quotes by default
Gui, Add, Checkbox, Checked%ApostropheForTone% vApostropheForTone, Use apostrophe (') key for tone marker
Gui, Add, Checkbox, Checked%OnlyDeadKeyForVowels% vOnlyDeadKeyForVowels, Only generate Independent form of vowel after 'q' deadkey

Gui, Add, Button, x10 y160 w80 h30, Save
Gui, Add, Button, x100 y160 w80 h30, Cancel
Gui, Show, xCenter yCenter, DevRom Configuration Options
return

ExitWithoutSaving:
GuiClose:
ButtonCancel:
Gui, Destroy
ExitApp

ButtonSave:
SaveAndExit:
Gui, Submit
Gui, Destroy
K_Params = ScriptDigit=%ScriptDigit% SwapHalfH=%SwapHalfH% UseLLA=%UseLLA% SmartQuotes=%SmartQuotes% SwapSHA=%SwapSHA% ApostropheForTone=%ApostropheForTone% OnlyDeadKeyForVowels=%OnlyDeadKeyForVowels%
IniWrite, %K_Params%, DevRom.kbd.ini, Keyboard, Params
ExitApp

; This function is copied from InKeyLib.ahki.
; Retrieves the value of a named parameter (as parsed from the K_Params global variable).
GetParam(paramName, defaultVal = 0) {
	global K_Params
	if RegExMatch(K_Params, "i)(?<=\b" . paramName . "=)\S+", v)
		return v
	return defaultVal
}
