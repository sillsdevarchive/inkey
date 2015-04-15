;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         Rinku Kazeno <rinkuREMOVETHIS@kazenomusic.net>
;
; Intuitive Keyboard Expander v2.5
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#InstallKeybdHook  ; Forces the use of  the keyboard hook
#UseHook               ; For improved consistence

tmpvar=0                           ;variable for knowing if a key was pressed
upshft=0                            ;variable to write shift's press state
VarSetCapacity(SendUbuf, 28, 0)     ;set variable size for SendInput
NumPut(1, SendUbuf, 0, "Char")      ;format the variable for SendInput

;;;;;;;;;;;;; This section contains the lookup table for the keys
;;;;;;;;;;;;; used with each modifier, and the Hex Unicode of the
;;;;;;;;;;;;; corresponding character. 'code' denotes the lowercase
;;;;;;;;;;;;; and 'kode' the uppercase character. The number in the
;;;;;;;;;;;;; variable names indicates the ASCII code of the modifier

;;;;;;; Acute
base39 = aeioucnszylrw\gk
code39 = 00e1,00e9,00ed,00f3,00fa,0107,0144,015b,017a,00fd,013a,0155,1e83,0301,01f5,1e31
kode39 = 00c1,00c9,00cd,00d3,00da,0106,0143,015a,0179,00dd,0139,0154,1e82,0301,01f4,1e30
;;;;;;; Grave
base96 = aeiouwy\
code96 = 00e0,00e8,00ec,00f2,00f9,1e81,1ef3,0300
kode96 = 00c0,00c8,00cc,00d2,00d9,1e80,1ef2,0300
;;;;;;; Circumflex
base54 = aeioucghjswy\z
code54 = 00e2,00ea,00ee,00f4,00fb,0109,011d,0125,0135,015d,0175,0177,0302,1e91
kode54 = 00c2,00ca,00ce,00d4,00db,0108,011c,0124,0134,015c,0174,0176,0302,1e90
;;;;;;; Cedilla, Comma, Ogonek
base44 = aeioustcklnrgfd
code44 = 0105,0119,012f,01eb,0173,015f,0163,00e7,0137,013c,0146,0157,0123,0192,0256
kode44 = 0104,0118,012e,01ea,0172,015e,0162,00c7,0136,013b,0145,0156,0122,0191,0189
;;;;;;; Diaeresis, Umlaut, Trema
base59 = aeiouywhx\
code59 = 00e4,00eb,00ef,00f6,00fc,00ff,1e85,1e27,1e8d,0308
kode59 = 00c4,00cb,00cf,00d6,00dc,0178,1e84,1e26,1e8c,0308
;;;;;;; Horizontal Line, Macron
base45 = d=htg0zaeiou\;r,.
code45 = 0111,00b1,0127,0167,01e5,03b8,01b6,0101,0113,012b,014d,016a,0304,00f7,024d,2264,2265
kode45 = 0110,00b1,0126,0166,01e4,03b8,01b5,0100,0112,012a,014c,016b,0304,00f7,024c,2264,2265
;;;;;;; Tilde
base61 = aoniu\
code61 = 00e3,00f5,00f1,0129,0169,0303
kode61 = 00c3,00d5,00d1,0128,0168,0303
;;;;;;; Over Ring or Dot
base48 = auzxrcegbdfhmpst\
code48 = 00e5,016f,017c,00a4,00ae,010b,0117,0121,1e03,1e0b,1e1f,1e23,1e41,1e57,1e61,1e6b,0307
kode48 = 00c5,016e,017b,00a4,00ae,010a,0116,0120,1e02,1e0a,1e1e,1e22,1e40,1e56,1e60,1e6a,0307
;;;;;;; Breve, Hacek, Caron
base56 = agcndztsrelujk\|h
code56 = 0103,011f,010d,0148,010f,017e,0165,0161,0159,011b,013e,016d,01f0,01e9,030c,030c,021f
kode56 = 0102,011e,010c,0147,010e,017d,0164,0160,0158,011a,013d,016c,01f0,01e8,0306,0306,021e
;;;;;;; Diagonal Strike, Horn
base47 = ol1=bcdgkytpwnure0)
code47 = 00f8,0142,203d,2260,0253,0188,0257,0260,0199,01b4,01ad,01a5,2c73,0272,028b,027d,0247,2205,2300
kode47 = 00d8,0141,203d,2260,0181,0187,018a,0193,0198,01b3,01ac,01a4,2c72,019d,01b2,2c64,0246,2205,2300
;;;;;;; Under Dot
base46 = iouedhstzlr\n
code46 = 1ecb,1ecd,1ee5,1eb9,1e0d,1e25,1e63,1e6d,1e93,1e37,1e5b,0323,1e47
kode46 = 1eca,1ecc,1ee4,1eb8,1e0c,1e24,1e62,1e6c,1e92,1e36,1e5a,0323,1e46
;;;;;;; Double Acute
base93 = ou\
code93 = 0151,0171,030b
kode93 = 0150,0170,030b
;;;;;;; Double Grave
base91 = aeiour\
code91 = 0201,0205,0209,020d,0215,0211,030f
kode91 = 0200,0204,0208,020c,0214,0210,030f
;;;;;;; Mirror
base92 = c3#aev,<'"p/18*
code92 = 0254,025b,025b,0259,01dd,028c,0242,0242,02bb,02bb,00b6,00bf,00a1,221e,221d
kode92 = 0186,0190,0190,018f,018e,0245,0241,0241,02ca,02ca,00b6,00bf,00a1,221e,221d
;;;;;;; Alt Gr
baseAr = eqywlsbdpmiaot\123,.xgc-n[]'0zv5
vaseAr = eqywlsbdpmiaot|!@#<>xgc_n{}")zv5
codeAr = 20ac,03c9,00a5,20a9,00a3,00a7,00df,00f0,00fe,00b5,0131,00e6,0153,2122,00a6,00bf,00b2
,00b3,00ab,00bb,00d7,0263,00a2,00ac,014b,2018,2019,201a,00b7,0292,221a,2030
kodeAr = 20ac,03a9,00a5,20a9,00a3,017f,1e9e,00d0,00de,00b5,0130,00c6,0152,2122,00a6,00bf,00b2
,00b3,2039,203a,00a4,0194,00a9,00ac,014a,201c,201d,201e,00b0,01b7,221a,2030

;;;;;;;;;;;;; This section checks if Alt-Hex Input is enabled in the registry.
;;;;;;;;;;;;; If yes it continues executing the program, if not it asks for
;;;;;;;;;;;;; permission to enable it by creating a .reg file, executing it
;;;;;;;;;;;;; silently, and then erasing it (did it this way for 64-bit support).

RegRead, yomi, HKEY_CURRENT_USER, Control Panel\Input Method, EnableHexNumpad
if yomi!=1
 {
  MsgBox, 4, , This program uses Alt+Hex Unicode Input when sending through`nthe Windows API fails, but it's disabled on your system.`nWould you like to enable it?
  IfMsgBox Yes
  {
   FileAppend,
(
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Input Method]
"EnableHexNumpad"="1"
), xy0ab9tmp.reg
   RunWait, %comspec% /c regedit.exe /s xy0ab9tmp.reg
   FileDelete xy0ab9tmp.reg
   MsgBox Directive processed, the program will now close. Please restart your system`nfor Windows to recognize the changes.
  ExitApp
  }
  else
  {
   MsgBox, 4, , It's strongly advised you enable Alt+Hex Unicode Input on your system.`nContinue anyway?
   IfMsgBox No
   {
	MsgBox The program will now close.
	Exitapp
   }
  }
 }
else
Return

;;;;;;;;;;;;; Here's the main function, it starts by defining all modifiers as hotkeys.

*'::
*6::
*`::
*,::
*;::
*-::
*=::
*0::
*/::
*.::
*8::
*]::
*[::
*\::
 modifier:=RegExReplace(A_ThisHotkey,"\*")   ;store the pressed modifier
 downshft:=GetKeyState("Shift", "P")    ;store the state of the Shift key
 HotKey, Shift UP, Shftint, On                      ;create a hotkey for shift up
 Hotkey, *%modifier% UP, Uppity, On     ;create a hotkey for the release of the modifier
 while GetKeyState(modifier, "P")                ;while the modifier's pressed
 {
  Suspend, On                                            ;disable all other modifiers
  Input, seckey, L1                                      ;wait for the key
  if (ErrorLevel="NewInput")                       ;if the modifier's released escape
  {
   HotKey, Shift UP, Off
   if (tmpvar=0 && upshft=0)        ;if no key was pressed send the modifier
   {
	if GetKeyState("Shift", "P")=1
	 Send +{%modifier%}
	else
	 Send {blind}{%modifier%}
	break
   }
   else
   {
	upshft=0
	tmpvar=0
	break
   }
  }
  HotKey, Shift UP, Off                                ;disable shift as a hotkey
  tmpvar=1                                               ;a key was pressed
  upshft=0                                              ;don't send anything if shift is released
  tbsel:=Asc(modifier)              ;get the ASCII code of the modifier
  base:=base%tbsel%            ;assign the correesponding lookup tables
  code:=code%tbsel%
  kode:=kode%tbsel%
  StringGetPos, charpos, base,%seckey%  ;get the position of the key in the lookup table
  if (ErrorLevel=1)                                   ;if doesn't exist send both keys
  {
   Send {Blind}{%modifier%}%seckey%
  }
  else
  {
   if GetKeyState("Shift", "P")=1            ;if shift's pressed send Uppercase
   {
	codepos:=charpos*5+1             ;get the Hex Unicode from the lookup table
	StringMid, Ucode, kode, %codepos%, 4
	HexCode=0x%Ucode%
	NumPut(0x40000, SendUbuf, 6)     ;put the Hex Unicode inside the variable
	NumPut(HexCode, SendUbuf, 6, "Short")
	result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)  ;send it to Windows baby!
	if ( ErrorLevel or result < 1 )         ;doesn't work?
	 Send {LAlt Down}{NumpadAdd}%Ucode%{LAlt Up} ;send the Alt Code instead
	else                         ;now prepare and send the key release code
	{
	 NumPut(0x60000, SendUbuf, 6)
	 NumPut(HexCode, SendUbuf, 6, "Short")
	 result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	}
   }
   else                                ;send Lowercase (same as Uppercase)
   {
	codepos:=charpos*5+1
	StringMid, Ucode, code, %codepos%, 4
	HexCode=0x%Ucode%
	NumPut(0x40000, SendUbuf, 6)
	NumPut(HexCode, SendUbuf, 6, "Short")
	result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	if ( ErrorLevel or result < 1 )
	 Send {LAlt Down}{NumpadAdd}%Ucode%{LAlt Up}
	else
	{
	 NumPut(0x60000, SendUbuf, 6)
	 NumPut(HexCode, SendUbuf, 6, "Short")
	 result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	}
   }
  }
 }
 Hotkey, *%modifier% UP, Off              ;disable the interrupt hotkey
 Suspend Off                                       ;disable suspend
 tmpvar=0                                          ;return to 0 the key pressed variable
 return

Uppity:                          ;interrupt the main function if modifier's released
 Suspend, Permit
 Input
 Return

Shftint:                               ;if shift is released without pressing a key
 Suspend, Permit
 if downshft=1                   ;if it was down while the modifier was pressed
 {
  upshft=1
  SendPlay +{%modifier%}      ;send the modifier anyway
 }
 return

$*RAlt::         ;Same as the main function, but for Right Alt
 Suspend, Permit
 while GetKeyState("RAlt", "P")
 {
  Suspend, On
  Input, seckey, L1
  if (ErrorLevel="NewInput")
  break
  else
  {
   Suspend, Off
   StringGetPos, charpos, baseAr,%seckey%
   if (ErrorLevel=1)
   {
	StringGetPos, charpos, vaseAr,%seckey%
   }
   if (ErrorLevel=1)
	Send {RAlt Down}{%seckey%}{RAlt Up}
   else
   {
	if GetKeyState("Shift", "P")=1
	{
	 codepos:=charpos*5+1
	 StringMid, Ucode, kodeAr, %codepos%, 4
	 HexCode=0x%Ucode%
	 NumPut(0x40000, SendUbuf, 6)
	 NumPut(HexCode, SendUbuf, 6, "Short")
	 result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	 if ( ErrorLevel or result < 1 )
	  Send {LAlt Down}{NumpadAdd}%Ucode%{LAlt Up}
	 else
	 {
	  NumPut(0x60000, SendUbuf, 6)
	  NumPut(HexCode, SendUbuf, 6, "Short")
	  result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	 }
	}
	else
	{
	 codepos:=charpos*5+1
	 StringMid, Ucode, codeAr, %codepos%, 4
	 HexCode=0x%Ucode%
	 NumPut(0x40000, SendUbuf, 6)
	 NumPut(HexCode, SendUbuf, 6, "Short")
	 result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	 if ( ErrorLevel or result < 1 )
	  Send {LAlt Down}{NumpadAdd}%Ucode%{LAlt Up}
	 else
	 {
	  NumPut(0x60000, SendUbuf, 6)
	  NumPut(HexCode, SendUbuf, 6, "Short")
	  result := DllCall("SendInput", "uint", 1, "uint", &SendUbuf, "int", 28)
	 }
	}
   }
  }
 }
 Suspend, Off
 return

$*RAlt UP::                              ;interrupt the Alt function
 Suspend, Permit
 Suspend, Off
 Input
 Return