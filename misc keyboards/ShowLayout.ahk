; Generic InKey™ Keyboard Layout
; Version 1.0  4 November 2008

#singleinstance force
SetWorkingDir %A_ScriptDir%
Menu, Tray, NoStandard
Menu, Tray, Add, Close
Menu, Tray, Icon, Generic.ico

Gui, Add, Text, x100 y10 h30 , This InKey™ keyboard layout is rather generic:
Gui, Add, Picture, x26 y40 w692 h180, standard_kbd.jpg
Gui, Add, Button, x320 y230 w90 h30 Default, OK
Gui, Show, xCenter yCenter w750, Display Generic Layout
Return

Close:
ButtonOK:
GuiClose:
	ExitApp

; See AHK Help for "GUI" for sample code that implements ToolTips that appear when the mouse moves over a GUI element.
