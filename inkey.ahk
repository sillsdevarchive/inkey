/*
 * * * Compile_AHK SETTINGS BEGIN * * *

[AHK2EXE]
Exe_File=%In_Dir%\InKey\InKey.exe
Alt_Bin=C:\Program Files (x86)\AutoHotkeyL\Compiler\AutoHotkeySC.bin
No_UPX=1
Execution_Level=2
[VERSION]
Set_Version_Info=1
Company_Name=InKeySoftware
File_Description=InKey Keyboard Manager
File_Version=0.3.0.3
Inc_File_Version=0
Internal_Name=inkey
Legal_Copyright=(c) 2008-2013 InKeySoftware
Original_Filename=InKey.ahk
Product_Name=InKey Keyboard Manager
Product_Version=0.3.0.3
[ICONS]
Icon_1=%In_Dir%\inkey.ico

* * * Compile_AHK SETTINGS END * * *
*/

#NoEnv
#SingleInstance force
#Warn All, OutputDebug

; Main initialization
	Outputdebug ___________________________ INKEY.AHK ___________________
	ver = 0.900 ;
	K_ProtocolNum := 4 ; When changes are made to the communication protocol between InKey and InKeyLib.ahki, this number should be incremented in both files.
	SetWorkingDir %A_ScriptDir%
	onExit DoCleanup
	;~ SetTitleMatchMode 3
	SetTitleMatchMode 2
	DetectHiddenWindows On
	;~ selfHwnd := WinExist(A_ScriptFullPath . " ahk_class AutoHotkey")
	selfHwnd := WinExist(A_ScriptFullPath . " ahk_class AutoHotkey")
	outputdebug selfHwnd = %selfHwnd%
	currentconfigurekbd := -1
	currentconfigure := 0
	ActiveKbd := -1
	ActiveKbdFile =
	ActiveKbdHwnd =
	ActiveHKL := 0
	Kbd2RegCt := 0
	LastKbdActivationTC := 0
	ShowKeyboardNameBalloon := 0
	oHKLDisplayName := Object()
	KbdFile0 := ""
	KbdFileID0 := ""
	KbdHKL0 := GetDefaultHKL() ; also initializes preLoadedHKLs
	oKbdByHKL := Object()
	oKbdByHKL[KbdHKL0] := 0
	dblTap := 0
	currSendingMode := 0
	LastRotID := ""
	CounterBefore := 0
	CounterAfter := 0
	thisAppDoesGreedyBackspace := 0

	SetFormat, IntegerFast, D
	outputdebug Default HKL=%KbdHKL0%
	ActivateKbd(0, KbdHKL0)
	;~ HKLDisplayName%KbdHKL0% := GetLang(1)  ; "Default Keyboard"
	oHKLDisplayName[KbdHKL0] := GetLang(1)  ; "Default Keyboard"
	validate()
	hwndLastActive := WinExist("A")
	WinGet hwndTray, ID, ahk_class Shell_TrayWnd
	;outputdebug hwndtray = %hwndtray%
	; KbdToRequest := -1
	GetRegisteredKbds()
	Outputdebug Kbd# 0 (Default) HKL=%KbdHKL0%
	InkeyLoadedHKLs := ""
	setupCallbacks()
;	SendU_Init()
	hMSVCRT := DllCall("LoadLibrary", "str", "MSVCRT.dll")

	initContext()
	Menu KbdMenu, UseErrorLevel

	; Read main section of INI file
	IniRead UnderlyingLayout, InKey.ini, InKey, UnderlyingLayout, %A_Space%
	if (not UnderlyingLayout)
		UnderlyingLayout := "0000" . A_Language
	RegRead UnderlyingLayoutFile, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%UnderlyingLayout%, Layout File
	if (not UnderlyingLayoutFile)
		UnderlyingLayoutFile := "kbdus.dll"

	IniRead FollowWindowsInputLanguage, InKey.ini, InKey, FollowWindowsInputLanguage, 1
	;IniRead AutoGrabContext, InKey.ini, InKey, AutoGrabContext, 0
	AutoGrabContext = 0
	IniRead PortableMode, InKey.ini, InKey, PortableMode, 1
	IniRead IsBeta, InKey.ini, InKey, Beta, 1

	IniRead ShowKeyboardNameBalloon, InKey.ini, InKey, ShowKeyboardNameBalloon, 0
	IniRead UseAltLangWithoutPrompting, InKey.ini, InKey, UseAltLangWithoutPrompting, 0
	IniRead CurrentLang, Lang.ini, Language, Name

	; [Un]/Register InKey to run on Windows start-up, if running from a fixed drive.
	DriveGet, driveIsFixed, Type, %A_ScriptFullPath%
	driveIsFixed := (driveIsFixed = "Fixed")
	if (driveIsFixed) {
		IniRead StartWithWindows, InKey.ini, InKey, StartWithWindows, 0
		if (StartWithWindows) {
			QuotedPath = "%A_ScriptFullPath%"
			RegRead, pls, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey
			if (pls <> QuotedPath)
				RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey, %QuotedPath%
		} else
			RegDelete HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey
	}

	IniRead LeaveKeyboardsLoaded, InKey.ini, InKey, LeaveKeyboardsLoaded, 0

	;IniRead PutMenuAtCursor, InKey.ini, InKey, PutMenuAtCursor, 0
	 ; if (not PutMenuAtCursor) {
		; WinGetPos TrayX, TrayY, ww, hh, ahk_class ToolbarWindow32, Notification Area
		; outputdebug tray: %TrayX%, %TrayY%, %ww%, %hh%
		 ; CoordMode Menu, Screen
	 ; }

	; Begin setting up menu
	menu tray, nostandard
	LangString:=GetLang(2)
	menu tray, add, %LangString%, ShowAbout ; About InKey...
	LangString:=GetLang(3)
	menu tray, add, %LangString%, DoConfigureInKey ; Configure InKey...
	LangString:=GetLang(4)
	menu tray, add, %LangString%, DoHelp ; InKey Help
;	menu tray, add, Follow Language Bar, MenuFollow
	; if FollowWindowsInputLanguage
		; menu, tray, check, Follow Language Bar
	LangString:=GetLang(5)
	menu tray, add, %LangString%, MenuAutoGrab ; Auto Grab Context
	if AutoGrabContext
		menu, tray, check, %LangString% ; Auto Grab Context
	LangString:=GetLang(6)
	menu tray, add, %LangString%, DoExit ; Exit InKey
	menu tray, click, 1
	menu tray, tip, InKey

	OnString:=GetLang(59) ; ON
	OffString:=GetLang(60) ; OFF

	KbdFile0 := ""
	DispGUIs := 0
	DispCmds := 0

	numKeyboards = 0
	KbdInProc = 0

	numKbdFiles = 0
	KbdFiles =
	FolderList =
	Loop, *.*, 2
		FolderList = %FolderList%%A_LoopFileName%`n
	Sort, FolderList
	Loop, parse, FolderList, `n
	{	if (A_LoopField = "" or InStr(A_LoopField, ".")) ; Ignore the blank item at the end of the list, and ignore any folder containing a dot in the name.
			continue

		CurrFolder := A_LoopField
		; For each keyboard class (i.e. folder), first read the keyboard program name
		IniRead, CurrKbdCmd, %A_LoopField%\Class.ini, Class, Cmd, %A_Space%
		if (CurrFolder <> "_Non-InKey" and not CurrKbdCmd)
			continue
			;	outputdebug processing folder: %A_LoopField%.  CurrKbdCmd=%CurrKbdCmd%

		; Loop for each *.kbd.ini file
		KbdList =
		Loop, %A_LoopField%\*.kbd.ini
			KbdList = %KbdList%%A_LoopFileName%`n
		Sort, KbdList
		Loop, parse, KbdList, `n
		{	if (A_LoopField = "") ; Ignore the blank item at the end of the list.
				continue
			CurrIni = %CurrFolder%\%A_LoopField%
			; outputdebug processing file: %CurrIni%
			IniRead, ii, %CurrIni%, Keyboard, Enabled, %A_Space%
			if (not ii)		; skip items without Enabled=1
				continue
			numKeyboards++  ; New keyboard to configure
			KbdFolder%numKeyboards% := CurrFolder
			KbdIniFile%numKeyboards% := CurrIni
			KbdDisabled%numKeyboards% := 0
			KbdIconNum%numKeyboards% := 0
			KbdFileHwnd%numKeyboards% := 0
			; KbdLayoutName%numKeyboards% := SubStr(A_LoopField, 1, InStr(A_LoopField, ".kbd.ini") - 1)
			IniRead, KbdLayoutName%numKeyboards%, %CurrIni%, Keyboard, LayoutName, %A_Space%
			IniRead, KbdMenuText%numKeyboards%, %CurrIni%, Keyboard, MenuText, %A_Space%
			IniRead, KbdHotkey%numKeyboards%, %CurrIni%, Keyboard, Hotkey, %A_Space%
			IniRead, KbdLang%numKeyboards%, %CurrIni%, Keyboard, Lang, %A_Space%
			IniRead, KbdAltLang%numKeyboards%, %CurrIni%, Keyboard, AltLang, %A_Space%
			IniRead, KbdIcon%numKeyboards%, %CurrIni%, Keyboard, Icon, %A_Space%
			IniRead, KbdParams%numKeyboards%, %CurrIni%, Keyboard, Params, %A_Space%
			IniRead, KbdConfigureGUI%numKeyboards%, %CurrIni%, Keyboard, ConfigureGUI, %A_Space%
			IniRead, KbdDisplayCmd%numKeyboards%, %CurrIni%, Keyboard, DisplayCmd, %A_Space%
			IniRead, KbdKLID%numKeyboards%, %CurrIni%, Keyboard, KLID, %A_Space%
			ProcessKbd()
		}
	}
	; now deal with the keyboards that needed registration or unregistration
	if (PortableMode)
		UnusedRKCt := 0
	if (UnusedRKCt or Kbd2RegCt) {  ; This will only be true when running in Installed mode. (PortableMode=0)
		if (A_IsAdmin) {  ; We have the necessary permissions to do this now.
			if (UnusedRKCt) {
				; Unregister any old keyboards not used
				UnloadCt := 0
				Loop % RKCt {
					if (not RK_Used%A_Index%) {
						key := RK_KLID%A_Index%
						RegDelete HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%key%
						outputdebug RegDelete HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%key%
						; If keyboard had previously been configured for pre-loading, undo that.
						id := RK_LID%A_Index%
						hkl := "0xF" . substr(RK_LID%A_Index%, -2) . substr(RK_KLID%A_Index%, -3)
						UnloadCt += DllCall("UnloadKeyboardLayout","uint",hkl)
					}
				}
				if (UnloadCt)
					RefreshLangBar()  ; Doing this here will cause Windows to take care of deleting registry residue from HKCU... Preload and Substitutes
			}
			; TODO:  Calculate MaxLID here (after the above deletions) instead, otherwise, repeated changes will use up LIDs.  Actually, some day we ought to be smart enough to use the lower LIDs that were unused.
			if (Kbd2RegCt) {
				; Register and load any keyboards needing it
				Loop % Kbd2RegCt
				{	; Do registration
					kk := Kbd2Reg%A_Index%
					KbdHKL%kk% := RegisterAndLoadKeyboard(kk)
					oKbdByHKL[KbdHKL%kk%] := kk
					SetFormat, IntegerFast, d
				}
			}
		} else {  ; not A_IsAdmin
			; There are keyboards needing registered or unregistered, but user does not have Admin privileges.
			Gui Hide
			TitleString:=GetLang(116)  ; Install/update Keyboard registration?
			TempString:=GetLang(117) . " " . UnusedRKCt . "`n" . GetLang(118) . " " . Kbd2RegCt . "`n`n" . GetLang(119) . "`n" . GetLang(120) . "`n" . GetLang(121) . "`n`n" . GetLang(122)
			MsgBox 36, %TitleString%, %TempString%  ; # Keyboards to unregister: %UnusedRKCt%`n# Keyboards to register: %Kbd2RegCt%`n`nFor InKey to run in its "Installed" mode, it must first update the keyboard registry to match your settings.`nDoing so requires full administrator permissions.`nIf you do not have administrator permissions on this computer, InKey can still run in "Portable" mode.`n`nWould you like to restart InKey with full administrator permissions?
			ifMsgBox Yes
			{	DllCall("shell32\ShellExecuteW", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "ReloadAsAdmin", str, A_ScriptDir, int, 1)
				sleep 2000
				exitapp
			}
			PortableMode = 1
			Gui Show
			Loop % Kbd2RegCt
			{	; Use substitute keyboards instead
				kk := Kbd2Reg%A_Index%
				KbdHKL%kk% := LoadSubstituteKeyboard(KbdLang%kk%, KbdLayoutName%kk%)
				oKbdByHKL[KbdHKL%kk%] := kk
			}
		}
	}
	KbdInProc =
	FolderList =
	found =
	KbdFiles =
	;  DRM: The following section was cut because it seemed to interfere with inkey-specified layout names.  it seems to still work for non-inkey layouts.
	;~ Loop, Parse, preloadedHKLs, %A_Space%
	;~ {
		;~ if ((A_LoopField <> "") and (HKLDisplayName%A_LoopField% = "")) ; Ignore the blank item at the end of the list, and any HKL for which we already have a display name
		;~ if ((A_LoopField <> "") and (oHKLDisplayName.HasKey(A_LoopField))) ; Ignore the blank item at the end of the list, and any HKL for which we already have a display name
		;~ {
;;			HKLDisplayName%A_LoopField% := GetHKLDisplayName(A_LoopField)
			;~ oHKLDisplayName[A_LoopField] := GetHKLDisplayName(A_LoopField)
			;~ OutputDebug % "We just looked up displayname for " A_LoopField  "=>" oHKLDisplayName[A_LoopField]
		;~ }
	;~ }
	IniRead RefreshLangBarOnLoad, InKey.ini, InKey, RefreshLangBarOnLoad, 2
	if (InkeyLoadedHKLs) {
		if (RefreshLangBarOnLoad = 1)
			RefreshLangBar() ; Slow but sure
		else if (RefreshLangBarOnLoad = 2) {	; Post WM_INPUTLANGCHANGEREQUEST to HWND_BROADCAST
			DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, LastLoadedHKL)  ; First change it to something else
			DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; Then change it back to default lang.
		}
	}

	if numKeyboards <> 0
	{
		menu tray, add
		LangString:=GetLang(7)
		menu tray, add, %LangString%, :DispConfigureSubmenu  ; Configure keyboard options
		if (DispCmds) {
			LangString:=GetLang(8)
			menu tray, add, %LangString%, :DispCmdSubmenu  ; Display keyboard layout
		}
		menu tray, add
		LangString:=GetLang(9)
		menu tray, add, %LangString%, ShowKbdMenu    ; Select Keyboard
		menu tray, default, %LangString%    ; Show it in boldface

		;IniRead KbdMenuText0, InKey.ini, InKey, DefaultKbdMenuText, & Default keyboard
		menu KbdMenu, add
		KbdMenuText0:=GetLang(10)
		menu KbdMenu, add, %KbdMenuText0%, KeyboardMenuItem	; Add menu item for default keyboard
		menu KbdMenu, check, %KbdMenuText0%
	}

	; ============Set up hotkeys.

	IniRead ii, InKey.ini, InKey, ResyncHotkey, %A_Space%
	; Resync Keyboards with InKey - Workaround for a bug
	if (ii)
		Hotkey %ii%, DoResync, UseErrorLevel

	; Reload InKey
	IniRead ii, InKey.ini, InKey, ReloadHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, DoReload, UseErrorLevel

	; DefaultKbdHotkey
	IniRead KbdHotkey0, InKey.ini, InKey, DefaultKbdHotkey, %A_Space%
	if (KbdHotkey0)
		Hotkey %KbdHotkey0%, OnKbdHotkey, UseErrorLevel

	; DefaultKbdDoubleTap
	IniRead ii, InKey.ini, InKey, DefaultKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapDefKbd, UseErrorLevel
	}

	; NextKbdHotkey
	IniRead ii, InKey.ini, InKey, NextKbdHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, RequestNextKbd, UseErrorLevel

	; NextKbdDoubleTap
	IniRead ii, InKey.ini, InKey, NextKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapNextKbd, UseErrorLevel
	}

	; PrevKbdHotkey
	IniRead ii, InKey.ini, InKey, PrevKbdHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, RequestPrevKbd, UseErrorLevel

	; PrevKbdDoubleTap
	IniRead ii, InKey.ini, InKey, PrevKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapPrevKbd, UseErrorLevel
	}

	; MenuHotkey
	IniRead ii, InKey.ini, InKey, MenuHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, ShowKbdMenu, UseErrorLevel

	; MenuDoubleTap
	IniRead ii, InKey.ini, InKey, MenuDoubleTap, %A_Space%
	if (ii) {
		; HotKey ~%ii% & SC200, Nothing, UseErrorLevel
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapMenuKbd, UseErrorLevel
	}

	; AutoGrabContextHotkey
	IniRead ii, InKey.ini, InKey, AutoGrabContextHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, MenuAutoGrab, UseErrorLevel

	; GrabContextHotkey
	IniRead ii, InKey.ini, InKey, GrabContextHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, GrabContext, UseErrorLevel

	; ChangeSendingMode hotkey
	IniRead ii, InKey.ini, InKey, ChangeSendingMode, %A_Space%
	if (ii)
		Hotkey %ii%, ChangeSendingMode, UseErrorLevel

	; ClearContextHotkey
	; IniRead ii, InKey.ini, InKey, ClearContextHotkey, %A_Space%
	; if (ii)
		; Hotkey $%ii%, CLEARCONTEXT, UseErrorLevel

	; All keyboard hotkeys (previously read)
	Loop % numKeyboards
	{	hk := GetKbdHotkey(A_Index)
		if (hk)
			Hotkey %hk%, OnKbdHotkey, UseErrorLevel
	}

	CoordMode, ToolTip

	if (RefreshLangBarOnLoad = 2 and InkeyLoadedHKLs)
	{	; Post WM_INPUTLANGCHANGEREQUEST to HWND_BROADCAST
	;	DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, LastLoadedHKL)  ; First change it to something else
		DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; Then change it back to default lang.
		ChangeLanguage(KbdHKL0)
	}

	IniRead PreviewAtCursor, InKey.ini, InKey, PreviewAtCursor, 1
	IniRead rotaPeriod, InKey.ini, InKey, SpeedRotaPeriod, 1000

	;~ if (numKeyboards <> 0)
		;~ Sleep, 2000
	gui hide

;	ChangeLanguage(KbdHKL0) ; Just to be sure
	; OnMessage(0x6, "On_WM_ACTIVATE")
	tipHwnd := CreateUTip()
	; tipTxt

	Loop % numKeyboards  {
			kk := A_Index
			OutputDebug % kk . " " . KbdLayoutName%kk% . " " .  KbdFileID%kk% . " " . KbdFile%kk%  . " " . KbdHKL%kk%
	}

	SetTimer CHECKLOCALE, 500
	if (numKeyboards = 0) {
		Gui Hide
		goto WelcomeToInKey
	}
return

ProcessKbd() {
	global
	static ProcdKbdList := ""
	local kk := numKeyboards
ProcessKbdErrors:
	if (KbdDisabled%kk%) {
			;or ( KbdFile%kk% and not FileExist(KbdFolder%kk% . "\" . KbdFile%kk%))) {
		; local xx := KbdMenuText%kk%
		; outputdebug ignoring %fldr% %xx%

		KbdFileID%kk% =
		KbdFile%kk% =
		KbdMenuText%kk% =
		KbdHotkeyCode%kk% =
		KbdLayoutName%kk% =
		KbdLang%kk% =
		KbdIcon%kk% =
		KbdParams%kk% =
		KbdKLID%kk% =
		KbdDisabled%kk% =
		KbdConfigureGUI%kk% =
		KbdRunGUI%kk% =
		KbdDisplayCmd%kk% =
		KbdRunCmd%kk% =
		KbdAltLang%kk% =
		numKeyboards--
		return
	}

	KbdFile%kk% := CurrKbdCmd

	; populate submenu for all enabled keyboards
	Menu, DispConfigureSubmenu, add, % KbdMenuText%kk%, DispConfigureMenuItem

	; populate subment if keyboard has a layout help file
	if (KbdDisplayCmd%kk%) {
		DispCmds++
		; If the keyboard help file exists in the keyboard's folder, prepend path.
		if (FileExist(KbdFolder%kk% . "\" . KbdDisplayCmd%kk% ))
			KbdDisplayCmd%kk%  := KbdFolder%kk% . "\" . KbdDisplayCmd%kk%
		; otherwise hopefully the file is on the PATH
		ii := KbdMenuText%kk%
		Menu, DispCmdSubmenu, add, %ii%, DispCmdMenuItem
	}

	if (KbdLayoutName%kk%) {
		; These are the settings for an InKey keyboard
		local ln := KbdLayoutName%kk%
		; Check that the language code is valid on this machine
		if (not KbdLang%kk%) {
			Gui Hide
			TitleString:=GetLang(123) ; Configuration Error
			TempString:=GetLang(124) ; The language code for keyboard "%ln%" is missing.
			MsgBox 0, %TitleString%, %TempString%
			Gui Show
			KbdDisabled%kk% := 1
			goto ProcessKbdErrors
		}
		if (strlen(KbdLang%kk%) <> 4) {
			Gui Hide
			TitleString:=GetLang(123) ; Configuration Error
			TempString:=GetLang(125) ; The language code for keyboard "%ln%" should be a 4-hexidecimal-digit code representing the language ID.
			MsgBox 0, %TitleString%, %TempString%
			Gui Show
			KbdDisabled%kk% := 1
			goto ProcessKbdErrors
		}
		local priLang := "0x" . KbdLang%kk%
		local sLangName
		VarSetCapacity( sLangName, 260, 0 )
		DllCall("GetLocaleInfo","uint",priLang & 0xFFFF,"uint", 0x1001, "str",sLangName, "uint",260)  ; LOCALE_SENGLANGUAGE=0x1001
		if (strlen(sLangName) < 1) {
			if (KbdAltLang%kk%) {
				local altLang := "0x" . KbdAltLang%kk%
				DllCall("GetLocaleInfo","uint", altLang & 0xFFFF,"uint", 0x1001, "str",sLangName, "uint",260)  ; LOCALE_SENGLANGUAGE=0x1001
				if (sLangName) {
					if (UseAltLangWithoutPrompting) {
						KbdLang%kk% := KbdAltLang%kk%
						goto LangCodeOK
					} else {
						Gui Hide
						TitleString:=GetLang(126) ; Use %sLangName% language for '%ln%' layout?
						LangCode:= KbdLang%kk%
						TempString:= GetLang(127) . " " . LangCode . " " . GetLang(128) . "`n`n" . GetLang(129) . "`n`n" . GetLang(130) . " " . sLangName . " " . GetLang(131) . " " . ln . " " . GetLang(132) ; "The language code " . %LangCode% . " is unknown on this version or service-pack of Windows.`n`nSome applications may not function properly with an unknown language.`n`nWould you like to instead use " . sLangName . " for the '" . ln "' keyboard?"
						MsgBox 4, %TitleString%, %TempString%
						Gui Show
						ifmsgbox Yes
							KbdLang%kk% := KbdAltLang%kk%
						goto LangCodeOK
					}
				}
			}

			Gui Hide
			TitleString:=GetLang(133) . " " . ln ; Unknown language code for layout: %ln%
			LangCode:= KbdLang%kk%
			TempString:= GetLang(127) . " " . LangCode . " " . GetLang(134) . "`n" . GetLang(135) . "`n`n" . GetLang(136) ; "The language code " . %LangCode% . " is unknown on this computer, and you have not configured an alternative for this keyboard.`nSome applications may not function properly with this language.`n`nLoad it anyway?"
			MsgBox 4, %TitleString%, %TempString%
			Gui Show
			ifmsgbox Yes
				goto LangCodeOK
			KbdDisabled%kk% := 1
			goto ProcessKbdErrors
		}

LangCodeOK:
		; Identify the keyboard file settings
		local ff := InStr(KbdFiles, ":" . KbdFile%kk% . A_Tab)
		if (ff) {
			KbdFileID%kk% := substr(KbdFiles, ff - 4, 4) + 0
		} else {
			numKbdFiles++
			KbdFileID%kk% := numKbdFiles
			kFileName%numKbdFiles% := KbdFile%kk%
			KbdFiles .= "   " . KbdFileID%kk% . ":" . KbdFile%kk% . A_Tab
		}
		; first 4 parameters are K_ProtocolNum, InKeyHwnd, FileID, KbdId
		RunCmd%kk% := GetAHKCmd(KbdFile%kk%) . KbdFolder%kk% . "\" . KbdFile%kk% . " " . K_ProtocolNum . " " . selfHwnd . " " . KbdFileID%kk% . " " . kk . " " . KbdParams%kk%

		klid := FindKLID(KbdLayoutName%kk%, KbdLang%kk%)  ; See if keyboard named is registered
		;outputdebug FindKLID => %klid%.
		if (klid) {
			; Keyboard is registered.  Ensure we haven't already used it.
			if (InStr(ProcdKbdList, klid)) {
				Gui Hide
				MsgBox 0, Configuration Error, Each keyboard must have a unique layout name.
				Gui Show
				KbdDisabled%kk% := 1
				goto ProcessKbdErrors
			}
			ProcdKbdList .= klid . " "
			;Ensure it's loaded, and get its HKL.
			KbdHKL%kk% := LoadKeyboardLayout(klid, 16, KbdLayoutName%kk%)
			oKbdByHKL[KbdHKL%kk%] := kk
			;~ Outputdebug % "Kbd# " . kk . " uses registered KLID: " . klid . ", HKL=" . KbdHKL%kk%    ;%
		} else {
			; Keyboard is not registered.
			if (PortableMode)  {
				KbdHKL%kk% := LoadSubstituteKeyboard(KbdLang%kk%, KbdLayoutName%kk%) ; Use a non-registered keyboard instead.
				oKbdByHKL[KbdHKL%kk%] := kk
			} 	else  {
				; Remember this keyboard as one we need to register (once all keyboard settings have been read).
				Kbd2RegCt++
				Kbd2Reg%Kbd2RegCt% := kk
			}
		}

	} else {
		; These are the settings for a non-InKey keyboard  (e.g. System or Keyman etc)
		; Set KbdFile[], KbdKLID[] and KbdHKL[] values
		KbdFile%kk% := ""
		KbdFileID%kk% =
		if (not KbdKLID%kk%)
			KbdKLID%kk% = 00000409
		KbdHKL%kk% := LoadKeyboardLayout(KbdKLID%kk%)
		oKbdByHKL[KbdHKL%kk%] := kk
		Outputdebug % "Kbd# " . kk . " is NON-INKEY. KLID=" . KbdKLID%kk% . ", HKL=" . KbdHKL%kk%    ;%
	}
	;ChangeLanguage(KbdHKL%kk%) ; Should help refresh the Lang Bar

	local hkl := KbdHKL%kk%
	;~ HKLDisplayName%hkl% := RegExReplace(KbdMenuText%kk%, "&") ; Strip the ampersand
	oHKLDisplayName[hkl] := RegExReplace(KbdMenuText%kk%, "&") ; Strip the ampersand

	; Icon settings for this keyboard
	KbdIconFile%kk% := KbdIcon%kk%
	if (KbdIconFile%kk%) {
		; If there is a second parameter (after a comma), separate that out.
		if (RegExMatch(KbdIconFile%kk%, "(.*),\s*(.*)", val)) {
			KbdIconFile%kk% = %val1%
			KbdIconNum%kk% = %val2%
		}

		; If the icon file exists in the keyboard's folder, prepend path.
		if (FileExist(KbdFolder%kk% . "\" . KbdIconFile%kk%))
			KbdIconFile%kk% := KbdFolder%kk% . "\" . KbdIconFile%kk%
		; otherwise hopefully the file is a system DLL
	}
	KbdIcon%kk% =

	local ii := KbdMenuText%kk%
	menu KbdMenu, add, %ii%, KeyboardMenuItem  	; Add menu item for this keyboard
}

RegisterAndLoadKeyboard(kk) {
	global
	local Lang := KbdLang%kk%
	local layoutName := KbdLayoutName%kk%
	local hiword
	local dummy
	local hkl
	local jj

	; Find the first available KLID for this lang
	SetFormat, IntegerFast, H
	Loop 255
	{
		hiword := A_Index  ; save as hex
		KLID := substr("000" . substr(hiword, 3), -3) . Lang
		RegRead dummy, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, Layout File
		if (ErrorLevel)
			break
	}
	StringUpper KLID, KLID

	; Set ID according to the next number after MaxLID
	MaxLID++
	SetFormat, IntegerFast, d
	ID := substr("000" . substr(MaxLID, 3), -3) ; e.g. 0xE -> 000E,  0x9E2 -> 09E2
	StringUpper ID, ID

	; Set the HKL. "F" followed by last 3 chars of ID followed by Lang's 4 chars
	hkl := "0xF" . substr(ID,-2) . Lang

	; Write the registry settings for this layout
	OutputDebug Writing to registry: %KLID%, %ID%, %layoutName%, %UnderlyingLayoutFile%.
	RegWrite REG_SZ, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, InKey, 1
	RegWrite REG_SZ, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, layout file, %UnderlyingLayoutFile%
	RegWrite REG_SZ, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, layout id, %ID%
	RegWrite REG_SZ, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, layout text, %layoutName%
	if errorlevel {
		Outputdebug RegWrite failed
		return 0
	}
	if (Preload)
		RegisterForPreloading(KLID, Lang)

	jj := LoadKeyboardLayout(KLID, 16, layoutName)
	if (jj <> hkl) {
		Outputdebug % "Error loading new kbd# " . A_Index . ". Expected HKL: " . hkl . ". Got HKL: " . jj ; %
		return 0
	} else {
		Outputdebug % "Kbd# " . A_Index . " succesfully registered. LN=" . layoutName . ", KLID=" . klid . ", HKL=" . hkl    ;%
	}
	return hkl
}

RegisterForPreloading(KLID, Lang) {
	; Check if there is a Substitutes item whose data value is already this KLID
	SubstID := ""
	Loop HKCU, Keyboard Layout\Substitutes
	{	RegRead rKLID
		if (rKLID = KLID) {
			SubstID := A_LoopRegName
			break
		}
	}
	; If not found, create one.
	if (not SubstID) {
		setformat integerfast, h
		substNum := 0x0
		Loop {
			SubstID := "d" .  substr("00" . substr(substNum,3), -2) . Lang
			RegRead itExists, HKCU, Keyboard Layout\Substitutes, %SubstID%
			if ErrorLevel
				break  ; we've found an available SubstID
			substNum++
		}
		setformat integerfast, d
		RegWrite REG_SZ, HKCU, Keyboard Layout\Substitutes, %SubstID%, %KLID%
	}
	; Check that there is not already a preload for this substID
	PreloadID := ""
	Loop HKCU, Keyboard Layout\Preload
	{	RegRead rSubstID
		if (rSubstID = SubstID) {
			PreloadID := A_LoopRegName
			break
		}
	}
	; If not found, create one.
	if (not PreloadID) {
		PreloadID := GetNextPreload()
		RegWrite REG_SZ, HKCU, Keyboard Layout\Preload, %PreloadID%, %SubstID%
	}
}

GetNextPreload() {  ; Retrieve the last preload number
	static n = 0
	if (n <> 0)
		return n++
	Loop HKCU, Keyboard Layout\Preload
	{	n := A_LoopRegName + 1
		break
	}
	return n
}

GetAHKCmd(filename) {
	if (SubStr(filename, -3) <> ".ahk")
		return ""	; Not an AHK file.  Must be an EXE.  We'll just run the file as specified.
	return GetAHK() . " "
}

GetAHK() {
	global
	static RunAHK := ""
	static ahkexe := "AutoHotKey.EXE"

	if (RunAHK)
		return RunAHK

	if (FileExist(A_ScriptDir . "\" . ahkexe)) {
		RunAHK := ahkexe
		return RunAHK
	}

	;~ if (FileExist(A_AHKPath)) {
		;~ RunAHK := A_AHKPath
		;~ return RunAHK
	;~ }

	gui hide
	TitleString:=GetLang(137) ; InKey Installation Error. Please reinstall.
	MsgBox 16, ERROR, %TitleString%
	ExitApp
}

ShowKbdMenu:
	gotKbdReq := 0

			; TODO: This is common functionality with DeactivateKbd(). Combine.
		; SetTitleMatchMode Regex
		; DetectHiddenWindows On
		; if WinExist("i)" . ActiveKbdFile . " ahk_class AutoHotkey")
			; PostMessage, 0x8001, 0, 0  ; The message is sent  to the "last found window" due to WinExist() above.
		 ; else
			; Outputdebug Error, could not suspend %ActiveKbdFile%, 2, 3
		; DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
	if (ActiveKbd) {
		ActiveKbdHwnd := GetKbdHwnd(ActiveKbd)
		if (ActiveKbdHwnd)
			DllCall("PostMessage", UInt, ActiveKbdHwnd, UInt, 0x8001)
		else {
			outputdebug Error, could not suspend kbd file: %ActiveKbdFile%
		}
	}
	; if (PutMenuAtCursor)
		Menu KbdMenu, show
	; else
		; Menu KbdMenu, show, %TrayX%, %TrayY%

	if (not gotKbdReq) { ; user must not have selected a keyboard

		; TODO: This is common functionality with DeactivateKbd(). Combine.
		if (ActiveKbd) {
			ActiveKbdHwnd := GetKbdHwnd(ActiveKbd)
			if (ActiveKbdHwnd)
				DllCall("PostMessage", UInt, ActiveKbdHwnd, UInt, 0x8002)
			else {
				outputdebug Error, could not resume kbd file: %ActiveKbdFile%
			}
		}
		; SetTitleMatchMode Regex
		; DetectHiddenWindows On
		; if WinExist("i)" . ActiveKbdFile . " ahk_class AutoHotkey")
			; PostMessage, 0x8002, 0, 0  ; The message is sent  to the "last found window" due to WinExist() above.
		 ; else
			; Outputdebug Error, could not resume %ActiveKbdFile%, 2, 3
		; DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.

	}
	;outputdebug done with menu
	return


FindKLID(layoutName, langID) {  ; If we need access to the other fields besides KLID, we should instead return the A_Index value
	global
	;outputdebug FindKLID(%layoutName%, %langID%) blf=%UnderlyingLayoutFile%
	Loop % RKCt
	{	if (SubStr(RK_KLID%A_Index%, -3) <> langID)	; Skip entries that don't match the langID
			continue
		if (RK_LText%A_Index% = layoutName and RK_LFile%A_Index% = UnderlyingLayoutFile) {
			RK_Used%A_Index% := 1
			UnusedRKCt--
			return RK_KLID%A_Index%
		}
	}
	Return ""
}
/*
FindKLID(layoutName, langID) {
; Find the KLID (identifying a registered layout) for an InKey layout matching the layoutName and LangID.
	Loop HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts, 2 ; 2=retrieve subkeys (not values)
	{	if (SubStr(A_LoopRegName, -4) <> langID)	; Skip entries that don't match the langID
			continue
		RegRead InKeyVal, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, InKey ; See if it has an "InKey" value
		if (InKeyVal) {		; If so, see if the "Layout Text" value matches layoutName
			RegRead ltext, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout Text
			if (ltext = layoutName)
				return A_LoopRegName		; The KLID
		}
	}
	return ""
}
*/

KeyboardMenuItem:
	gotKbdReq := 1
	kbd := KbdByMenuText(A_ThisMenuItem)
	;outputdebug KeyboardMenuItem: KbdByMenuText(%A_ThisMenuItem%) => %kbd%
	RequestKbd(kbd)
	WinActivate ahk_id %hwndLastActive%
	return

DispConfigureMenuItem:
	kbd := KbdByMenuText(A_ThisMenuItem)
	ConfigureKeyboard(kbd)
	return

DispCmdMenuItem:
	kbd := KbdByMenuText(A_ThisMenuItem)

	; dd := KbdFolder%kbd%
	; if %dd%
		; SetWorkingDir %dd%
	RunDisplayCmd := GetAHKCmd(KbdDisplayCmd%kbd%) . KbdDisplayCmd%kbd%
	Run %RunDisplayCmd%
	; SetWorkingDir %A_ScriptDir%
	return

MenuFollow:
	FollowWindowsInputLanguage := not FollowWindowsInputLanguage
	if FollowWindowsInputLanguage
	{
;		menu, tray, check, Follow Language Bar
		ActiveHKL = -1  ; So that it will get reset
	}
	; else
		; menu, tray, uncheck, Follow Language Bar2
	WinActivate ahk_id %hwndLastActive%
	return

GrabContext:
	;global StackIdx
	gosub refreshContext
	;setformat integerfast, d
	si := StackIdx + 0

	TrayTipQ("Grabbed Context: " . si)
;	setformat integerfast, h
	;~ TrayTipQ("non-joined conjunct", "", 20000)

	return

MenuAutoGrab:
	AutoGrabContext := not AutoGrabContext
	if AutoGrabContext
	{
		TempString:=GetLang(5)
		menu, tray, check, %TempString%
		settimer refreshContext, -200
		TempString:=GetLang(5) . " " . OnString
		TrayTipQ(TempString) ; Auto Grab Context is ON
	}
	else {
		TempString:=GetLang(5)
		menu, tray, uncheck, %TempString%
		settimer refreshContext, off
		TempString:=GetLang(5) . " " . OffString
		TrayTipQ(TempString) ; Auto Grab Context is OFF
	}

	; TODO:  Just once per file.    ; Does the keyboard script need to know if AutoGrab is on???
	; SetTitleMatchMode Regex
	; DetectHiddenWindows On
	; Loop %numKeyboards%
	; {
		; f := GetKbdFile(A_Index)
		; if (f and WinExist("i)" . GetKbdFile(A_Index) . " ahk_class AutoHotkey"))
			; PostMessage, 0x8003, AutoGrabContext, 0  ; The  message is sent  to the "last found window" due to WinExist() above.
	; }
	; DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
	; WinActivate ahk_id %hwndLastActive%

	return

; On_WM_ACTIVATE(wparam, lparam) {
	; return 0
; }

RequestKbd(kbd) {
	global
	OUTPUTDEBUG ***** RequestKbd(%kbd%)
	if (kbd = 0 and ActiveHKL = KbdHKL0) {
		;outputdebug user is trying to go to default kbd when InKey thinks default is already on.
		ActiveHKL := ChangeLanguage(GetKbdHKL(0))  ; Set OS locale
		GoSub DoResync
		return
	}
	if (GetKbdHKL(kbd) = ActiveHKL)  { ; ??? Should we call GetActiveHKL here???
		outputdebug % "GetKbdHKL(" . kbd . ") => " . GetKbdHKL(kbd) . ". ActiveHKL = " . ActiveHKL 	 ; %
		; User is requesting this keyboard, but it's supposedly already active.
			; EVENTUALLY: Nothing to do.  We are already set for this locale.  TO DO: Toggle active kbd off, and remember which it was, so we can toggle it back on.
		; FOR NOW: Due to the "improper suspension" bug, let's reinit the keyboard.
		; local hwnd := GetKbdHwnd(kbd)
		; local r = 0
		; if (hwnd)
			; r := DllCall("SendMessage", UInt, hwnd, UInt, 0x8002)

		; if (r <> 2)
			;ReinitKeyboard(kbd) - not previously commented out (versions 0.093 and before)

		; else
			; outputdebug Error, could not resume %ActiveKbdFile%

		; switch to default keyboard
		ActiveHKL := ChangeLanguage(GetKbdHKL(0))
		ActivateKbd(0, ActiveHKL)
		return
	}
	ActiveHKL := ChangeLanguage(GetKbdHKL(kbd))  ; Set OS locale
	ActivateKbd(kbd, ActiveHKL)
}

RequestNextKbd:
	if (ActiveKbd = NumKeyboards)
		RequestKbd(0)
	else
		RequestKbd(ActiveKbd + 1)
	return

RequestPrevKbd:
	if (ActiveKbd < 1)
		RequestKbd(NumKeyboards)
	else
		RequestKbd(ActiveKbd - 1)
	return


 ; Slow but sure method to refresh the language bar
RefreshLangBar() {
	; Open and close the "Text Services and Input Languages" dialog ("Languages" window in Win8)
	OutputDebug RefreshLangBar
	DetectHiddenWindows on
	CoordMode mouse
	global  titleTSIL
	titleTSIL := A_OSVersion = "WIN_8" ? "Language" : "Text Services and Input Languages"
	MouseGetPos mouseX, mouseY
	Run control.exe input.dll,
	;~ WinWait, %titleTSIL%, , 10
	WinWaitActive, %titleTSIL%, , 6
	MouseMove mouseX, mouseY, 0
	if not errorlevel {
		WinClose %titleTSIL%
	} else {
		SetTimer  CLOSELANGUAGES, -1
		; we won't hold the current thread up any longer than this
	}
	DetectHiddenWindows off
}

CLOSELANGUAGES:
; Languages window was not closed.  We'll try harder now.
outputdebug Trying harder to close the Languages window
WinWait, %titleTSIL%, , 15
WinClose %titleTSIL%
return

DoResync:
	SetTimer CHECKLOCALE, Off
	Loop % numKbdFiles
	{
		fHwnd := KbdFileHwnd%A_Index%
		sv := 0
		if (fHwnd) {
			sv := DllCall("SendMessage", UInt, fHwnd, UInt, 0x8003)
			outputdebug sent MsgClose to file # %a_index%
		}
		KbdFileHwnd%A_Index% = 0
	}
	; now make sure it worked
	SetTitleMatchMode Regex
	DetectHiddenWindows On
	tries := 0
	Loop
	{
		tries++
		if (tries > 100) {
			TempString:=GetLang(144) ; Error while attempting to reset keyboards.
			TrayTipQ(TempString)
			return
		}
		kf := 0
		Loop % numKbdFiles
		{
			f := kFileName%A_Index%
			if (f and WinExist("i)" . f . " ahk_class AutoHotkey")) {
				outputdebug trying to close %f%
				PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
				PostMessage, 0x112, 0xF060
				kf++
			}
		}
		if (not kf)
			break
	}
	DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.
	ActiveHKL = 0
	SetTimer CHECKLOCALE, 500
	gosub CHECKLOCALE
	TempString:=GetLang(11)
	TrayTipQ(TempString)  ; Keyboards have been reset
	return

DoReload:
Suspend off
reload  ; Reload (Useful when making frequent changes to script)
return

DoExit:
	ExitApp

DoCleanup:  ; Called onExit
	; Set all top-level windows to the default HKL  (TODO: Cycle through all windows, and only do this to windows with InKey-loaded HKLs)
	If (not LeaveKeyboardsLoaded)
		DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; KbdHKL0  0x50 = WM_INPUTLANGCHANGEREQUEST

	SetTitleMatchMode Regex
	DetectHiddenWindows On
	Loop %numKeyboards%
	{
		f := GetKbdFile(A_Index)
		if (f and WinExist("i)" . GetKbdFile(A_Index) . " ahk_class AutoHotkey"))
			PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
	}
	DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.

	if (InkeyLoadedHKLs and not LeaveKeyboardsLoaded) {

		; We unload any keyboards that InKey loaded
		outputdebug InkeyLoadedHKLs = %InkeyLoadedHKLs%
		Loop %numKeyboards%
		{
			hkl := GetKbdHKL(A_Index)
			setformat IntegerFast, hex
			hkl += 0
			setformat IntegerFast, dec
			if (hkl and InStr(InkeyLoadedHKLs, hkl)) {
				; Outputdebug Unloading hkl %hkl%
				DllCall("UnloadKeyboardLayout","uint",hkl)
			} else {
				outputdebug HKL %hkl% was not unloaded (kbd = %A_Index%)
			}
		}

		if (not InStr("Shutdown Logoff Reload Single", A_ExitReason)) {  ; No need to refresh Lang Bar if we're restarting InKey or shutting down the workstation.
			IniRead ii, InKey.ini, InKey, RefreshLangBarOnExit, %A_Space%
			if (ii)
				RefreshLangBar()
			else {
				; A trick to refresh the language bar for all top-level windows.
				; Fast and invisible, but might leave "Unknown language" as an inactive option in the LangBar
				DllCall("UnloadKeyboardLayout","uint",0x40905fe)
				x := LoadKeyboardLayout("000005FE")
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, x)  ; KbdHKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
				DllCall("UnloadKeyboardLayout","uint",KbdHKL0)
				klid := "0000" . A_Language
				KbdHKL0 := LoadKeyboardLayout(klid, 18)
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; KbdHKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
				DllCall("UnloadKeyboardLayout","uint",x)
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; KbdHKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
			}
		}
	}
	DllCall("FreeLibrary", unit, hMSVCRT)
	ExitApp

DoHelp:
	Run InKey.chm
	return


DeactivateKbd() {
	global
	if (ActiveKbd) {
		local kbdHwnd := GetKbdHwnd(ActiveKbd)
		local sv := 0
		if (kbdHwnd)
			sv := DllCall("SendMessage", UInt, kbdHwnd, UInt, 0x8001)
		if (sv <> 3)
			outputdebug ***Error: could not suspend %ActiveKbdFile%
		LastActiveKbd := ActiveKbd
	}
;	ActiveKbd = 0
	ActiveKbdFile =
	ActiveKbdHwnd =
}


OnKbdHotKey:
	hhh := A_ThisHotkey
	kkk := KbdByHotKey(hhh)
	outputdebug Hotkey %hhh% => RequestKbd(%kkk%)
	RequestKbd(KbdByHotkey(A_ThisHotkey))
	return

CHECKLOCALE:
	;WinGetClass at, A
	la := WinExist("A")   ; Remember the active window as hwndLastActive, unless we are the active window.
	;outputdebug la = %la%, at = %at%

	if (la = hwndTray)
		return

	if (la <> SelfHwnd) and (la <>0) {
		if (la <> hwndLastActive) {
			outputdebug Active window changed from %hwndlastactive% to %la%
			hwndLastActive := la
			initContext()
		}
	}

	; see also BOOL IsWindowEnabled(hwnd) http://msdn.microsoft.com/en-us/library/ms646303(VS.85).aspx
; don't update hwndLastActive if la = 0 or if class = Shell_TrayWnd !!!!!!!11
	if (not FollowWindowsInputLanguage)
		return

	loc := GetActiveHKL()
	if (loc = ActiveHKL) {
		;outputdebug loc: %loc%, activehkl: %activehkl%
		return		; Nothing to do.  We are already set for this locale.
	}
	; Otherwise, we probably need to change keyboards.
	setformat integerfast, h
	loc += 0
	outputdebug ***Locale change: %ActiveHKL% to %loc%
	outputhwnddetails(hwndLastActive, " for the sake of ")
	setformat integerfast, d
	; First, though, if lang is unchanged (only layout), and InKey itself changed the lang only an instant ago, this is a case of Windows changing it to a "default" layout for the lang, and we need to reset it.
	if ((loc & 0xFFFF = ActiveHKL & 0xFFFF) and (A_Tickcount - LastKbdActivationTC < 1000)) {
		diff := A_Tickcount - LastKbdActivationTC
		outputdebug Actually, this must be have been a case of Windows switching layout behind our backs. We'll reset it. %A_TickCount%, %LastKbdActivationTC%, %diff%
		ChangeLanguage(ActiveHKL, 0)
		return
	}
	ActiveHKL := loc
	if ((ActiveHKL & 0xffff ) <> 0x05FE)  { ; We never try to follow the language called "Unknown".
		ActivateKbd(KbdByHKL(ActiveHKL), ActiveHKL)
	}
	return

ReinitKeyboard(n) {
	; NOT global
	initContext()
	s := n . "|" . GetKbdParams(n)
	rk := Send_WM_COPYDATA(n, 0x9201, s)
	outputdebug ReinitKeyboard(%n%) Send_WM_COPYDATA => %rk%  .  s = "%s%"
	if (rk=3)  ; Means that InKeyLib.ahki received and processed it OK.
		return 0
	else
		SoundPlay *32	;
	return 1
}

SetActiveKbd(kbd) {
	global
	local ii
	if (ActiveKbd = -1) {
		ActiveKbd := kbd
		return
	}

	ii := KbdMenuText%ActiveKbd%
	Menu KbdMenu, UseErrorLevel
	if (not ii)
		outputdebug ERROR: No KbdMenuText%activekbd%
	Menu KbdMenu, Uncheck, %ii%
	ActiveKbd := kbd
	ii := KbdMenuText%ActiveKbd%
	Menu KbdMenu, Check, %ii%
}


ActivateKbd(kbd, hkl) {
	global

	if (not KbdFile%kbd%) {  ; If new locale does not map to an InKey keyboard...
		if (ActiveKbd > 0 and KbdFile%ActiveKbd%) 	; If there was already an active InKey keyboard,
			DeactivateKbd()		;  deactivate it.
		; if (KbdIconFile%kbd%)
			; Menu Tray, Icon, KbdIconFile%kbd%, KbdIconNum%kbd%
		; else if (kbd = 0)
			; Menu, Tray, Icon, Shell32.dll, 76
		; else
			; Menu, Tray, Icon, input.dll, 2
		TrayIcon(kbd, hkl)
		SetActiveKbd(kbd)
		ActiveKbdFile := ""
		ActiveKbdHwnd := 0
		return
	}
	; Otherwise, there is a different keyboard we should switch to.
	local NewKbdFile := GetKbdFile(kbd)

	if (ActiveKbd) and (NewKbdFile <> ActiveKbdFile) {
		DeactivateKbd()	 ; Deactivate the currently active keyboard if in a different file
	}

	SetActiveKbd(kbd)
	ActiveKbdFile := NewKbdFile
	ActiveKbdHwnd := GetKbdHwnd(kbd)
	RunFresh = 1
	if (ActiveKbdHwnd) {	; If keyboard file is already loaded,
		RunFresh := ReinitKeyboard(kbd) 	; just reinitialize it
		; outputdebug ReinitKeyboard returned %RunFresh%
	}

	if (RunFresh) {
		kbdid := KbdFileID%kbd%
		; NewKbdParams := selfHwnd . " " . KbdFileID%kbd% . " " . kbd . " " . GetKbdParams(kbd)
		;;first 3 parameters are InKeyHwnd, FileID, KbdId
		; if (SubStr(NewKbdFile, -3) = ".ahk")
			; RunCmd := "AutoHotKey.exe "
		; else
			; RunCmd =
		; RunCmd .= KbdFolder%kbd% . "\" . NewKbdFile . " " . NewKbdParams
		RunCmd := RunCmd%kbd%
	DllCall("QueryPerformanceCounter", "Int64 *", CounterBefore)
		Run %RunCmd%,  ,  UseErrorLevel, OutputVarPID
		if (ErrorLevel) {
			TitleString:=GetLang(145) ; Error
			TempString:= GetLang(146) . kbd . "`n" . GetLang(147) . "`n" . RunCmd ; Unable to launch keyboard #%kbd%,`nbecause the following command failed:`n%RunCmd%
			MsgBox 16, %TitleString%, %TempString%
			requestkbd(0)
			return
		}
		KbdFileHwnd%kbdid% = 0
		outputdebug Launched %RunCmd% => %OutputVarPID%
		DetectHiddenWindows On
		if (OutputVarPID) {
			WinWait ahk_pid %OutputVarPID%, , 10
			if errorlevel {
				outputdebug winwait timed out
			} else {
				WinGetClass cl
				if (cl = "#32770") {
					sleep 500
					TitleString:=GetLang(145) ; Error
					TempString:= GetLang(148) . " " . NewKbdFile . ".`n`n" . GetLang(149) ; There seems to be a problem with launching "%NewKbdFile%".`n`nWould you like switch to the default keyboard?
					MsgBox 52, %TitleString%, %TempString%
					IfMsgBox Yes
					{	DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KbdHKL0)  ; Change all windows to default lang.
						ActivateKbd(0, KbdHKL0)
						return
					}
				} else {
					KbdFileHwnd%kbdid% := WinExist("ahk_pid " . OutputVarPID)
					OutputDebug % "KbdFileHwnd" . kbdid . "=" . KbdFileHwnd%kbdid%
					;DllCall("SendMessage", "UInt", KbdFileHwnd%kbdid%, UInt, 0x8100)
				}
				; WinGetTitle tt
				; wingettext tx
				; outputdebug pid = %OutputVarPID%, title = %tt%, text = %tx%, class = [%cl%]
			}
		}
		DetectHiddenWindows Off
	}
	TrayIcon(kbd, hkl)
}


TrayIcon(kbd, hkl) {
	global
	;~ outputdebug trayicon(%kbd%, %hkl%)
	setformat integerfast, H
	TempHKL:=hkl+0
	SetFormat IntegerFast, D
	;~ if (not HKLDisplayName%TempHKL%)
	OutputDebug % "temphkl=" temphkl " ohkldisplayname=>" oHKLDisplayName[TempHKL]
	if (not oHKLDisplayName[TempHKL])
		oHKLDisplayName[TempHKL] := GetHKLDisplayName(TempHKL)
	;~ local tipTxt := "InKey" . (HKLDisplayName%TempHKL% ? " - " . HKLDisplayName%TempHKL% : "")
	local tipTxt := "InKey" . (oHKLDisplayName[TempHKL] ? " - " . oHKLDisplayName[TempHKL] : "")
	menu tray, tip, %tipTxt%
	if (oHKLDisplayName[TempHKL] and ShowKeyboardNameBalloon)
		TrayTipQ(oHKLDisplayName[TempHKL])
	if (kbd = 0) {
		Menu, Tray, Icon, Shell32.dll, 76
		return
	}
	local ff := GetKbdIconFile(kbd)
	local nn := GetKbdIconNum(kbd)
	if (ff) {
		menu tray, useerrorlevel
		Menu Tray, Icon, %ff%, %nn%
		if errorlevel
			Menu, Tray, Icon, input.dll, 2
		menu tray, useerrorlevel, off
	} else
		Menu, Tray, Icon, input.dll, 2
}


; Get HWND to keyboard (if active)
GetKbdHwnd(n) {
	global
	if (n = 0)
		return ""
	local kbdid := KbdFileID%n%
	if (not KbdFileHwnd%kbdid%)
		return 0
	local kbdHwnd := WinExist("ahk_id " . KbdFileHwnd%kbdid%) ; TODO Faster: DllCall IsWindow
	if (kbdHwnd)
		return kbdHwnd

	local Prev_DetectHiddenWindows := A_DetectHiddenWindows
	local Prev_TitleMatchMode := A_TitleMatchMode
	SetTitleMatchMode Regex
	DetectHiddenWindows On
	kbdHwnd := WinExist("i)" . GetKbdFile(n) . " ahk_class AutoHotkey")
	DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
	SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
	;~ ss := GetKbdFile(n)
	;~ outputdebug GetKbdHwnd(%n%) => %ss% => %kbdHwnd%
	return kbdHwnd
}


;===============================================++++==============================
; Look-ups

KbdByHKL(hkl) {
	global
	if (oKbdByHKL.HasKey(hkl))
		return oKbdByHKL[hkl]
	;~ outputdebug % "$$$$$ Looking for keyboard with HKL=" . hkl . ", number of keyboards=" . numKeyboards . ". oKbdByHKL => " . oKbdByHKL[hkl]
	;~ Loop %numKeyboards%
	;~ {
		;~ TempString:=GetKbdHKL(A_Index)
		;~ SetFormat, IntegerFast, H
		;~ HexString:=TempString
		;~ SetFormat, IntegerFast, D
		outputdebug Count=%A_Index%, Trying %HexString%
		;~ if (HexString = hkl)
		;~ {
			;~ OutputDebug % "KbdByHkl(" . hkl . ") returns " . A_Index  . ".  oKbdByHKL[] is " . oKbdByHKL[hkl]
			;~ return %A_Index%
		;~ }
	;~ }
	outputdebug Attempt to look up Kbd by HKL of %hkl% failed, so returning default Kbd (0).
	return 0
}

KbdByMenuText(mtxt) {
	global
	;outputdebug KbdByMenuText(%mtxt%)
	Loop %numKeyboards%
	{	kk := KbdMenuText%A_Index%
		;outputdebug kbdbymenutext trying KbdMenuText%A_Index% => %kk%
		if (KbdMenuText%A_Index% = mtxt)
			return %A_Index%
	}
	;outputdebug KbdByMenuText: no match
	return 0
}

KbdByLayoutName(mtxt) {
	global
	;outputdebug KbdByLayoutName(%mtxt%)
	Loop %numKeyboards%
	{	kk := KbdLayoutName%A_Index%
		;outputdebug kbdbyLayoutName trying KbdLayoutName%A_Index% => %kk%
		if (KbdLayoutName%A_Index% = mtxt)
			return %A_Index%
	}
	;outputdebug KbdByLayoutName: no match
	return 0
}

KbdByHotkey(hk) {
	global
	Loop %numKeyboards%
	{
		if (GetKbdHotkey(A_Index) = hk)
			return %A_Index%
	}
	return 0
}

;===============================================++++==============================

GetKbdHKL(n) {
	return KbdHKL%n%
}

GetKbdFile(n) {
	return KbdFile%n%
}

GetKbdHotkey(n) {
	return KbdHotkey%n%
}

GetKbdIconFile(n) {
	return KbdIconFile%n%
}

GetKbdIconNum(n) {
	return KbdIconNum%n%
}

GetKbdParams(n) {
	return KbdParams%n%
}

/*
The LoadKeyboardLayout() API function is given an 8-character string that identifies a locale
by the name of its key under HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts
e.g. "00010409" is the first (0001) alternate keyboard for US English (0409), namely Dvorak.
This 8-character string is called the KLID.

The LoadKeyboardLayout() API function returns a 32-bit value (representing a locale) called the HKL, not to be confused with the KLID,
especially in AHK where numbers are represented with strings.
The low word of the HKL represents the language, and the high word represents the device.  In the case of alternate
keyboards, this device identifier is produced by taking the string value named "layout id" from under the keyboard's registry key,
converting it to a number (the string represents the hex value), and adding 0xf000.
In the case of a language's default keyboard, the high word will typically be the language code.

The HKL is the number sent with a WM_INPUTLANGCHANGE message, or returned by the
GetKeyboardLayout() API function.


Some API constants:
 HKL_PREV = 0
 HKL_NEXT = 1

 KLF_ACTIVATE       = 1
 KLF_SUBSTITUTE_OK  = 2
 KLF_UNLOADPREVIOUS = 4
 KLF_REORDER        = 8
 KLF_REPLACELANG    = 16
 KLF_NOTELLSHELL    = 128
 KLF_SETFORPROCESS  = 256
 KL_NAMELENGTH      = 9

 WM_INPUTLANGCHANGEREQUEST = 0x50
 WM_INPUTLANGCHANGE = 0x51

*/

LoadKeyboardLayout(KLID, Flags=16, layoutName="") {
	global	; preLoadedHKLs  InkeyLoadedHKLs
	SetFormat, IntegerFast, H
	local jj := DllCall("LoadKeyboardLayout", "Str", KLID, "UInt", Flags) & 0xffffffff
	;outputdebug LoadKeyboardLayout(%KLID%, %Flags%) returned HKL: %jj%
	if (not InStr(preLoadedHKLs, jj)) and (not InStr(InkeyLoadedHKLs, jj)) {
		InkeyLoadedHKLs := InkeyLoadedHKLs . jj . " "
		loadedHKLs := loadedHKLs . jj . " "
		hklStr := substr("0000" . substr(jj,3), -7)  ; format hkl as a zero-padded string (minus the 0x prefix)
		RegWrite REG_SZ, HKCU, Software\InKey\SubstituteLayoutNames, %hklStr%, %layoutName%
	}
	; outputdebug InkeyLoadedHKLs = %InkeyLoadedHKLs%, preLoadedHKLs = %preLoadedHKLs%
	LastLoadedHKL := jj
	SetFormat, IntegerFast, D
	return jj
}

ChangeLanguage(LoadedHKL, SetTickCount=1) {
	global hwndLastActive
	global LastKbdActivationTC
	if (not LoadedHKL)
		outputdebug ***ERROR: ChangeLanguage(<no LoadedHKL>)
	outputHwndDetails(hwndLastActive, "Send LANGCHG " . LoadedHKL . " to:")
	repeatCt := 0
	if (SetTickCount)
		LastKbdActivationTC := A_TickCount
TryLangChgAgain:
	DllCall("SendMessage", "UInt", hwndLastActive, UInt, 0x50, UInt, 1, UInt, LoadedHKL)  ; 0x50 = WM_INPUTLANGCHANGEREQUEST
	ThreadID := DllCall("GetWindowThreadProcessId", "UInt", hwndLastActive, "UInt", 0)
	SetFormat, IntegerFast, H
	ResultingHKL := DllCall("GetKeyboardLayout", "UInt", ThreadID) & 0xffffffff
	outputdebug ResultingHKL: %ResultingHKL% ; this line is actually necessary to make the hexadecimal format "take"
	SetFormat, IntegerFast, D
	if (LoadedHKL <> ResultingHKL) {
		repeatCt++
		outputdebug Warning: After attempt #%repeatCt% to set locale to %LoadedHKL%, HKL was %ResultingHKL%.
		if (repeatCt < 10) {
			sleep (repeatCt-1) * 70
			goto TryLangChgAgain
		} else {
			if (SetTickCount)
				LastKbdActivationTC = 0
			outputdebug ***ERROR: TOO MANY FAILURES TO GET THIS APP TO ACCEPT LANG CHG.
		}
	}
	return ResultingHKL
}

GetActiveHKL() {
	WinGet, WinID,, A
	ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID) & 0xffffffff
	; outputdebug GetActiveHKL() =>  %InputLocaleID%
	return InputLocaleID
}

;---------------------------------------------------------------------
; LoadSubstituteKeyboard(lang, ByRef layoutName)
;   lang    -  4 character string containing language code.  e.g. "04FF" for Sanskrit

;  Loads the keyboard, registering a substitute in HKCU\Keyboard Layout\Substitutes if necessary.
;  Returns the HKL which can be used to activate the keyboard for a window using SendMessage with WM_INPUTLANGCHANGEREQUEST,
;  (as within the ChangeLanguage() function) or to unload the keyboard.
LoadSubstituteKeyboard(lang, ByRef layoutName) {
	global UnderlyingLayout
;outputdebug loadsubst %lang%, %layoutName%
	; static FirstTime := 1
	; if (FirstTime) {
		; RegDelete HKCU, Software\InKey\SubstituteLayoutNames
		; FirstTime := 0
	; }
	layout := UnderlyingLayout
	klidL := ""
	Loop HKCU, Keyboard Layout\Substitutes
	{
		if (SubStr(A_LoopRegName,-3) = lang) {
			RegRead kbdL
			if (kbdL = layout) {
				klidL := A_LoopRegName
				break
			}
		}
	}
;outputdebug klidL = %klidL%
	if (not klidL) {
		; There is not already a substitute registered to map lang to the plain keyboard.
		klidL=0000%lang%
		RegRead xx, HKCU, Keyboard Layout\Substitutes, %klidL%
		if (not Errorlevel) {
			i := 0
			Loop
			{	; Find the next available (not yet existing) KLID, starting with d000
				klidL := "d00" . i . lang
				RegRead xx, HKCU, Keyboard Layout\Substitutes, %klidL%
				if Errorlevel
					break
				i++
			}
		}
		; OutputDebug KLID to create: %klidL%
		RegWrite REG_SZ, HKCU, Keyboard Layout\Substitutes, %klidL%, %layout%
	}
;outputdebug now klidL = %klidL%
	hklL := LoadKeyboardLayout(klidL, 18, layoutName)
	;hklStr := substr("0000" . substr(hklL,3), -7)  ; format hklL as a zero-padded string (minus the 0x prefix)
	;RegWrite REG_SZ, HKCU, Software\InKey\SubstituteLayoutNames, %hklStr%, %layoutName%
;outputdebug hklL = %hklL%
	return hklL
}



; CLEARCONTEXT:
; if (stackIdx > 0 and ActiveKbdFile) { ; if there is any context
	; initContext()
	; TrayTipQ("Context has been cleared")
; } else {
	; Send {%A_ThisHotkey%}
; }
; return
; Optional hotkey to clear the context.  Press again to obtain the key's ordinary meaning.
; Recommended options are Esc / Pause / PrintScreen
;ClearContextHotkey=Esc

;~ ̃~^BackSpace::
~LButton::
~^BS::
~Ins::
~Del::
~*Left::
~*Right::
~*Down::
~*Up::
~*Home::
~*End::
~*PgUp::
~*PgDn::   ; BUG:  And there is an active Kbd??
	; outputdebug arrow key: ucg = %AutoGrabContext%
	if (ActiveKbdFile) {
		if (AutoGrabContext)
			settimer refreshContext, -300
		else
			initContext()
	}
	; if (FollowWindowsInputLanguage)		; NOT SURE WHY WE NEEDED THIS
		; gosub CHECKLOCALE	; CMTD OUT 8/27/08

	return
/*
~LShift & ^!#F12::return

LShift::
	if (dblTap = 1)
		msgbox dbl lshift
	else {
		dblTap = 1
		SetTimer DoubleTapTimer, -400
	}
 return
*/
Nothing:
	return

DblTapDefKbd:
	if (dblTap = 1) {
		RequestKbd(0)
		dblTap =
	} else {
		dblTap = 1
		SetTimer DoubleTapTimer, -400
	}
	return

DblTapNextKbd:
	if (dblTap = 2) {
		GoSub RequestNextKbd
	} else {
		dblTap = 2
		SetTimer DoubleTapTimer, -400
	}
	return

DblTapPrevKbd:
	if (dblTap = 3) {
		GoSub RequestPrevKbd
	} else {
		dblTap = 3
		SetTimer DoubleTapTimer, -400
	}
	return

DblTapMenuKbd:
	if (dblTap = 4) {
		GoSub ShowKbdMenu
		dblTap =
	} else {
		dblTap = 4
		SetTimer DoubleTapTimer, -400
	}
	return

DoubleTapTimer:
	dblTap =
	return

/*
; Detection of single, double, and triple-presses of a hotkey.
;$~LControl up::
TapCounter:
	if tap_presses > 0 ; SetTimer already started, so we log the keypress instead.
	{
		tap_presses += 1
		return
	}
	; Otherwise, this is the first press of a new series. Set count to 1 and start
	; the timer:
	tap_presses = 1
	SetTimer, TapTimer, 400 ; Wait for more presses within a 400 millisecond window.
	return

TapTimer:
	SetTimer, TapTimer, off
	if tap_presses = 1 ; The key was pressed once.
	{
		;Run, m:\  ; Open a folder.
	}
	else if tap_presses = 2 ; The key was pressed twice.
	{
		RequestKbd(0)
	}
	else if tap_presses > 2
	{
		 MsgBox, Three or more taps detected.
	}
	; Regardless of which action above was triggered, reset the count to
	; prepare for the next series of presses:
	tap_presses = 0
	return
*/
; #F6::
; menu tray, show
; return

; A debug routine
outputHwndDetails(hwnd, intro = "") {
	DetectHiddenWindows on
	wingetclass class, ahk_id %hwnd%
	wingettitle title, ahk_id %hwnd%
	;wingettext text, ahk_id %hwnd%

			WinGet, WinID,, A
			ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)

	outputdebug %intro% hwnd: [%hwnd%] class: [%class%] activepid: [%ThreadID%] Title: [%title%] ; and text [%text%]
	DetectHiddenWindows off
}


TrayTipQ(txt, title="", ms=2000) {
   traytip %title%,%txt%
   SetTimer REMOVE_TRAYTIP, %ms%
	return
}

REMOVE_TRAYTIP:
	SetTimer REMOVE_TRAYTIP,off
	traytip
	return
/*
U8Tip(utf8, period=2000) {
	global tipHwnd
	global PreviewAtCursor
	UTF8ToWide(wideTxt, utf8)
	Gui, 2:Hide
	DllCall("SendMessageW", "UInt", tipHwnd,  "UInt", 0x0C, "UInt", 0, "Uint", &wideTxt)  ; 0x0C = WM_SETTEXT
	if (PreviewAtCursor) {
		MouseGetPos mouseX, mouseY
		mouseX -= 45  ; 35 + margin*2
		;outputdebug Gui, 2:Show, x%mouseX% y%mouseY% NoActivate
		Gui, 2:Show, x%mouseX% y%mouseY% NoActivate
	} else
		Gui, 2:Show, NoActivate
	p := period * -1
	setTimer HIDE_U_TIP, %p%
}
*/
UTip(byref wideTxt, period=2000) {
	global tipHwnd
	global PreviewAtCursor
;	UTF8ToWide(wideTxt, utf8)
	Gui, 2:Hide
	DllCall("SendMessageW", "UInt", tipHwnd,  "UInt", 0x0C, "UInt", 0, "Uint", &wideTxt)  ; 0x0C = WM_SETTEXT
	if (PreviewAtCursor) {
		SetFormat integerfast, d
		MouseGetPos mouseX, mouseY
		mouseX -= 45  ; 35 + margin*2
		;outputdebug Gui, 2:Show, x%mouseX% y%mouseY% NoActivate
		Gui, 2:Show, x%mouseX% y%mouseY% NoActivate
	} else
		Gui, 2:Show, NoActivate
	p := period * -1
	setTimer HIDE_U_TIP, %p%
}

CreateUTip() {
	local x
	CoordMode mouse
	SysGet mon, MonitorWorkArea
	tipWidth := 35	; maybe these should be user prefs??
	tipHeight := 20
	x := monRight - tipWidth
	y := monBottom - tipHeight - 10
	Gui, 2:+AlwaysOnTop +Owner -Caption ; +Owner avoids a taskbar button.
	Gui 2:margin, 5, 5
	Gui, 2:Color, FFFF99
	Gui 2:Font, s16
	Gui, 2:Add, Text, x0 y0 hwndtipHwnd1 center w%tipWidth% h%tipHeight% BackgroundTrans
	Gui, 2:Show, Hide x%x% y%y%  ; NoActivate avoids deactivating the currently active window.
	return tipHwnd1
}

HIDE_U_TIP:
Gui 2:Hide
return

;=========================================================



refreshContext:
	outputdebug %A_ScriptName% refreshContext, ucg = %AutoGrabContext%
	ClipSaved := ClipboardAll   ; Save the entire clipboard to a variable
	clipboard =
	initContext()
	Send +{Left}^c			; Send Shift+Left to select, and then Ctrl+C to copy
	ClipWait 2	; Wait for clipboard
	if (errorlevel) {
		outputdebug No clipboard text found for refreshContext.
	} else {
		Send {Right}  ; To unselect text to the left
		x := clipboard
		refreshStack(x)
	}
	Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
	ClipSaved =   ; Free the memory in case the clipboard was very large.
	showstack()
	return


/*
GetLoadedHKLs() { ; Returns a string containing space-delimited hex representation of loaded HKLs
	s := ""
	HKLnum:=DllCall("GetKeyboardLayoutList","uint",0,"uint",0)
	VarSetCapacity( HKLlist, HKLnum*4, 0 )
	DllCall("GetKeyboardLayoutList","uint",HKLnum,"uint",&HKLlist)
	setformat integerfast, hex
	loop %HKLnum%
	{
		hkl:= NumGet( HKLlist, (A_Index-1)*4 )
		s .= hkl . " "
	}
	setformat integerfast, dec
	return s
}
*/

; This does 2 things really:  Initializes preLoadedHKLs and returns the HKL of the default kbd.
; preLoadedHKLs will be a string containing space-delimited hex representation of loaded HKLs.
GetDefaultHKL() {
	global preLoadedHKLs

	SetFormat, IntegerFast, H
	defHKL := TryGetDefaultHKL()
	SetFormat, IntegerFast, D
	outputdebug defHKL => %defHKL%
	defHKLIsValid := 0

	preLoadedHKLs := ""
	HKLnum:=DllCall("GetKeyboardLayoutList","uint",0,"uint",0)
	VarSetCapacity( HKLlist, HKLnum*4, 0 )
	DllCall("GetKeyboardLayoutList","uint",HKLnum,"uint",&HKLlist)
	SetFormat, IntegerFast, H
	loop %HKLnum%
	{
		tmpHkl:= NumGet( HKLlist, (A_Index-1)*4 )
		if (defHKL = tmpHkl)
			defHKLIsValid := 1
		preLoadedHKLs .= tmpHkl . " "
	}
	global loadedHKLs := preLoadedHKLs
	SetFormat, IntegerFast, D
	outputdebug Preloaded HKLs: %preLoadedHKLs%

	if (defHKLIsValid)
		return defHKL
	outputdebug ERROR: Unable to match the default HKL to a loaded HKL.
	return LoadKeyboardLayout("0000" . A_Language, 18) ; May mess up if default lang has more than one keyboard.
}

TryGetDefaultHKL() {
	VarSetCapacity(defhkl, 4, 0)
	dllcall("SystemParametersInfo", UINT, 89, UINT, 0, UINTP, defhkl, UINT, 0) ; SPI_GETDEFAULTINPUTLANG = 89
	;SetFormat, IntegerFast, H
	;defhkl := defhklbuf + 0
	;defhkl += 0
	;SetFormat, IntegerFast, D
	outputdebug defhkl = %defhkl%
	return defhkl
/*  This is a method of calculating the default HKL via the registry:

	RegRead plklid, HKCU, Keyboard Layout\Preload, 1
	if (Errorlevel) {
		outputdebug ERROR: preload\1
		return 0
	}
	langID := SubStr(plklid, -3)
	RegRead klid, HKCU, Keyboard Layout\Substitutes, %plklid%
	if (Errorlevel)
		return "0x" . langID . langID
	klidval := "0x" . klid
	if (klidval < 0x1000)
		return "0x" . SubStr(klid, -3) . langID
	RegRead LayoutID, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%klid%, Layout ID
	if (Errorlevel) {
		outputdebug ERROR: Keyboard Layouts\%klid%\Layout ID
		return 0
	}
	return "0xf" . SubStr(LayoutID, -2) . langID
*/
}

GetRegisteredKbds() {
	; Loop backwards through the Keyboard Layout KLIDs, remembering the InKey keyboards, and the highest Layout ID encountered.
	global
	RKCt := 0
;	RKList := ""
;	local ltxt
	maxLID = 0
	local LID
	Loop HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts, 2 ; 2=retrieve subkeys (not values)
	{	if (SubStr(A_LoopRegName, 1, 4) = "0000")	; Stop when we reach the 0000nnnn entries.
			break
		RegRead LID, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout ID	; Keep track of the highest Layout ID we encounter
		LID := "0x" . LID
		if (LID > maxLID)
			maxLID := LID
		RegRead InKeyVal, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, InKey ; See if this KLID has an "InKey" value
		if (InKeyVal) {
			RKCt++
			RK_KLID%RKCt% := A_LoopRegName
			RK_LID%RKCt% := LID
			RegRead RK_LText%RKCt% , HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout Text
			RegRead RK_LFile%RKCt% , HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout File
			; RegRead ltxt, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout Text
			; RegKbdLayoutText%RKCt% := ltxt
		}
	}
	UnusedRKCt := RKCt
}

GetHKLDisplayName(HKL) {  ; Should only be called AFTER all keyboards have been loaded
	global loadedHKLs
	setformat integerfast, H
	HKL += 0
	LayoutID := SubStr("00000" . SubStr(HKL, 3), -7, 4)  ; e.g. f01c from 0xf01c0409
	RegRead DispLayoutName, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\0000%LayoutID%, Layout Text ; Check basic layout
;outputdebug %DispLayoutName% <- RegRead DispLayoutName, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\0000%LayoutID%, Layout Text ; Check basic layout
	if (not DispLayoutName) { ; Search through extended layouts
		ID2match := "0" . SubStr(HKL,4,3)
		Loop HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts, 2 ; 2=retrieve subkeys (not values)
		{	if (SubStr(A_LoopRegName, 1, 4) = "0000")	; Stop when we reach the 0000nnnn entries.
				break
			RegRead LID, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout ID	; Keep track of the highest Layout ID we encounter
			if (LID = ID2match) {
				RegRead DispLayoutName, HKLM, %A_LoopRegSubKey%\%A_LoopRegName%, Layout Text
				break
			}
		}
	}

	; Check if this is the only loaded HKL using its layout.
	LayoutID := SubStr(HKL, 1, strlen(HKL) - 4)  ; e.g. 0xf01c
	StringReplace xx, loadedHKLs, %LayoutID%, , UseErrorLevel  ; ErrorLevel will contain the count of occurrences
	;~ outputdebug %errorlevel% occurences of  LayoutID: %LayoutID% in loadedHKLs
	SetFormat integerfast, D
	if (ErrorLevel <= 1)  ; The layout name will uniquely identify this HKL.
		return DispLayoutName

	; Layout name is not unique.  What about Language?
	LOCALE_SENGLANGUAGE=0x1001
	LOCALE_SENGCOUNTRY=0x1002
	VarSetCapacity( sLang, 260, 0 )
	VarSetCapacity( sCountry, 260, 0 )
	DllCall("GetLocaleInfo","uint",HKL & 0xFFFF,"uint",LOCALE_SENGLANGUAGE, "str",sLang, "uint",260)
	DllCall("GetLocaleInfo","uint",HKL & 0xFFFF,"uint",LOCALE_SENGCOUNTRY, "str",sCountry, "uint",260)
	Locale := sLang . " (" . sCountry . ")"

	; Check if this is the only loaded HKL using its language.
	LocaleID := SubStr(HKL, -3) . " "   ; e.g. "0409 "
	StringReplace xx, loadedHKLs, %LocaleID%, , UseErrorLevel  ; ErrorLevel will contain the count of occurrences
	outputdebug %errorlevel% occurences of %LocaleID% in %loadedHKLs%
	if (ErrorLevel <= 1)  ; The lang name will uniquely identify this HKL.
		return Locale

	return Locale . " - " . DispLayoutName
}

ShowAbout:
	Gui, Add, Button, x115 y200 w80 h20 BackgroundTrans Default, OK
	Gui, Show
	return

ButtonOK:
	Gui, Hide
	return

#include Config.ahk	; Configuration GUI (GUI 3) routines
#include Validate.ahk	; Validation and splash screen (GUI 1) routines
#include Comm.ahk	; Interprocess communication and stack management
; #include iSendU.ahk	; InKey's customized version of the SendU module
#include KeyboardConfigure.ahk ; Keyboard Configuration GUI (GUIs 5-7)
#include Lang.ahk ; Internationalisation routines