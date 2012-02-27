; Russian Phonetic Unicode 5.1 InKey™ Keyboard Layout
; Version 1.0  4 November 2008

#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Close
Menu, Tray, Icon, RussianPhoneticUnicode.ico

Gui, Add, Text, x100 y10 h30 , This InKey™ keyboard layout has been designed to either follow the standard Russian Windows keyboard layout:
Gui, Add, Picture, x26 y40 w692 h180, standard_kbd.jpg
Gui, Add, Text, x250 y245 h30, or a phonetic keyboard layout involving rotas:
Gui, Add, Picture, x26 y280 w692 h180, phonetic_kbd.jpg
Gui, Add, Button, x320 y470 w90 h30 Default, OK
Gui, Show, xCenter yCenter w750, Display Russian (Phonetic) Unicode Layout
Return

Close:
ButtonOK:
GuiClose:
	ExitApp

; See AHK Help for "GUI" for sample code that implements ToolTips that appear when the mouse moves over a GUI element.
