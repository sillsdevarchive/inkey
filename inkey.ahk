			   ; 2nd and 3rd segments of version number MUST be single-digit. See versionNum()
			   ; Update both the following lines at the same time:
			   ver = 2.0.0.9
;@Ahk2Exe-SetVersion 2.0.0.9
;@Ahk2Exe-SetName InKey
;@Ahk2Exe-SetDescription InKey Keyboard Manager
;@Ahk2Exe-SetCopyright Copyright (c) 2018-2015`, InKey Software
;@Ahk2Exe-SetCompanyName InKey Software
;@Ahk2Exe-SetMainIcon InKey.ico

#NoEnv
#SingleInstance force
#Warn All, OutputDebug
#MaxHotkeysPerInterval 300
#HotkeyInterval 1000


; To implement for TINKER
; - SetPhase, IsPhase
; SetMode(), IsMode for more persistent settings. e.g. smart/plain quote, dev/roman digits

; -Implement 〔KeyChar〕 that provides the character that A_Hotkey would have produced. (Useful for default fallback of user-defined special-function key such as Deva-Winscript 〔TOGGLE〕 (which might be something like Alt+Backslash), and for multi-key handlers such as digits.)

; TODO: Warn if any 〔UNKNOWNS〕 remain in text. (need to redo how AHK file is written)

; TODO: implement multi-ruleset. each ruleset begins with >
; TODO: implement preprocess that prepends rulesets/rules to specified keys
; TODO: implement normalize that appends rulesets to specified keys.
; Problem: A 2nd ruleset (such as preproc or normalization) will result in requiring two BKSP to undo it (if it applied). Also it happens in two steps, so in-btween form is briefly displayed than changed. We need to make the net affect of multiple rulesets happen as a single unit.

; TODO: generate handlers at tinker compile time rather than inkeylib.ahki run time

; TODO: enable define to be inside ##if...

; TODO: Make installation of keyboards smooth again, now that we're calling the .exe to do the install.
; (Some flakiness with name showing badly in config list, with no return value from exe, etc.)

; TODO: When opening Config dialog, *RunAs ftype InKeyKeyboardFile="%A_ScriptDir%" "%1"

; TODO: figure out what when RegisterForPreloading() was supposed to be called  (~ line 786)



; Main initialization
	Outputdebug ___________________________ INKEY.AHK ___________________
	K_ProtocolNum := 5 ; When changes are made to the communication protocol between InKey and InKeyLib.ahki, this number should be incremented in both files.

	K_TinkerVersion := versionNum(ver)
	K_MinTinkerVersion := 1.956 ; Min required version of Tinker language, converted to a float (as versionNum() does)
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
	ActiveAtLastReq := 0
	LastKbdActivationTC := 0
	ShowKeyboardNameBalloon := 0
	oHKLDisplayName := Object()
	KBD_File0 := ""
	KBD_FileID0 := ""
	KBD_HKL0 := GetDefaultHKL() ; also initializes preLoadedHKLs
	oKbdByHKL := Object()
	oKbdByHKL[KBD_HKL0] := 0
	dblTap := 0
	currSendingMode := 0
	LastRotID := ""
	CounterBefore := 0
	CounterAfter := 0
	thisAppDoesGreedyBackspace := 0
	VKbdHwnd := 0
	VKbdShowing := 0
	UnregisterUnusedKeyboards := 0

	SetFormat, IntegerFast, D
	outputdebug Default HKL=%KBD_HKL0%

	; Determine whether to store settings in AppData or in the working directory (which may prevent writing)
	if (FileExist("StoreUserSettingsInAppData.txt")) {
		StoreUserSettingsInAppData := 1
		BaseSettingsFolder := A_AppData . "\InKeySoftware"
		InKeyINI := BaseSettingsFolder "\InKey.ini"
		if (not FileExist(InKeyINI)) {
			FileCreateDir %BaseSettingsFolder%
			FileCopy InKey.ini, %InKeyINI%
		}
	} else {
		StoreUserSettingsInAppData := 0
		BaseSettingsFolder := A_ScriptDir
		InKeyINI := "InKey.ini"
	}
	IniRead GUILang, %InKeyINI%, InKey, GUILang, en

	AllowUnsafe := 0
	if (FileExist("AllowUnsafeKeyboards.txt")) {
		MsgBox 308, Unsafe InKey Keyboards Permitted, InKey is currently configured to allow legacy AHK keyboards. This makes you vulnerable to any malicious keyboard that you might install. Once you have replaced your legacy keyboards with Tinker-format keyboards`, you should disallow unsafe keyboards.`n`nWould you like to disallow unsafe keyboards now?, 15
		IfMsgBox Yes
			FileDelete AllowUnsafeKeyboards.txt
		else
			AllowUnsafe := 1
	}
	InKeyCacheDir = %A_Temp%\InkeyCache
	FileCreateDir %InKeyCacheDir%
	ActivateKbd(0, KBD_HKL0)
	;~ HKLDisplayName%KBD_HKL0% := GetLang(1)  ; "Default Keyboard"
	oHKLDisplayName[KBD_HKL0] := GetLang(1)  ; "Default Keyboard"
	ShowSplash()		; validate()
	hwndLastActive := WinExist("A")
	WinGet hwndTray, ID, ahk_class Shell_TrayWnd
	;outputdebug hwndtray = %hwndtray%
	; KbdToRequest := -1
	GetRegisteredKbds()
	Outputdebug Kbd# 0 (Default) HKL=%KBD_HKL0%
	InkeyLoadedHKLs := ""
	setupCallbacks()
	;	SendU_Init()
	hMSVCRT := DllCall("LoadLibrary", "str", "MSVCRT.dll")

	initContext()
	Menu KbdMenu, UseErrorLevel

	; Read main section of INI file
	IniRead UnderlyingLayout, %InKeyINI%, InKey, UnderlyingLayout, %A_Space%
	if (not UnderlyingLayout)
		UnderlyingLayout := "0000" . A_Language
	RegRead UnderlyingLayoutFile, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%UnderlyingLayout%, Layout File
	if (not UnderlyingLayoutFile)
		UnderlyingLayoutFile := "kbdus.dll"

	IniRead FollowWindowsInputLanguage, %InKeyINI%, InKey, FollowWindowsInputLanguage, 1
	;IniRead AutoGrabContext, %InKeyINI%, InKey, AutoGrabContext, 0
	AutoGrabContext = 0
	IniRead PortableMode, %InKeyINI%, InKey, PortableMode, 1
	IniRead IsBeta, %InKeyINI%, InKey, Beta, 1

	IniRead ShowKeyboardNameBalloon, %InKeyINI%, InKey, ShowKeyboardNameBalloon, 0
	IniRead UseAltLangWithoutPrompting, %InKeyINI%, InKey, UseAltLangWithoutPrompting, 0
	IniRead GUILang, %InKeyINI%, InKey, GUILang, en
	IniRead GUILangName, .Langs\%GUILang%.ini, Language, Name, English

	; [Un]/Register InKey to run on Windows start-up, if running from a fixed drive.
	DriveGet, driveIsFixed, Type, %A_ScriptFullPath%
	driveIsFixed := (driveIsFixed = "Fixed")
	if (driveIsFixed) {
		IniRead StartWithWindows, %InKeyINI%, InKey, StartWithWindows, 0
		if (StartWithWindows) {
			QuotedPath = "%A_ScriptFullPath%"
			RegRead, pls, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey
			if (pls <> QuotedPath)
				RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey, %QuotedPath%
		} else
			RegDelete HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey
	}

	IniRead LeaveKeyboardsLoaded, %InKeyINI%, InKey, LeaveKeyboardsLoaded, 0

	;IniRead PutMenuAtCursor, %InKeyINI%, InKey, PutMenuAtCursor, 0
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

	KBD_File0 := ""
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
	{	if (A_LoopField = "" or (InStr(A_LoopField, ".") and (A_LoopField <> ".nonInkey"))) ; Ignore the blank item at the end of the list, and ignore any folder containing a dot in the name.
			continue

		CurrFolder := A_LoopField
		CurrKbdTinkerFile := ""
		CurrKbdCmd := ""
		if (FileExist(CurrFolder "\" CurrFolder ".tinker")) {
			CurrKbdTinkerFile := CurrFolder "\" CurrFolder ".tinker"
			CurrKbdCmd := CurrFolder . ".ahk"
		} else if (AllowUnsafe and FileExist(CurrFolder "\" CurrFolder ".ahk")) {
			CurrKbdCmd := CurrFolder . ".ahk"
		} else if (A_LoopField <> ".nonInkey") {
			continue
		}

		; Loop for each *.kbd.ini file
		KbdList =
		Loop, %A_LoopField%\*.kbd.ini
			KbdList = %KbdList%%A_LoopFileName%`n
		Sort, KbdList
		Loop, parse, KbdList, `n
		{	if (A_LoopField = "") ; Ignore the blank item at the end of the list.
				continue
			CurrIni = %CurrFolder%\%A_LoopField%
			CurrKbdIni := A_LoopField
			if (StoreUserSettingsInAppData) {
				oriIni := CurrIni
				CurrIni := BaseSettingsFolder "\" CurrIni
				if (not FileExist(CurrIni)) {
					FileCreateDir %BaseSettingsFolder%\%CurrFolder%
					FileCopy %oriIni%, %CurrIni%
				}
			}
			;outputdebug processing file: %CurrIni%
			IniRead, ii, %CurrIni%, Keyboard, Enabled, 1
			if (not ii)		; skip items marked as disabled
				continue
			numKeyboards++  ; New keyboard to configure
			KBD_IniStem%numKeyboards% := SubStr(CurrKbdIni, 1, StrLen(CurrKbdIni) - 8)
			if (CurrKbdTinkerFile) {
				KBD_File%numKeyboards% := CurrFolder "." KBD_IniStem%numKeyboards% ".ahk"
				KBD_CacheStem%numKeyboards% := InkeyCacheDir "\" CurrFolder "." KBD_IniStem%numKeyboards%
				KBD_AhkFile%numKeyboards% := KBD_CacheStem%numKeyboards% ".ahk"

			} else {
				KBD_File%numKeyboards% := CurrKbdCmd
				KBD_AhkFile%numKeyboards% := CurrFolder "\" CurrKbdCmd
			}

			KBD_Folder%numKeyboards% := CurrFolder
			KBD_IniFile%numKeyboards% := CurrIni
			KBD_Disabled%numKeyboards% := 0
			KBD_IconNum%numKeyboards% := 0
			KBD_FileHwnd%numKeyboards% := 0
			; KBD_LayoutName%numKeyboards% := SubStr(A_LoopField, 1, InStr(A_LoopField, ".kbd.ini") - 1)
			KBD_TinkerFile%numKeyboards% := CurrKbdTinkerFile
			IniRead, KBD_LayoutName%numKeyboards%, %CurrIni%, Keyboard, LayoutName, %A_Space%
			IniRead, KBD_MenuText%numKeyboards%, %CurrIni%, Keyboard, MenuText, %A_Space%
			IniRead, KBD_Hotkey%numKeyboards%, %CurrIni%, Keyboard, Hotkey, %A_Space%
			IniRead, KBD_Lang%numKeyboards%, %CurrIni%, Keyboard, Lang, %A_Space%
			IniRead, KBD_AltLang%numKeyboards%, %CurrIni%, Keyboard, AltLang, %A_Space%
			IniRead, KBD_Icon%numKeyboards%, %CurrIni%, Keyboard, Icon, %A_Space%
			IniRead, KBD_Params%numKeyboards%, %CurrIni%, Keyboard, Params, %A_Space%
			IniRead, KBD_DisplayCmd%numKeyboards%, %CurrIni%, Keyboard, LayoutHelp, %A_Space%
			; outputdebug % CurrIni ">> z. layouthelp = " KBD_DisplayCmd%numKeyboards%
			if (KBD_DisplayCmd%numKeyboards% = "")
				IniRead, KBD_DisplayCmd%numKeyboards%, %CurrIni%, Keyboard, DisplayCmd, %A_Space%  ; Old name for LayoutHelp
			; outputdebug % "a. layouthelp = " KBD_DisplayCmd%numKeyboards%
			if ((RegExMatch(KBD_DisplayCmd%numKeyboards%, "i)\.(pdf|png|doc|docx|txt|htm|html|jpg)$")
					or (RegExMatch(KBD_DisplayCmd%numKeyboards%, "i)\.ahk$") and AllowUnsafe))
				  and FileExist(KBD_Folder%numKeyboards% . "\" . KBD_DisplayCmd%numKeyboards% )) {
				if (RegExMatch(KBD_DisplayCmd%numKeyboards%, "i)\.tinker\.html$"))
				{	; LayoutHelp file is one we generate
					KBD_DisplayCmdSrc%numKeyboards%  := KBD_Folder%numKeyboards% . "\" . KBD_DisplayCmd%numKeyboards% ; If the keyboard help file exists in the keyboard's folder, prepend path.
					KBD_DisplayCmd%numKeyboards%  := KBD_CacheStem%numKeyboards% ".html"
				} else {
					KBD_DisplayCmdSrc%numKeyboards%  =
					KBD_DisplayCmd%numKeyboards%  := KBD_Folder%numKeyboards% . "\" . KBD_DisplayCmd%numKeyboards% ; If the keyboard help file exists in the keyboard's folder, prepend path.
				}
			} else {
				KBD_DisplayCmd%numKeyboards% =
				KBD_DisplayCmdSrc%numKeyboards% =
			}
			; outputdebug % "b. layouthelp = " KBD_DisplayCmd%numKeyboards%
			if (AllowUnsafe) {
				IniRead, KBD_ConfigureGUI%numKeyboards%, %CurrIni%, Keyboard, ConfigureGUI, %A_Space%
			} else {
				KBD_ConfigureGUI%numKeyboards% =
			}
			IniRead, KbdKLID%numKeyboards%, %CurrIni%, Keyboard, KLID, %A_Space%
			KBD_HKL%numKeyboards% = ""
			ProcessKbd()
		}
	}
	; now deal with the keyboards that needed registration or unregistration
	if (PortableMode or not UnregisterUnusedKeyboards)
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
					KBD_HKL%kk% := RegisterAndLoadKeyboard(kk)
					oKbdByHKL[KBD_HKL%kk%] := kk
					SetFormat, IntegerFast, d
				}
			}
		} else {  ; not A_IsAdmin
			; There are keyboards needing registered or unregistered, but user does not have Admin privileges.
			Gui Hide
			TitleString:=GetLang(116)  ; Install/update Keyboard registration?
			TempString:= UnregisterUnusedKeyboards ? (GetLang(117) . " " . UnusedRKCt . "`n") : ""
			TempString .= GetLang(118) . " " . Kbd2RegCt . "`n`n" . GetLang(119) . "`n" . GetLang(120) . "`n" . GetLang(121) . "`n`n" . GetLang(122)
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
				KBD_HKL%kk% := LoadSubstituteKeyboard(KBD_Lang%kk%, KBD_LayoutName%kk%)
				oKbdByHKL[KBD_HKL%kk%] := kk
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
	IniRead RefreshLangBarOnLoad, %InKeyINI%, InKey, RefreshLangBarOnLoad, 2
	if (InkeyLoadedHKLs) {
		if (RefreshLangBarOnLoad = 1)
			RefreshLangBar() ; Slow but sure
		else if (RefreshLangBarOnLoad = 2) {	; Post WM_INPUTLANGCHANGEREQUEST to HWND_BROADCAST
			DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, LastLoadedHKL)  ; First change it to something else
			DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; Then change it back to default lang.
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

		;IniRead KBD_MenuText0, %InKeyINI%, InKey, DefaultKbdMenuText, & Default keyboard
		menu KbdMenu, add
		KBD_MenuText0:=GetLang(10)
		menu KbdMenu, add, %KBD_MenuText0%, KeyboardMenuItem	; Add menu item for default keyboard
		menu KbdMenu, check, %KBD_MenuText0%
	}

	; ============Set up hotkeys.

	IniRead ii, %InKeyINI%, InKey, ResyncHotkey, %A_Space%
	; Resync Keyboards with InKey - Workaround for a bug
	if (ii)
		Hotkey %ii%, DoResync, UseErrorLevel

	; Reload InKey
	IniRead ii, %InKeyINI%, InKey, ReloadHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, DoReload, UseErrorLevel

	; DefaultKbdHotkey
	IniRead KBD_Hotkey0, %InKeyINI%, InKey, DefaultKbdHotkey, %A_Space%
	if (KBD_Hotkey0)
		Hotkey %KBD_Hotkey0%, OnKbdHotkey, UseErrorLevel

	; DefaultKbdDoubleTap
	IniRead ii, %InKeyINI%, InKey, DefaultKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapDefKbd, UseErrorLevel
	}

	; ToggleKbdHotkey
	IniRead ii, %InKeyINI%, InKey, ToggleKbdHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, HotkeyToggleKbd, UseErrorLevel

	; ToggleKbdDoubleTap
	IniRead ii, %InKeyINI%, InKey, ToggleKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapToggleKbd, UseErrorLevel
	}

	; NextKbdHotkey
	IniRead ii, %InKeyINI%, InKey, NextKbdHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, RequestNextKbd, UseErrorLevel

	; NextKbdDoubleTap
	IniRead ii, %InKeyINI%, InKey, NextKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapNextKbd, UseErrorLevel
	}

	; PrevKbdHotkey
	IniRead ii, %InKeyINI%, InKey, PrevKbdHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, RequestPrevKbd, UseErrorLevel

	; PrevKbdDoubleTap
	IniRead ii, %InKeyINI%, InKey, PrevKbdDoubleTap, %A_Space%
	if (ii) {
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapPrevKbd, UseErrorLevel
	}

	; MenuHotkey
	IniRead ii, %InKeyINI%, InKey, MenuHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, ShowKbdMenu, UseErrorLevel

	; MenuDoubleTap
	IniRead ii, %InKeyINI%, InKey, MenuDoubleTap, %A_Space%
	if (ii) {
		; HotKey ~%ii% & SC200, Nothing, UseErrorLevel
		HotKey %ii% & ~s, Nothing, UseErrorLevel   ; Make key a prefix by using it in front of "&" at least once. Use tilde so normal behavior occurs.
		HotKey %ii%, DblTapMenuKbd, UseErrorLevel
	}

	; AutoGrabContextHotkey
	IniRead ii, %InKeyINI%, InKey, AutoGrabContextHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, MenuAutoGrab, UseErrorLevel

	; GrabContextHotkey
	IniRead ii, %InKeyINI%, InKey, GrabContextHotkey, %A_Space%
	if (ii)
		Hotkey %ii%, GrabContext, UseErrorLevel

	; ChangeSendingMode hotkey
	IniRead ii, %InKeyINI%, InKey, ChangeSendingMode, %A_Space%
	if (ii)
		Hotkey %ii%, ChangeSendingMode, UseErrorLevel

	; ClearContextHotkey
	; IniRead ii, %InKeyINI%, InKey, ClearContextHotkey, %A_Space%
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
		DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; Then change it back to default lang.
		ChangeLanguage(KBD_HKL0)
	}

	IniRead PreviewAtCursor, %InKeyINI%, InKey, PreviewAtCursor, 1
	IniRead rotaPeriod, %InKeyINI%, InKey, SpeedRotaPeriod, 1000

;	ChangeLanguage(KBD_HKL0) ; Just to be sure
	; OnMessage(0x6, "On_WM_ACTIVATE")
	tipHwnd := CreateUTip()
	; tipTxt

	Loop % numKeyboards  {
		kk := A_Index
		OutputDebug % kk . " " . KBD_LayoutName%kk% . " " .  KBD_FileID%kk% . " " . KBD_File%kk%  . " " . KBD_HKL%kk%
	}

	; Process Tinker files
	Loop % numKeyboards  {
		kk := A_Index
		if (KBD_TinkerFile%kk%) {
			if ((not FileExist(KBD_AhkFile%kk%)) or FileIsOlderThan(KBD_AhkFile%kk%, KBD_TinkerFile%kk%) or FileIsOlderThan(KBD_AhkFile%kk%, A_ScriptFullPath) or FileIsOlderThan(KBD_AhkFile%kk%, KBD_IniFile%kk%) or (KBD_DisplayCmdSrc%kk% and FileIsOlderThan(KBD_DisplayCmd%kk%, KBD_DisplayCmdSrc%kk%))) {
				GUIControl,, splashTxt, % "Recompiling keyboard:" chr(10) KBD_LayoutName%kk%
				err := ProcessTinkerFile(kk)
				GUIControl,, splashTxt, %A_Space%
				if (err) {
					Gui Hide
					MsgBox %err%
				}
				if (tinkWarnings) {
					Gui hide
					MsgBox 260, Warning, % "Warnings were encountered while processing " KBD_Folder%kk% ".tinker`nView warnings now?"
					IfMsgBox Yes
						Run % "notepad """ KBD_AhkFile%kk% """"
				}
			}
		}
	}

	gui hide

	SetTimer CHECKLOCALE, 500
	if (numKeyboards = 0) {
		Gui Hide
		goto WelcomeToInKey
	}
return

FileIsOlderThan(this, that) {
	FileGetTime thisTime, %this%
	FileGetTime thatTime, %that%
	EnvSub thisTime, %thatTime%, S
	; outputdebug FileIsOlderThan(%this%, %that%) => %thisTime%
	return (thisTime < 0)
}

ProcessKbd() {
	global
	static ProcdKbdList := ""
	local kk := numKeyboards
ProcessKbdErrors:
	if (KBD_Disabled%kk%) {
			;or ( KBD_File%kk% and not FileExist(KBD_Folder%kk% . "\" . KBD_File%kk%))) {
		; local xx := KBD_MenuText%kk%
		; outputdebug ignoring %fldr% %xx%
		IniWrite 0, % KBD_IniFile%kk%, Keyboard, Enabled
		KBD_FileID%kk% =
		KBD_File%kk% =
		KBD_AhkFile%kk% =
		KBD_MenuText%kk% =
		KbdHotkeyCode%kk% =
		KBD_LayoutName%kk% =
		KBD_Lang%kk% =
		KBD_Icon%kk% =
		KBD_Params%kk% =
		KbdKLID%kk% =
		KBD_Disabled%kk% =
		KBD_ConfigureGUI%kk% =
		KBD_RunGUI%kk% =
		KBD_DisplayCmd%kk% =
		KBD_RunCmd%kk% =
		KBD_AltLang%kk% =
		KBD_HKL%kk% =
		KBD_OptionsFile%kk% =
		numKeyboards--
		return
	}

	; populate submenu for all enabled keyboards
	Menu, DispConfigureSubmenu, add, % KBD_MenuText%kk%, DispConfigureMenuItem

	; populate submenu if keyboard has a layout help file
	if (KBD_DisplayCmd%kk%) {
		DispCmds++

		ii := KBD_MenuText%kk%
		Menu, DispCmdSubmenu, add, %ii%, DispCmdMenuItem
	}

	if (KBD_LayoutName%kk%) {
		; These are the settings for an InKey keyboard
		local ln := KBD_LayoutName%kk%
		; Check that the language code is valid on this machine
		if (not KBD_Lang%kk%) {
			Gui Hide
			TitleString:=GetLang(123) ; Configuration Error
			TempString:=GetLang(124) ; The language code for keyboard "%ln%" is missing.
			MsgBox 0, %TitleString%, %TempString%
			Gui Show
			KBD_Disabled%kk% := 1
			goto ProcessKbdErrors
		}
		if (strlen(KBD_Lang%kk%) <> 4) {
			Gui Hide
			TitleString:=GetLang(123) ; Configuration Error
			TempString:=GetLang(125) ; The language code for keyboard "%ln%" should be a 4-hexidecimal-digit code representing the language ID.
			MsgBox 0, %TitleString%, %TempString%
			Gui Show
			KBD_Disabled%kk% := 1
			goto ProcessKbdErrors
		}
		local priLang := "0x" . KBD_Lang%kk%
		local sLangName
		VarSetCapacity( sLangName, 260, 0 )
		DllCall("GetLocaleInfo","uint",priLang & 0xFFFF,"uint", 0x1001, "str",sLangName, "uint",260)  ; LOCALE_SENGLANGUAGE=0x1001
		if (strlen(sLangName) < 1) {
			if (KBD_AltLang%kk%) {
				local altLang := "0x" . KBD_AltLang%kk%
				DllCall("GetLocaleInfo","uint", altLang & 0xFFFF,"uint", 0x1001, "str",sLangName, "uint",260)  ; LOCALE_SENGLANGUAGE=0x1001
				if (sLangName) {
					if (UseAltLangWithoutPrompting) {
						KBD_Lang%kk% := KBD_AltLang%kk%
						goto LangCodeOK
					} else {
						Gui Hide
						TitleString:=GetLang(126) ; Use %sLangName% language for '%ln%' layout?
						LangCode:= KBD_Lang%kk%
						TempString:= GetLang(127) . " " . LangCode . " " . GetLang(128) . "`n`n" . GetLang(129) . "`n`n" . GetLang(130) . " " . sLangName . " " . GetLang(131) . " " . ln . " " . GetLang(132) ; "The language code " . %LangCode% . " is unknown on this version or service-pack of Windows.`n`nSome applications may not function properly with an unknown language.`n`nWould you like to instead use " . sLangName . " for the '" . ln "' keyboard?"
						MsgBox 4, %TitleString%, %TempString%
						Gui Show
						ifmsgbox Yes
							KBD_Lang%kk% := KBD_AltLang%kk%
						goto LangCodeOK
					}
				}
			}

			Gui Hide
			TitleString:=GetLang(133) . " " . ln ; Unknown language code for layout: %ln%
			LangCode:= KBD_Lang%kk%
			TempString:= GetLang(127) . " " . LangCode . " " . GetLang(134) . "`n" . GetLang(135) . "`n`n" . GetLang(136) ; "The language code " . %LangCode% . " is unknown on this computer, and you have not configured an alternative for this keyboard.`nSome applications may not function properly with this language.`n`nLoad it anyway?"
			MsgBox 4, %TitleString%, %TempString%
			Gui Show
			ifmsgbox Yes
				goto LangCodeOK
			KBD_Disabled%kk% := 1
			goto ProcessKbdErrors
		}

LangCodeOK:
		; Identify the keyboard file settings
		local ff := InStr(KbdFiles, ":" . KBD_File%kk% . A_Tab)
		if (ff) {
			KBD_FileID%kk% := substr(KbdFiles, ff - 4, 4) + 0
		} else {
			numKbdFiles++
			KBD_FileID%kk% := numKbdFiles
			kFileName%numKbdFiles% := KBD_File%kk%
			KbdFiles .= "   " . KBD_FileID%kk% . ":" . KBD_File%kk% . A_Tab
		}
		; first 4 parameters are K_ProtocolNum, InKeyHwnd, FileID, KbdId
		RunCmd%kk% := GetAHKCmd(KBD_File%kk%) . """" . KBD_AhkFile%kk% . """ " . K_ProtocolNum . " " . selfHwnd . " " . KBD_FileID%kk% . " " . kk . " " . KBD_Params%kk%

		klid := FindKLID(KBD_LayoutName%kk%, KBD_Lang%kk%)  ; See if keyboard named is registered
		;outputdebug FindKLID => %klid%.
		if (klid) {
			; Keyboard is registered.  Ensure we haven't already used it.
			if (InStr(ProcdKbdList, klid)) {
				Gui Hide  ; TODO: Add this text to Lang
				MsgBox 0, % "Keyboard Configuration Error", % "Each keyboard must have a unique layout name.`n`nKeyboard File: " KBD_Folder%kk% "\" KBD_IniStem%kk% "`nLayout name: " KBD_LayoutName%kk% "`n`nCheck keyboard settings."
				Gui Show
				KBD_Disabled%kk% := 1
				goto ProcessKbdErrors
			}
			ProcdKbdList .= klid . " "
			;Ensure it's loaded, and get its HKL.
			KBD_HKL%kk% := LoadKeyboardLayout(klid, 16, KBD_LayoutName%kk%)
			oKbdByHKL[KBD_HKL%kk%] := kk
			;~ Outputdebug % "Kbd# " . kk . " uses registered KLID: " . klid . ", HKL=" . KBD_HKL%kk%    ;%
		} else {
			; Keyboard is not registered.
			if (PortableMode)  {
				KBD_HKL%kk% := LoadSubstituteKeyboard(KBD_Lang%kk%, KBD_LayoutName%kk%) ; Use a non-registered keyboard instead.
				oKbdByHKL[KBD_HKL%kk%] := kk
			} 	else  {
				; Remember this keyboard as one we need to register (once all keyboard settings have been read).
				Kbd2RegCt++
				Kbd2Reg%Kbd2RegCt% := kk
			}
		}
	} else {
		; These are the settings for a non-InKey keyboard  (e.g. System or Keyman etc)
		; Set KbdFile[], KbdKLID[] and KbdHKL[] values
		KBD_File%kk% := ""
		KBD_FileID%kk% =
		if (not KbdKLID%kk%)
			KbdKLID%kk% = 00000409
		KBD_HKL%kk% := LoadKeyboardLayout(KbdKLID%kk%)
		oKbdByHKL[KBD_HKL%kk%] := kk
		Outputdebug % "Kbd# " . kk . " is NON-INKEY. KLID=" . KbdKLID%kk% . ", HKL=" . KBD_HKL%kk%    ;%
	}
	;ChangeLanguage(KBD_HKL%kk%) ; Should help refresh the Lang Bar

	local hkl := KBD_HKL%kk%
	;~ HKLDisplayName%hkl% := RegExReplace(KBD_MenuText%kk%, "&") ; Strip the ampersand
	oHKLDisplayName[hkl] := RegExReplace(KBD_MenuText%kk%, "&") ; Strip the ampersand

	; Icon settings for this keyboard
	KbdIconFile%kk% := KBD_Icon%kk%
	if (KbdIconFile%kk%) {
		; If there is a second parameter (after a comma), separate that out.
		if (RegExMatch(KbdIconFile%kk%, "(.*),\s*(.*)", val)) {
			KbdIconFile%kk% = %val1%
			KBD_IconNum%kk% = %val2%
		}

		; If the icon file exists in the keyboard's folder, prepend path.
		if (FileExist(KBD_Folder%kk% . "\" . KbdIconFile%kk%))
			KbdIconFile%kk% := KBD_Folder%kk% . "\" . KbdIconFile%kk%
		; otherwise hopefully the file is a system DLL
	}
	KBD_Icon%kk% =

	local ii := KBD_MenuText%kk%
	menu KbdMenu, add, %ii%, KeyboardMenuItem  	; Add menu item for this keyboard
}

RegisterAndLoadKeyboard(kk) {
	global
	local Lang := KBD_Lang%kk%
	local layoutName := KBD_LayoutName%kk%
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
	if (0)    ; if (Preload) 			; TODO: I don't remember what Preload was supposed to mean
		RegisterForPreloading(KLID, Lang)   ; so this NEVER gets called!!

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

ProcessTinkerFile(kk) {  ; Generate an AHK file from the TINKER file
	global
	tinkWarnings := 0
	local TinkerFile := KBD_TinkerFile%kk%
	local AHKFile := KBD_AhkFile%kk%
	outputdebug Generating %AHKFile% from %TinkerFile%
	FileEncoding UTF-8
	FileRead tinkerLines, %TinkerFile%
	if (ErrorLevel) {
		return ("Unable to read file: " TinkerFile)
	}

	layoutLines := ""
	if (KBD_DisplayCmdSrc%kk%) {
		FileRead layoutLines, % KBD_DisplayCmdSrc%kk%
		layoutLines := RegExReplace(layoutLines, "i)((?:&#12308;)|〔)LayoutName(〕|(?:&#12309;))", KBD_LayoutName%kk%)
		layoutLines := RegExReplace(layoutLines, "i)((?:&#12308;)|〔)IniFileName(〕|(?:&#12309;))", KBD_IniFile%kk%)
		; layoutLines := RegExReplace(layoutLines, "i)KA", "k")
	}

	tinkerLines := RegExReplace(tinkerLines, "((?<!\r)\n)|(\r(?!\n))", "`r`n") ; ensure canonical CR-LF
	tinkerLines := RegExReplace(tinkerLines, "[\x{a0}]+", " ") ; replace any no break space with normal space. (may be code copied from tutorial.)
	; local nbsp := chr(0xA0)
	; StringReplace tinkerLines, tinkerLines, %nbsp%, %A_Space%, 1  ; replace any no break space with normal space. (may be code copied from tutorial.)

	; Remove all comments and trailing whitespace from the file
	local fpos
	while (fpos := RegExMatch(tinkerLines, "(【[^【】]*)//([^【】]*】)")) { ; First preserve all // that are inside 【 param braces 】
		tinkerLines := RegExReplace(tinkerLines, "(【[^【】]*)//([^【】]*】)", "$1" chr(0xfffe) "$2", 0, -1, fpos)
	}
	tinkerLines := RegExReplace(tinkerLines, "\s*//.*", "") ; nuke comments
	StringReplace tinkerLines, tinkerLines, % chr(0xfffe), //, 1
	tinkerLines := RegExReplace(tinkerLines, "m)\s+$", "") ; nuke trailing whitespace

	tinkerLines := RegExReplace(tinkerLines, "s)(►.*?◄)", "")
	tinkerLines := RegExReplace(tinkerLines, "(?<=\n)[\r\n]+", "") ; nuke blank lines

	if (FileExist(AHKFile)) {
		FileDelete %AHKFile%
	}
	FileAppend `; generated by InKey v. %ver%`n, %AHKFile%

	local CapsSensitive := 1
	local options := ""
	local CapsKeys := "abcdefghijklmnopqrstuvwxyz"

	fpos := RegExMatch(tinkerLines, "Oim)^Settings:\s*(?:\s+//.*)?\r?\n((?:\s+.*\r?\n)+)(?:Options:\s*(?:\s+//.*)?\r?\n((?:\s+.*\r?\n)+))?\.\.\.(?:\s+//.*)?\r?\n", match)
	if (fpos) {
		tinkerLines := SubStr(tinkerLines, match.Len(0) + fpos)
		local settings := match.Value(1)
		options := match.Value(2)

		; Check Tinker version for compatibility
		if (RegExMatch(settings, "Om)^\s+TinkerVersion:\s+([0-9\.]*)$", match)) {
			local tvNum := versionNum(match.Value(1))
			if (tvNum < K_MinTinkerVersion) {
				local err := TinkerFile " uses Tinker v. " match.Value(1) ". Please update keyboard to at least v. " K_MinTinkerVersion
				FileAppend `; %err%`n, %AHKFile%
				return (err)
			}
			if (tvNum > K_TinkerVersion) {
				local err := TinkerFile " requires a later version of InKey (" match.Value(1) "). Please update InKey version " ver " to the latest version."
				FileAppend `; %err%`n, %AHKFile%
				return (err)
			}
		} else {
			TinkWarnings += 1
			FileAppend `; WARNING: No TinkerVersion key found in Settings`n, %AHKFile%
		}

		; Get CapsSensitive setting
		if (RegExMatch(settings, "Om)^\s+CapsSensitive:\s+(No|false)$", match)) {
			CapsSensitive := 0
		}

		; Get CapsKeys setting
		if (RegExMatch(settings, "Om)^\s+CapsKeys:\s+(\S*)$", match)) {
			CapsKeys := match.Value(1)
		}

	} else {
		local fp := InStr(tinkerLines, "...")
		if (fp) {
			tinkerLines := SubStr(tinkerLines, fp+1)
			FileAppend `; WARNING: Error in parsing header section`n, %AHKFile%
			tinkWarnings += 1
		} else {
			FileAppend `; ERROR: Unable to locate '...' marking end of header in:%tinkerLines%`n, %AHKFile%
			return ("Unable to locate '...' marking end of header in " TinkerFile)
		}
	}

	; parse the Options section
	local fldName
	local fldDef
	local fldVal
	local optionsFile := KBD_CacheStem%kk% . ".options"
	if (FileExist(optionsFile)) {
		FileDelete %optionsFile%
	}
	if (options) {
		FileAppend %options%, %optionsFile%
		while (StrLen(options) > 1) {
			if (RegExMatch(options, "Oi)^( +)- (checkbox|keystroke):\s*\r?\n((?:\1\s+.*\r?\n)+)", match)) {
				options := substr(options, match.Len(0)+1)
				local ctrltype := match.Value(2)
				local subFlds := match.Value(3)
				fldName := ""
				if (RegExMatch(subFlds, "Oi) name:\s+(.*?)\r?\n", match)) {
					fldName := match.Value(1)
				} else {
					FileAppend /* WARNING: Option not parsed:`n%subFlds% */, %AHKFile%
					continue
				}
				fldDef := " "
				if (RegExMatch(subFlds, "Oi) default:\s+(.*?)\r?\n", match)) {
					fldDef := match.Value(1)
				}
				; numOpts += 1
				; OPT_Name%numOpts% := fldName
				 outputdebug % "read from ini:" KBD_IniFile%kk%
				fldVal := 9
				IniRead fldVal, % KBD_IniFile%kk%, Options, %fldName%, %fldDef%		; TODO: maybe fldDef may need chars escaped or like %A_Space%???
				if (ctrltype = "keystroke") {
					if (fldVal = "") {
						layoutLines := RegExReplace(layoutLines, "((\Q&#12308;\E)|〔)\Q" fldName "\E((\Q&#12309;\E)|〕)", "<nokeystroke title=""" . fldName . """>‡</nokeystroke>")
						fldVal := "00" ; this signals that the handler should be ignored
					} else {
						local keybtns, lblmatch, modkey, spPos, priChar, priKey
						spPos := InStr(fldVal, " ")
						if (spPos) {
							priKey := substr(fldVal, 1, spPos - 1)
							priChar := substr(fldVal, spPos - 2, spPos - 1)
						} else {
							priKey := fldVal
							priChar := substr(fldVal, -1, 1)
						}
						if (RegExMatch(priKey, "O)^([>!<#+^]+)(\S)$", lblmatch)) {
							if (lblmatch.Value(1) = ">!")
								modkey := "RAlt"   ; Make >! into a RAlt button
							else if (lblmatch.Value(1) = "!")
								modkey := "Alt"
							else if (lblmatch.Value(1) = "<!")
								modkey := "LAlt"
							else if (lblmatch.Value(1) = "+")
								modkey := "Shift"
							else
								modkey := "[" lblmatch.Value(1) "]"
							keybtns := "<span title=""" fldName """><keystroke>" modkey "</keystroke><keystroke>" lblmatch.Value(2) "</keystroke>"
						} else {
							keybtns := "<keystroke title=""" . fldName . """>" priKey "</keystroke>"
						}
						layoutLines := RegExReplace(layoutLines, "((\Q&#12308;\E)|〔)\Q" fldName "\E((\Q&#12309;\E)|〕)", keybtns)
					}

					if (spPos) {
						; If more than one key specified, enclose all keys in 【 】 brackets at start of line, but just use the first key in other contexts.
						tinkerLines := RegExReplace(tinkerLines, "m)^\Q〔" fldName "〕\E", "【" fldVal "】")
						tinkerLines := RegExReplace(tinkerLines, "\Q〔" fldName "〕\E", priChar)
					} else {
						tinkerLines := RegExReplace(tinkerLines, "m)^\Q〔" fldName "〕\E", fldVal)
						tinkerLines := RegExReplace(tinkerLines, "\Q〔" fldName "〕\E", priChar)
					}
				} else {
					; ctrltype is checkbox
					tinkerLines := RegExReplace(tinkerLines, "\Q〔" fldName "〕\E", fldVal)
					layoutLines := RegExReplace(layoutLines, "((\Q&#12308;\E)|〔)\Q" fldName "\E((\Q&#12309;\E)|〕)", fldVal ? "YES" : "NO")
				}
				continue
			}
			tinkWarnings += 1
			FileAppend /* WARNING: Options not parsed:`n%options% */, %AHKFile%
			break
		}
	}


	; TODO: Build the AHK file header better
	local useContext := CapsSensitive ? 2 : 1
	FileAppend K_MinimumInKeyLibVersion = 1.912`nK_UseContext = %useContext%`n#include InKeyLib.ahki`n, %AHKFile%

	; Process any define and function statements
	while (RegExMatch(tinkerLines, "Oi)^(define[ \t]+(\w+)[ \t]+(.*?)\r?\n)|(function[ \t]+(\w+)\s*((?:【\w+?】\s*?)+)\r?\n\s+(\S.*(?:\r?\n\s+\S.*)*)\r?\n)", match)) {
		tinkerLines := SubStr(tinkerlines, 1, match.Pos(0)-1) . SubStr(tinkerLines, match.Pos(0)+match.Len(0))
		; outputdebug % "Preproc: " match.Value(0)
		; outputdebug % "[0].Pos="  match.Pos(0) "; [0].Len=" match.Len(0)
		; outputdebug % "tinkerLines begin: " substr(tinkerlines, 1, 40) "..."
		; apply the define or function across tinkerLines
		; define text => match[1]
		; def[1] => match 2
		; def[2] => match 3
		; fn txt => match 4
		; fn[1] => 5
		; fn2 > 6
		; fn3 > 7
		; define XXX YYY
		if (match.Value(1)) {
			StringReplace tinkerLines, tinkerLines, % "〔" match.Value(2) "〕", % match.Value(3), 1
			; tinkerLines := RegExReplace(SubStr(tinkerLines, match.Len(1) + 1), "\Q〔" match.Value(2) "〕\E", match.Value(3)) ; TODO: escape $ as $$ in the replacement text!!!
			continue
		}

		; function XXX 【 】+
		if (match.Value(4)) {
			; tinkerLines := SubStr(tinkerLines, match.Len(4) + 1)
			local fname := match.Value(5)
			local fparams := match.Value(6)
			local frules := match.Value(7)
			fparams := RegExReplace(fparams, "】\s*【", chr(0xfffe))
			local fparamsA := StrSplit(fparams, char(0xfffe), "【】")
			local findFunc := "i)\Q" fname "\E"
			StringReplace frules, frules, $, $$, 1
			for index, element in fparamsA {
				findFunc .= "\s*【(.*?)】"
				frules := RegExReplace(frules, "i)〔\Q" . element . "\E〕", "$${" . index . "}")
			}
			; StringReplace tinkerLines, tinkerLines, %find
			tinkerLines := RegExReplace(tinkerLines, findFunc, frules)
			continue
		}


	}

	tinkerLines := HexCodes2Chars(tinkerLines) ; Replace 〔hex〕 codes with chars

	; ⌘if ⌘then ⌘else ⌘endif
	while RegExMatch(tinkerLines, "O)⌘if[\s\r\n]*([^⌘]*?)[\s\r\n]*⌘then[\s\r\n]*([^⌘]*?)(?:[\s\r\n]*⌘else[\s\r\n]*([^⌘]*?))?[\s\r\n]*⌘endif", defM) {
		local toFind := defM.Value(0)
		; outputdebug % "⌘IF{" defM.Value(1) "} ⌘THEN{" defM.Value(2) "} ⌘ELSE{" defM.Value(3) "}"
		; outputdebug % "evalExpr(""" defM.Value(1) """) => "  evalExpr(defM.Value(1))
		local toRepl := defM.Value(evalExpr(defM.Value(1)) ? 2 : 3)
		; outputdebug % "toRepl{" toRepl "}"
		StringReplace, tinkerLines, tinkerLines, %toFind%, %toRepl%

	}
	tinkerLines := RegExReplace(tinkerLines, "(?:(?<=\n)|^)\s*[\r\n]+", "") ; nuke blank lines resulting from above


	; tinkerLines := RegExReplace(tinkerLines, "(\n\S*)([``""]){2}", "$1$2") ; remove escape from backtick/dblquot in keystroke labels ; TODO: also in labels with alt, shift, etc!!!

	; Handle colon key : as +`;
	; StringReplace tinkerLines, tinkerLines, `n:, `n+```;, 1
	tinkerLines := RegExReplace(tinkerLines, "m)^([!><#^]*):", "$1+`;")

	local debugfile := KBD_CacheStem%kk% ".tinker"
	if (FileExist(debugfile)) {
		FileDelete %debugfile%
	}
	FileAppend %tinkerLines%, %debugFile%

	; Extract all key handlers and their translated rulesets to an array
	local keyArray, synArray
	keyArray := Object()
	local unparsed := ""
	while (RegExMatch(tinkerLines, "Om)^(?:(\S+)|(?:【([^】]+)】))\s*>\s*(\S.*(\r?\n\s+.*)*\r?\n?)", match)) {
		if (match.Pos(0) > 1)
			unparsed .= SubStr(tinkerLines, 1, match.Pos(0) - 1)
		tinkerLines := SubStr(tinkerLines, match.Pos(0) + match.Len(0))
		local keystroke := match.Value(1) . match.Value(2)
		if (keystroke = "00")
			continue	; User blanked out hotkey, so ignore this and all its rules.
		keystroke := RegExReplace(keystroke, "\s+", chr(0xfffe))
		synArray := StrSplit(keystroke, chr(0xfffe)) ; spaces in keystroke indicate synonymous keys. TODO: Would be more efficient to end up with two hotkeys on the same code than duplicating code like this.
		local tr := translateRules(match.Value(3))
		Loop % synArray.MaxIndex()
		{
			keystroke := RegExReplace(synArray[a_index], "^([!#<>^]*)([A-Z])$", "$1+$L2")  ; e.g. K -> +k
			keyArray[keystroke] := tr
			; outputdebug key = %keystroke%
		}
	}
	unparsed .= tinkerLines
	if (unparsed) {
		unparsed := RegExReplace(unparsed, "m)^.*$", "; unparsed: $0")
		tinkWarnings += 1
		FileAppend %unparsed%, %AHKFile%
	}

	; Write layoutLines to html file
	if (KBD_DisplayCmdSrc%kk%) {
		if (FileExist(KBD_DisplayCmd%kk%))
			FileDelete % KBD_DisplayCmd%kk%
		FileAppend %layoutLines%, % KBD_DisplayCmd%kk%
	}

	; First process any key handlers for CapsKeys
	if (CapsSensitive) {
		; outputdebug CapsKeys = %CapsKeys%
		loop parse, CapsKeys
		{
			local loKey := A_LoopField
			local upKey := "+" A_LoopField
			if (keyArray[loKey] and keyArray[upKey]) {
				FileAppend % "$" loKey "::`n$" upKey "::`nif (UseUpperCase()) {`n`t" keyArray[upKey] "} else {`n`t" keyArray[loKey] "}`nreturn`n", %AHKFile%
				keyArray.Remove(loKey)
				keyArray.Remove(upKey)
			; } else if (keyArray[loKey] or keyArray[upKey]) {
				; tinkWarnings += 1
				; warnTxt := "CapsSensitive = Yes, and CapsKeys included '" loKey "', but this requires handlers for both " loKey " and " upKey "`n"
				; outputdebug Warning: %warnTxt%. loKey=%loKey%  upKey=%upKey%
				; FileAppend `; Warning: %warnTxt%, %AHKFile%
			}
		}
	}

	; Now process all remaining key handlers
	for key, rules in keyArray
		FileAppend % "$" key "::" keyArray[key], %AHKFile%

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
			outputdebug Error, could not suspend kbd file: %ActivekbdFile%
		}
	}
	; if (PutMenuAtCursor)
		Menu KbdMenu, show
	; else
		; Menu KbdMenu, show, %TrayX%, %TrayY%

	if (not gotKbdReq) { ; user must not have selected a keyboard


		if (ActiveKbd) {
			ActiveKbdHwnd := GetKbdHwnd(ActiveKbd)
			if (ActiveKbdHwnd) {
				resumeResult := DllCall("SendMessage", UInt, ActiveKbdHwnd, UInt, 0x8002)
				if (resumeResult>10) {
					VKbdHwnd := resumeResult
					VKbdShowing := 1
				}
			} else {
				outputdebug Error, could not resume kbd file: %ActivekbdFile%
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

	; dd := KBD_Folder%kbd%
	; if %dd%
		; SetWorkingDir %dd%
	RunDisplayCmd := GetAHKCmd(KBD_DisplayCmd%kbd%) . """" . KBD_DisplayCmd%kbd% . """"
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
	ActiveAtLastReq := ActiveKbd
	OUTPUTDEBUG ***** RequestKbd(%kbd%)
	if (kbd = 0 and ActiveHKL = KBD_HKL0) {
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
			; outputdebug Error, could not resume %ActivekbdFile%

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
		fHwnd := KBD_FileHwnd%A_Index%
		sv := 0
		if (fHwnd) {
			sv := DllCall("SendMessage", UInt, fHwnd, UInt, 0x8003)
			outputdebug sent MsgClose to file # %a_index%
		}
		KBD_FileHwnd%A_Index% = 0
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
		DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; KBD_HKL0  0x50 = WM_INPUTLANGCHANGEREQUEST

	SetTitleMatchMode Regex
	DetectHiddenWindows On
	Loop %numKeyboards%
	{
		f := GetKbdFile(A_Index)
		if (f and WinExist("i)" . GetKbdFile(A_Index) . " ahk_class AutoHotkey"))
			PostMessage, 0x10, 0, 0  ; The WM_CLOSE message is sent  to the "last found window" due to WinExist() above.
	}
	DetectHiddenWindows Off  ; Must not be turned off until after PostMessage.

	;outputdebug InkeyLoadedHKLs=%InkeyLoadedHKLs%`nLeaveKeyboardsLoaded=%LeaveKeyboardsLoaded%
	if (InkeyLoadedHKLs and not LeaveKeyboardsLoaded) {
	; if (1) {

		; We unload any keyboards that InKey loaded
		outputdebug InkeyLoadedHKLs = %InkeyLoadedHKLs%
		Loop %numKeyboards%
		{
			hkl := GetKbdHKL(A_Index)
			setformat IntegerFast, hex
			hkl += 0
			hklStr := substr("." . hkl, 2)  ; get a copy fixed as a string while in hex
			;outputdebug Did InKey load this HKL? %hkl%
			setformat IntegerFast, dec
			if (hkl and InStr(InkeyLoadedHKLs, hklStr, false)) {
			; if (1) {
				; Outputdebug Unloading hkl %hklStr%
				DllCall("UnloadKeyboardLayout", Uint, hkl)
			} else {
				setformat IntegerFast, hex
				outputdebug HKL %hklStr% was not unloaded (kbd = %A_Index%)
				setformat IntegerFast, dec
			}
		}

		if (not InStr("Shutdown Logoff Reload Single", A_ExitReason)) {  ; No need to refresh Lang Bar if we're restarting InKey or shutting down the workstation.
			IniRead ii, %InKeyINI%, InKey, RefreshLangBarOnExit, %A_Space%
			if (ii)
				RefreshLangBar()
			else {
				; A trick to refresh the language bar for all top-level windows.
				; Fast and invisible, but might leave "Unknown language" as an inactive option in the LangBar
				DllCall("UnloadKeyboardLayout","uint",0x40905fe)
				x := LoadKeyboardLayout("000005FE")
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, x)  ; KBD_HKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
				DllCall("UnloadKeyboardLayout","uint",KBD_HKL0)
				klid := "0000" . A_Language
				KBD_HKL0 := LoadKeyboardLayout(klid, 18)
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; KBD_HKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
				DllCall("UnloadKeyboardLayout","uint",x)
				DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; KBD_HKL0  0x50 = WM_INPUTLANGCHANGEREQUEST
			}
		}
	}
	DllCall("FreeLibrary", UInt, hMSVCRT)
	outputdebug Exiting InKey normally
	ExitApp

DoHelp:
	Run http://inkeysoftware.com/userguide.html
	return

$#V::ShowOnScreen()  ; TODO: map to user-config hotkey / menu

ShowOnScreen() {
	global
	if (ActiveKbd) {
		local kbdHwnd := GetKbdHwnd(ActiveKbd)
		if (kbdHwnd) {
			;~ OutputDebug showonscreen
			VKbdHwnd := DllCall("SendMessage", UInt, kbdHwnd, UInt, 0x8004)
			VKbdShowing := 1
		}	; TODO:  Kbd should send a message to set VKbdShowing to 0 when closed, for faster _ChangeText
	}
}

DeactivateKbd() {
	global
	if (ActiveKbd) {
		local kbdHwnd := GetKbdHwnd(ActiveKbd)
		local sv := 0
		if (kbdHwnd)
			sv := DllCall("SendMessage", UInt, kbdHwnd, UInt, 0x8001)
		if (sv <> 3)
			outputdebug ***Error: could not suspend %ActivekbdFile%
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

	if ((la <> SelfHwnd) and (la <>0) and (la <> VKbdHwnd)) {
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
	global	VKbdHwnd
	global	VKbdShowing
	initContext()
	s := n . "|" . GetKbdParams(n)
	rk := Send_WM_COPYDATA(n, 0x9201, s)
	outputdebug ReinitKeyboard(%n%) Send_WM_COPYDATA => %rk%  .  s = "%s%"
	if (rk=3)  ; Means that InKeyLib.ahki received and processed it OK.
		return 0
	if (rk>10) {  ; Means that a virtual keyboard was reinintialized, and this is its handle
		VKbdHwnd := rk
		VKbdShowing := 1
		return 0
	}
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

	ii := KBD_MenuText%ActiveKbd%
	Menu KbdMenu, UseErrorLevel
	if (not ii)
		outputdebug ERROR: No KBD_MenuText%activekbd%
	Menu KbdMenu, Uncheck, %ii%
	ActiveKbd := kbd
	ii := KBD_MenuText%ActiveKbd%
	Menu KbdMenu, Check, %ii%
}


ActivateKbd(kbd, hkl) {
	global

	if (not KBD_File%kbd%) {  ; If new locale does not map to an InKey keyboard...
		if (ActiveKbd > 0 and KBD_File%ActiveKbd%) 	; If there was already an active InKey keyboard,
			DeactivateKbd()		;  deactivate it.
		; if (KbdIconFile%kbd%)
			; Menu Tray, Icon, KbdIconFile%kbd%, KBD_IconNum%kbd%
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
		kbdid := KBD_FileID%kbd%
		; NewKbdParams := selfHwnd . " " . KBD_FileID%kbd% . " " . kbd . " " . GetKbdParams(kbd)
		;;first 3 parameters are InKeyHwnd, FileID, KbdId
		; if (SubStr(NewKbdFile, -3) = ".ahk")
			; RunCmd := "AutoHotKey.exe "
		; else
			; RunCmd =
		; RunCmd .= KBD_Folder%kbd% . "\" . NewKbdFile . " " . NewKbdParams
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
		KBD_FileHwnd%kbdid% = 0
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
					{	DllCall("PostMessage", "UInt", 0xffff, UInt, 0x50, UInt, 1, UInt, KBD_HKL0)  ; Change all windows to default lang.
						ActivateKbd(0, KBD_HKL0)
						return
					}
				} else {
					KBD_FileHwnd%kbdid% := WinExist("ahk_pid " . OutputVarPID)
					OutputDebug % "KbdFileHwnd" . kbdid . "=" . KBD_FileHwnd%kbdid%
					;DllCall("SendMessage", "UInt", KBD_FileHwnd%kbdid%, UInt, 0x8100)
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
	;~ OutputDebug % "temphkl=" temphkl " ohkldisplayname=>" oHKLDisplayName[TempHKL]
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
	local kbdid := KBD_FileID%n%
	if (not KBD_FileHwnd%kbdid%)
		return 0
	local kbdHwnd := WinExist("ahk_id " . KBD_FileHwnd%kbdid%) ; TODO Faster: DllCall IsWindow
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
		; outputdebug Count=%A_Index%, Trying %HexString%
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
	{	kk := KBD_MenuText%A_Index%
		;outputdebug kbdbymenutext trying KBD_MenuText%A_Index% => %kk%
		if (KBD_MenuText%A_Index% = mtxt)
			return %A_Index%
	}
	;outputdebug KbdByMenuText: no match
	return 0
}

KbdByLayoutName(mtxt) {
	global
	;outputdebug KbdByLayoutName(%mtxt%)
	Loop %numKeyboards%
	{	kk := KBD_LayoutName%A_Index%
		;outputdebug kbdbyLayoutName trying KBD_LayoutName%A_Index% => %kk%
		if (KBD_LayoutName%A_Index% = mtxt)
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
	return KBD_HKL%n%
}

GetKbdFile(n) {
	return KBD_File%n%
}

GetKbdHotkey(n) {
	return KBD_Hotkey%n%
}

GetKbdIconFile(n) {
	return KbdIconFile%n%
}

GetKbdIconNum(n) {
	return KBD_IconNum%n%
}

GetKbdParams(n) {
	return KBD_Params%n%
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
	setformat, integerfast, H
	InputLocaleID:= ( DllCall("GetKeyboardLayout", "UInt", ThreadID) & 0xffffffff )
	; outputdebug GetActiveHKL() =>  %InputLocaleID%
	setformat, integerfast, D
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
~^v::
~+Ins::
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

DblTapToggleKbd:
	if (dblTap = 5) {
		dblTap =
		goto HotkeyToggleKbd
	} else {
		dblTap = 5
		SetTimer DoubleTapTimer, -400
	}
	return

HotkeyToggleKbd:
	OutputDebug ActiveKbd = %Activekbd%, LastActiveKbd = %lastactivekbd%
	;~ pausedKbd := ActiveKbd
	RequestKbd(ActiveAtLastReq)
	;~ LastActiveKbd := pausedKbd
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
		Send {Shift Down}{Shift Up}{Ctrl Down}{Ctrl Up}{Alt Down}{Alt Up}
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
	Send ^+{Left}^c			; Send Ctrl+Shift+Left to select, and then Ctrl+C to copy
	ClipWait 2	; Wait for clipboard
	if (errorlevel) {
		outputdebug No clipboard text found for refreshContext.
	} else {
		Send ^+{Right}{Left}  ; To unselect text to the left   ;TODO :BUG Does not work if text is last thing on line, moves left one.
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
	;outputdebug defhkl = %defhkl%
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

Char(codePt) {
; Use this instead of AHK's Chr() function if you need to handle SMP characters too.
	if (codePt > 0xffffffff)   ; Invalid Unicode
		return ""
	if (codePt & 0xffff0000) { ; SMP character. Convert to surrogate pair
		codePt -= 0x10000
		return Chr((0xd800 | (codePt >> 10))) . chr((0xdc00 | (codePt & 0x3ff)))
	}
	return chr(codePt)         ; BMP character.
}

; Convert any 〔 〕 hex codes to characters
HexCodes2Chars(strIn) {
	; local m1
	; local v1
	; local rr
	local bail := 0
	while (RegExMatch(strIn, "O)〔([0-9A-Fa-f]+)〕", m1)) {
		v1 := "0x" m1.Value(1)
		v1 += 0
		if (v1 < 32) {
			rr := "\x{" m1.Value(1) "}"
		} else {
			rr := Char(v1)
		}
		strIn := RegExReplace(strIn, m1.Value(0), rr)  ; TODO: For efficiency, avoid this whole reassign

		bail += 1
		if (bail > 200) {
			ff := m1.Value(0)
			rr := Char(v1)
			msgbox 0, fatal, convert hex chars failed: '%ff%'->'%rr%'  ; TODO: don't fail with msgbox (it's behind splash screen)
			break
		}
	}
	return strIn
}

evalExpr(e) {
	if (e = "" or e = "0")
		return 0
	if (RegExMatch(e, "^\d+$"))
		return e + 0
	if (RegExMatch(e, "^(.*?)\s*([=<>&|^]+)\s*(.*?)$", ov)) {
		if (ov2 = "=")
			return (evalExpr(ov1) = evalExpr(ov3))
		if (ov2 = "<")
			return (evalExpr(ov1) < evalExpr(ov3))
		if (ov2 = ">")
			return (evalExpr(ov1) > evalExpr(ov3))
		if (ov2 = "<>")
			return (evalExpr(ov1) <> evalExpr(ov3))
		if (ov2 = "|")
			return (evalExpr(ov1) or evalExpr(ov3))
		if (ov2 = "&")
			return (evalExpr(ov1) and evalExpr(ov3))
		if (ov2 = "^")
			return (evalExpr(ov1) ^ evalExpr(ov3))
		outputdebug Unrecognized operator in expression: %e%
		return 0
	}
	return e
}

rulesRE(key) {
	return 	"Om)^(\Q" key "\E)\s*>\s*(\S.*(\r?\n\s+.*)*\r?\n?)"
	; return 	"O)^(?:\r?\n?)*(\Q" key "\E)\s*>\s*(\S.*(\r?\n\s+.*)*\r?\n?)"
}

translateRules(ruleStr) {
	global
	local trans := ""
	ruleStr :=  RegExReplace(ruleStr, "([``""])", "$1$1")  ; 1st escape ALL backticks and double-quotes to work with AHK syntax
	ruleStr := RegExReplace(ruleStr, "\r?\n\s+\|\s*", chr(0xfffe)) ; mark split points between alternate rules (sep by vert bar)
	ruleStr := RegExReplace(ruleStr, "\r?\n\s+", " ")  ; unwrap lines
	local rules := StrSplit(ruleStr, chr(0xfffe))
	for index, element in rules {
		if (index > 1)
			trans .= "  || "

		; TODO: implement IfPhase, SetPhase, &, +, _

		; map|loopMap|multiTapMap|multiTapSend 【 】+
		if (RegExMatch(element, "Oi)^(map|loopMap|multiTapMap|multiTapSend)\s*((【.*?】\s*?)+)\s*$", m2)) {
		; if (RegExMatch(element, "Oi)^(map|loopMap|multiTapMap)\s*((【.*?】\s*?)+)\s*$", m2)) {
			local mapType := m2.Value(1)
			local mapParams := RegExReplace(m2.Value(2), "】\s*【", chr(0x22) chr(0x2c) " " chr(0x22))
			mapParams := RegExReplace(mapParams, "[【】]", chr(0x22))
			trans .= "InCase(" mapType "(" mapParams "))`n"

		; (After 【 】)? Replace 【 】 with 【 】 (usingMap|usingLoopMap 【 】+)?
		} else if (RegExMatch(element, "Oi)^(after\s*【(.*?)】\s*)?replace\s*【(.*?)】\s*with\s*【(.*?)】\s*( using(Loop)?Map\s*((【.*?】\s*)+))?\s*$", m2)) {
			local aft =
			if (m2.Value(1))
				aft := "After(" chr(34) m2.Value(2) chr(34) ") "
			local rep := m2.Value(3)
			local wth := m2.Value(4)
			local using =
			if (m2.Value(5)) {
				local mapParams := RegExReplace(m2.Value(7), "】\s*【", chr(0x22) chr(0x2c) " " chr(0x22))
				mapParams := RegExReplace(mapParams, "[【】]", chr(0x22))
				using := " using" m2.Value(6) "Map(" RegExReplace(mapParams, "[【】]", chr(0x22)) ")"
			}
			trans .= "InCase(" aft "Replace(""" rep """) with(""" wth """)" using ")`n"

		; after 【 】 send 【 】
		} else if (RegExMatch(element, "Oi)^after\s*【(.*?)】\s*send\s*【(.*?)】\s*$", m2)) {
			local rep := m2.Value(1)
			local wth := m2.Value(2)
			trans .= "InCase(After(""" rep """) thenSend(""" wth """))`n"

		; 【 】
		} else if (RegExMatch(element, "Oi)^【(.*?)】\s*$", m2)) {
			local rep := m2.Value(1)
			if (InStr(rep, " ")) {
				trans .= "InCase(MultiTapSend(""" rep """))`n"
			} else {
				trans .= "Send(""" rep """)`n"
			}
		; beep
		} else if (RegExMatch(element, "Oi)^beep\s*$", m2)) {
			trans .= "Beep()`n"

		} else {
			outputdebug Rule not parsed: %element%
			tinkWarnings += 1
			trans .= " `; Rule not parsed: " . element
		}
	} ; end for ... rules
	return trans
}

versionNum(s) {  ; Given a version string like 2.0.0.12, returns a numeric value for comparison,
				 ; treating the 4th segement as a 3-digit number.
				 ; Thus 1.2.3.45 => 1.23045, and 1.234 => 1.23004
				 ; 2nd and 3rd segments MUST be single-digit.
	if (not RegExMatch(s, "O)(\d++)\.?+(\d)?+\.?+(\d)?+\.?+(\d++)?+", vmatch))
		return 0
	return vmatch.Value(1) + (vmatch.Value(2) / 10) + (vmatch.Value(3) / 100)+ (vmatch.Value(4) / 100000)
}

#include Config.ahk	; Configuration GUI (GUI 3) routines
#include Validate.ahk	; Validation and splash screen (GUI 1) routines
#include Comm.ahk	; Interprocess communication and stack management
; #include iSendU.ahk	; InKey's customized version of the SendU module
#include KeyboardConfigure.ahk ; Keyboard Configuration GUI (GUIs 5-7)
#include LangConversions.ahk
#include Lang.ahk ; Internationalisation routines