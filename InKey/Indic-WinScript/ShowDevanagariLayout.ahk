; Indic-Winscript Keyboard Layout

#singleinstance force
SetWorkingDir %A_ScriptDir%

MsgBox 4, Show Devanagari Layout, The layout documentation is not yet available,`nbut there is an older PDF file that may give you`nan approximate idea of the Winscript layout.`n(New features are not shown.)`n`nWould you like to open it?
IfMsgBox yes
	Run "ShowDevanagariLayout.pdf"
