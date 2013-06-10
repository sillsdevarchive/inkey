; Russian Phonetic Unicode 2.0 InKey™ Keyboard Layout
; Version 2.0  22 March 2013

#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Close
Menu, Tray, Icon, RussianPhoneticUnicode.ico

Gui, Add, Text, x100 y10 h30 , This InKey™ keyboard layout has been designed to follow a phonetic keyboard layout involving MultiTap maps:
Gui, Add, Picture, x26 y40 w692 h180, phonetic_kbd.jpg
Gui, Add, Button, x320 y240 w90 h30 Default, OK
Gui, Show, xCenter yCenter w750, Display Russian Phonetic Unicode Layout
Return

Close:
ButtonOK:
GuiClose:
	ExitApp

; See AHK Help for "GUI" for sample code that implements ToolTips that appear when the mouse moves over a GUI element.
