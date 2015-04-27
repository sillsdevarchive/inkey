; Section of code relating to the configuration GUI

WelcomeToInKey:   ; Called on startup when no languages are loaded
	welcome = 1		; Whether to display the welcome message
	startingTab = 1		; Which tab to start on
	goto DoConfigure

DoConfigureInKey:
	welcome = 0		; Whether to display the welcome message
	startingTab = 2		; Which tab to start on
	goto DoConfigure

; Before coming here, ensure that welcome and startingTab variables have been set appropriately
DoConfigure:
	; check to see if configuration window is already open

	If currentconfigure
	{
		Gui, 3:Show
		return
	}

	currentconfigure=1

	needsRestart = 0	; Flag indicating whether configuration changes requiring a restart have been made
	TempString:=GetLang(12)
	Gui, 3:Add, Button, x130 y540 w100 h30 Default g3OKButton, %TempString%  ; OK
	TempString:=GetLang(13)
	Gui, 3:Add, Button, x270 y540 w100 h30 g3CancelButton, %TempString% ; Cancel
	TempString:=GetLang(14) . "|" . GetLang(15) . "|" . GetLang(16)  ; Add/Configure Keyboards|InKey Options|InKey Hotkeys
	Gui, 3:Add, Tab, x10 y10 w440 h520 gOnTabChange vTabNum AltSubmit Choose%startingTab%, %TempString%

	; TAB #1:  ADD/CONFIGURE KEYBOARDS
	Gui, 3:Tab, 1
	TempString:=GetLang(17)
	Gui, 3:Add, Text, x20 y50 w420 h20 , %TempString%  ; Place a check next to a keyboard to enable it
	TempString:=GetLang(18) . "|" . GetLang(19) . "|" . GetLang(20)  ; Load|Keyboard|File
	Gui, 3:Add, ListView, x20 y80 w420 h380 +Checked -Multi AltSubmit gOnConfigListEvent, %TempString%
	TempString:=GetLang(21)
	Gui, 3:Add, Button, x20 y466 w200 h56 gInstallMore,  %TempString%  ; Install new keyboard or update `nexisting keyboard from file...
	TempString:=GetLang(22)
	Gui, 3:Add, Button, x240 y466 w200 h56 Disabled vConfigureKeyboardButton gConfigureHighlightedKeyboard, %TempString% ; Configure selected keyboard...
	Gui, 3:Default
	FillKbdListAll()	; Add ALL keyboards to the listview control

	; TAB #2:  INKEY OPTIONS
	Gui, 3:Tab, 2
	IniRead, PortableMode, %InKeyINI%, InKey, PortableMode   ; Setting might be 0, but variable was temporarily 1, so re-read setting
	IniRead, RefreshLangBarOnExit, %InKeyINI%, InKey, RefreshLangBarOnExit
	;~ IniRead, NoSplash, %InKeyINI%, InKey, NoSplash	; Read in Validate.ahk, but value sometimes gets lost ; Wasn't global there.
	; store current values, to compare with user's new selections
	if (not driveIsFixed)
		StartWithWindows = 0
	OldStartWithWindows := StartWithWindows
	OldPortableMode := PortableMode
	OldNoSplash := NoSplash
	OldFollowWindowsLocale := FollowWindowsInputLanguage
	OldLeaveKeyboardsLoaded := LeaveKeyboardsLoaded
	OldRefreshLangBarOnExit := RefreshLangBarOnExit
	OldRefreshLangBarOnLoad := RefreshLangBarOnLoad
	OldShowKeyboardNameBalloon := ShowKeyboardNameBalloon
	OldPreviewAtCursor := PreviewAtCursor
	OldUnderlyingLayout := UnderlyingLayout
	OldRotaPeriod := rotaPeriod
	OldUseAltLangWithoutPrompting := UseAltLangWithoutPrompting

	; create GUI using values from ini file
	disabledSWW := driveIsFixed ? 0 : 1
	TempString:=GetLang(23)
	Gui, 3:Add, CheckBox, x20 y48 Section Checked%StartWithWindows% disabled%disabledSWW% vStartWithWindows, %TempString%  ; Start with Windows
	TempString:=GetLang(24)
	Gui, 3:Add, CheckBox, Checked%PortableMode% vPortableMode, %TempString%  ; Portable Mode
	TempString:=GetLang(25)
	Gui, 3:Add, CheckBox, Checked%FollowWindowsInputLanguage% vFollowWindowsInputLanguage, %TempString%  ; Follow Windows' Input Language
	TempString:=GetLang(26)
	Gui, 3:Add, CheckBox, Checked%RefreshLangBarOnLoad% vRefreshLangBarOnLoad, %TempString%  ; Refresh Language Bar on Startup
	TempString:=GetLang(27)
	Gui, 3:Add, Text, xs+19 yp+20, %TempString%  ; (Opens and closes 'Text Services and Input Languages' window.)
	TempString:=GetLang(28)
	Gui, 3:Add, CheckBox, xs Checked%RefreshLangBarOnExit% vRefreshLangBarOnExit, %TempString%  ; Refresh Language Bar on Exit
	TempString:=GetLang(29)
	Gui, 3:Add, CheckBox, Checked%LeaveKeyboardsLoaded% disabled vLeaveKeyboardsLoaded, %TempString%  ; Leave Keyboards Loaded	; This feature is only half-developed.  Let's disable it from the GUI for now.
	TempString:=GetLang(30)
	Gui, 3:Add, CheckBox, Checked%UseAltLangWithoutPrompting% vUseAltLangWithoutPrompting, %TempString%  ; Use Alternate Language Without Prompting
	TempString:=GetLang(31)
	Gui, 3:Add, Text, xs, %TempString%  ; Underlying Layout:
	; convert UnderlyingLayout from a number to meaningful text
	; UnderlyingLayout specifies which Keyboard Layout ID (KLID) in [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts] the InKey keyboards should be based on.
	UnderlyingLayoutKLIDs := "00000409,00000406,00000413,0000040B,0000040C,00000407,0000080A,00000414,00010415,00000419,0000040A,0000041D,00000809,00000452,00010409,00020409"  ; We can supplement this list with other likely KLIDs.
	idx := InStr(UnderlyingLayoutKLIDs, UnderlyingLayout)  ; idx will be the index of which of these layouts is currently selected
	if (idx) {
		idx := ((idx - 1) / 9) + 1
	} else {	; Allow for a KLID that wasn't in our list.
		idx := (strlen(UnderlyingLayoutKLIDs) + 1) / 9 + 1
		UnderlyingLayoutKLIDs := UnderlyingLayoutKLIDs . "," . UnderlyingLayout
		UnderlyingLayoutName := UnderlyingLayoutNames
	}
	UnderlyingLayoutNames := ""  	; String for filling the drop-down list with layout names
	UnderlyingLayoutPairs := ""		; String for looking up the KLID again later, given the chosen layout name
	Loop Parse, UnderlyingLayoutKLIDs, `,
	{	; Look up the name associated with the KLID
		RegRead layoutName, HKLM, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%A_LoopField%, Layout Text
		if (not layoutName)
			layoutName := "invalid layout"
		if (UnderlyingLayoutNames) {
			UnderlyingLayoutNames := UnderlyingLayoutNames . "|" . layoutName
			UnderlyingLayoutPairs := UnderlyingLayoutPairs . A_LoopField . "|" . layoutName . "|"
		} else {
			UnderlyingLayoutNames := layoutName
			UnderlyingLayoutPairs := "|" . A_LoopField . "|" . layoutName . "|"
		}
	}
	Gui, 3:Add, DropDownList, xs+180 yp Choose%idx% vUnderlyingLayoutText, %UnderlyingLayoutNames%
	TempString:=GetLang(32)
	Gui, 3:Add, CheckBox, xs Checked%ShowKeyboardNameBalloon% vShowKeyboardNameBalloon, %TempString%  ; Show Keyboard Name Balloon
	TempString:=GetLang(33)
	Gui, 3:Add, CheckBox, Checked%PreviewAtCursor% vPreviewAtCursor, %TempString%  ; Show the Rota Preview Window at Cursor
	TempString:=GetLang(34)
	Gui, 3:Add, Text, xs, %TempString%  ; Speed Rota Period:
	Gui, 3:Add, Edit, xs+180 yp-4 w40 vrotaPeriod, %rotaPeriod%
	TempString:=GetLang(35)
	Gui, 3:Add, Text, xs+225 yp+4, %TempString%  ; milliseconds
	TempString:=GetLang(36)
	Gui, 3:Add, Checkbox, xs Checked%NoSplash% vNoSplash, %TempString%  ; Disable Splash Screen at Startup
	TempString:=GetLang(37)
	Gui, 3:Add, Text, xs, %TempString%  ; Interface Language:
	AvailableLangs =
	idx := 0
	Loop, %A_WorkingDir%\Langs\*.ini
	{
		StringLeft, Filename, A_LoopFileName, StrLen(A_LoopFileName) - 4
		outputdebug CurrentLang=%CurrentLang%, Filename=%Filename%, Counter=%A_Index%
		if (Filename = CurrentLang)
			idx := A_Index
		if (AvailableLangs)
			AvailableLangs := AvailableLangs . "|" . Filename
		else
			AvailableLangs := Filename
	}
	Gui, 3:Add, DropDownList, xs+180 yp Choose%idx% vCurrentLangText, %AvailableLangs%

	TempString:=GetLang(153) " " A_WorkingDir    ; InKey folder:
	Gui, 3:Add, Text, xs yp+30, %TempString%
	TempString:=GetLang(154)  ; Open
	Gui, 3:Add, Button, xs yp+20 w160 h20 gOpenInKeyFolder, %TempString%

	; TAB #3: INKEY HOTKEYS
	Gui, 3:Tab, 3
	TempString:=GetLang(38)
	Gui, 3:Add, Text, x320 y38 h20 Section, %TempString%  ; Special Keys:
	Gui, 3:Add, Text, xs+50 yp+18 h20, ^ = CTRL
	Gui, 3:Add, Text, xs+50 yp+18 h20, # = WIN
	Gui, 3:Add, Text, xs+50 yp+18 h20, + = SHIFT
	Gui, 3:Add, Text, xs+50 yp+18 h20, ! = ALT
	TempString:=GetLang(39)
	Gui, 3:Add, Text, x36 y38 h20 Section, %TempString%  ; Instructions:
	TempString:=GetLang(40)
	Gui, 3:Add, Text, xs+10 yp+18 h20, %TempString%  ; Type the hotkey combination in the box.
	TempString:=GetLang(41)
	Gui, 3:Add, Text, xs+10 yp+18 h20, %TempString%  ; Clear box to disable hotkey.
	IniRead, DefaultKbdHotkey, %InKeyINI%, InKey, DefaultKbdHotkey
	OldDefaultKbdHotkey := DefaultKbdHotkey
	TempString:=GetLang(42)
	Gui, 3:Add, Text, x36 yp+28 w220 Section, %TempString%  ; Change to default keyboard:
	Gui, 3:Add, Edit, x270 yp w80 vDefaultKbdHotkey, %DefaultKbdHotkey%

	IniRead, DefaultKbdDoubleTap, %InKeyINI%, InKey, DefaultKbdDoubleTap
	OldDefaultKbdDoubleTap := DefaultKbdDoubleTap
	TempString:=GetLang(43)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change to default keyboard with double-tap:
	Gui, 3:Add, Edit, x270 yp w80 vDefaultKbdDoubleTap, %DefaultKbdDoubleTap%

	IniRead, NextKbdHotkey, %InKeyINI%, InKey, NextKbdHotkey
	OldNextKbdHotkey := NextKbdHotkey
	TempString:=GetLang(44)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change to next keyboard:
	Gui, 3:Add, Edit, x270 yp w80 vNextKbdHotkey, %NextKbdHotkey%

	IniRead, NextKbdDoubleTap, %InKeyINI%, InKey, NextKbdDoubleTap
	OldNextKbdDoubleTap := NextKbdDoubleTap
	TempString:=GetLang(45)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change to next keyboard with double-tap:
	Gui, 3:Add, Edit, x270 yp w80 vNextKbdDoubleTap, %NextKbdDoubleTap%

	IniRead, PrevKbdHotkey, %InKeyINI%, InKey, PrevKbdHotkey
	OldPrevKbdHotkey := PrevKbdHotkey
	TempString:=GetLang(46)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change to previous keyboard:
	Gui, 3:Add, Edit, x270 yp w80 vPrevKbdHotkey, %PrevKbdHotkey%

	IniRead, PrevKbdDoubleTap, %InKeyINI%, InKey, PrevKbdDoubleTap
	OldPrevKbdDoubleTap := PrevKbdDoubleTap
	TempString:=GetLang(47)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change to previous keyboard with double-tap:
	Gui, 3:Add, Edit, x270 yp w80 vPrevKbdDoubleTap, %PrevKbdDoubleTap%

	IniRead, ToggleKbdHotkey, %InKeyINI%, InKey, ToggleKbdHotkey
	OldToggleKbdHotkey := ToggleKbdHotkey
	TempString:=GetLang(151)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Toggle keyboard:
	Gui, 3:Add, Edit, x270 yp w80 vToggleKbdHotkey, %ToggleKbdHotkey%

	IniRead, ToggleKbdDoubleTap, %InKeyINI%, InKey, ToggleKbdDoubleTap
	OldToggleKbdDoubleTap := ToggleKbdDoubleTap
	TempString:=GetLang(152)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Toggle keyboard with double-tap:
	Gui, 3:Add, Edit, x270 yp w80 vToggleKbdDoubleTap, %ToggleKbdDoubleTap%

	IniRead, MenuHotkey, %InKeyINI%, InKey, MenuHotkey
	OldMenuHotkey := MenuHotkey
	TempString:=GetLang(48)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Keyboard menu pop-up:
	Gui, 3:Add, Edit, x270 yp w80 vMenuHotkey, %MenuHotkey%

	IniRead, MenuDoubleTap, %InKeyINI%, InKey, MenuDoubleTap
	OldMenuDoubleTap := MenuDoubleTap
	TempString:=GetLang(49)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Keyboard menu pop-up with double-tap:
	Gui, 3:Add, Edit, x270 yp w80 vMenuDoubleTap, %MenuDoubleTap%

	IniRead, ChangeSendingMode, %InKeyINI%, InKey, ChangeSendingMode
	OldChangeSendingMode := ChangeSendingMode
	TempString:=GetLang(50)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Change sending mode:
	Gui, 3:Add, Edit, x270 yp w80 vChangeSendingMode, %ChangeSendingMode%

	IniRead, ResyncHotkey, %InKeyINI%, InKey, ResyncHotkey
	OldResyncHotkey := ResyncHotkey
	TempString:=GetLang(51)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Resync InKey:
	Gui, 3:Add, Edit, x270 yp w80 vResyncHotkey, %ResyncHotkey%

	IniRead, ReloadHotkey, %InKeyINI%, InKey, ReloadHotkey
	OldReloadHotkey := ReloadHotkey
	TempString:=GetLang(52)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Reload InKey:
	Gui, 3:Add, Edit, x270 yp w80 vReloadHotkey, %ReloadHotkey%

	IniRead, GrabContextHotkey, %InKeyINI%, InKey, GrabContextHotkey
	OldGrabContextHotkey := GrabContextHotkey
	TempString:=GetLang(53)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Grab context:
	Gui, 3:Add, Edit, x270 yp w80 vGrabContextHotkey, %GrabContextHotkey%

	IniRead, AutoGrabContextHotkey, %InKeyINI%, InKey, AutoGrabContextHotkey
	OldAutoGrabContextHotkey := AutoGrabContextHotkey
	TempString:=GetLang(54)
	Gui, 3:Add, Text, xs w220, %TempString%  ; Toggle Auto Grab context:
	Gui, 3:Add, Edit, x270 yp w80 vAutoGrabContextHotkey, %AutoGrabContextHotkey%

	TempString:=GetLang(55)
	Gui, 3:Add, Button, xs yp+30 w160 h20 gRestoreDefaults, %TempString%  ; Restore Defaults

	Gui, 3:Show, xCenter yCenter h580 w460, InKey Options
	if (welcome)
	{
		WelcomeString:=GetLang(56) ; Welcome to InKey!
		TempString:=GetLang(57) . "`n`n" . GetLang(58) ; Please begin by selecting the keyboards you would like to load.`n`nNote: To adjust the options for some of the keyboards you may need to manually edit the configuration files.
		MsgBox 0, %WelcomeString%, %TempString%
		welcome = 0
	}
	Return

OpenInKeyFolder:
run explorer "%A_workingdir%"
return

RestoreDefaults:
	GuiControl,, DefaultKbdHotkey, ^#Down
	GuiControl,, DefaultKbdDoubleTap, RShift
	GuiControl,, NextKbdHotkey, ^#Right
	GuiControl,, PrevKbdHotkey, ^#Left
	GuiControl,, ToggleKbdHotkey, ^#/
	GuiControl,, NextKbdDoubleTap, RControl
	GuiControl,, PrevKbdDoubleTap, LControl
	GuiControl,, ToggleKbdDoubleTap, LAlt
	GuiControl,, MenuHotkey, ^#Up
	GuiControl,, MenuDoubleTap, LShift
	GuiControl,, ChangeSendingMode, ^#=
	GuiControl,, ResyncHotkey, #F12
	GuiControl,, ReloadHotkey, ^#F12
	GuiControl,, GrabContextHotkey, F12
	GuiControl,, AutoGrabContextHotkey, +F12
	Return

FillKbdListAll() {
	global AllowUnsafe
	ImageListID := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
	LV_SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
	tFolderList =
	idx1 = 0
	Loop, *.*, 2
		tFolderList = %tFolderList%%A_LoopFileName%`n
	Sort, tFolderList
	Loop, parse, tFolderList, `n
	{	if (A_LoopField = "" or (InStr(A_LoopField, ".") and (A_LoopField <> ".nonInkey"))) ; Ignore the blank item at the end of the list, and ignore any folder containing a dot in the name.
			continue

		tmpCurrFolder := A_LoopField
		tmpCurrKbdTinkerFile := ""
		tmpCurrKbdCmd := ""
		if (FileExist(tmpCurrFolder "\" tmpCurrFolder ".tinker")) {
			tmpCurrKbdTinkerFile := tmpCurrFolder "\" tmpCurrFolder ".tinker"
			tmpCurrKbdCmd := tmpCurrFolder . ".ahk"
		} else if (AllowUnsafe and FileExist(tmpCurrFolder "\" tmpCurrFolder ".ahk")) {
			tmpCurrKbdCmd := tmpCurrFolder . ".ahk"
		} else if (A_LoopField <> ".nonInkey") {
			continue
		}

		; Loop for each *.kbd.ini file
		tKbdList =
		Loop, %A_LoopField%\*.kbd.ini
			tKbdList = %tKbdList%%A_LoopFileName%`n
		Sort, tKbdList
		global StoreUserSettingsInAppData, BaseSettingsFolder
		Loop, parse, tKbdList, `n
		{	if (A_LoopField = "") ; Ignore the blank item at the end of the list.
				continue
			tmpCurrIni = %tmpCurrFolder%\%A_LoopField%
			if (StoreUserSettingsInAppData) {
				tmpCurrIni := BaseSettingsFolder "\" tmpCurrIni
			}

			idx1++
;		outputdebug processing file: %tmpCurrIni%
			IniRead, enabled, %tmpCurrIni%, Keyboard, Enabled, 1
			chk := (enabled) ? "check " : ""
			IniRead, KbdLayoutName, %tmpCurrIni%, Keyboard, LayoutName, %A_Space%
			IniRead, KbdIcon, %tmpCurrIni%, Keyboard, Icon, %A_Space%
			KbdIcon = %tmpCurrFolder%\%KbdIcon%
			ii1 := IL_Add(ImageListID, KbdIcon)  ; Omits the DLL's path so that it works on Windows 9x too.
;~ outputdebug	kbdicon=%Kbdicon%	ii1=%ii1% iconIdx=%iconIdx%	LV_Add(%chk%%iconIdx%, "", KbdLayoutName, tmpCurrIni)
			iconIdx := (ii1) ? " Icon" . ii1 : ""
			LV_Add(chk . iconIdx, "", KbdLayoutName, tmpCurrFolder "\" A_LoopField)
		}
	}
	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	LV_Modify(0, "-Select") ; De-select all rows
}

OnConfigListEvent:
	RowNumber := LV_GetNext(0)  ; Search list view from top of list
	if not RowNumber  ; The above returned zero, so there are no selected rows.
	{
		GuiControl, 3:Disable, ConfigureKeyboardButton
	}
	else
	{
		GuiControl, 3:Enable, ConfigureKeyboardButton
	}

	if A_GuiEvent = I  ; I = Item changed
	{
		If InStr(ErrorLevel, "C", true)  ; C = checked
		{
			LV_Modify(A_EventInfo, "Select")
		}
	}
	;outputdebug A_GuiEvent=%A_GuiEvent%, A_EventInfo=%A_EventInfo%, ErrorLevel=%ErrorLevel%
	return

ConfigureHighlightedKeyboard:
	SetWorkingDir %A_ScriptDir%

	RowNumber := LV_GetNext()
	if not RowNumber
	{
		TempString:=GetLang(100)
		MsgBox %TempString%  ; Please select a keyboard to configure...
		return
	}

	LV_GetText(TempKeyboardName, RowNumber, 2)
	LV_GetText(FileInfo, RowNumber, 3)
	global StoreUserSettingsInAppData, BaseSettingsFolder
	if (StoreUserSettingsInAppData) {
		FileInfo := BaseSettingsFolder "\" FileInfo
	}

	; check to see if keyboard is in the list of active keyboards
	tempkbd := KbdByLayoutName(TempKeyboardName)

	if (tempkbd = 0)
	{
		tempkbd := numKeyboards+1
		Loop, Parse, FileInfo, \
		{
			If A_Index=1
			{
				KBD_Folder%tempkbd% = %A_LoopField%
			}
		}
		KBD_IniFile%tempkbd% = %FileInfo%
		IniRead, KBD_LayoutName%tempkbd%, %FileInfo%, Keyboard, LayoutName, %A_Space%
		IniRead, KBD_MenuText%tempkbd%, %FileInfo%, Keyboard, MenuText, %A_Space%
		IniRead, KBD_Hotkey%tempkbd%, %FileInfo%, Keyboard, Hotkey, %A_Space%
		IniRead, KBD_Lang%tempkbd%, %FileInfo%, Keyboard, Lang, %A_Space%
		IniRead, KBD_AltLang%tempkbd%, %FileInfo%, Keyboard, AltLang, %A_Space%
		IniRead, KBD_Icon%tempkbd%, %FileInfo%, Keyboard, Icon, %A_Space%
		KbdIconFile%tempkbd% := KBD_Icon%tempkbd%
		if (KbdIconFile%tempkbd%) {
			; If there is a second parameter (after a comma), separate that out.
			if (RegExMatch(KbdIconFile%tempkbd%, "(.*),\s*(.*)", val)) {
				KbdIconFile%tempkbd% = %val1%
				KbdIconNum%tempkbd% = %val2%
			}

			; If the icon file exists in the keyboard's folder, prepend path.
			if (FileExist(KBD_Folder%tempkbd% . "\" . KbdIconFile%tempkbd%))
				KbdIconFile%tempkbd% := KBD_Folder%tempkbd% . "\" . KbdIconFile%tempkbd%
			; otherwise hopefully the file is a system DLL
		}
		IniRead, KBD_Params%tempkbd%, %FileInfo%, Keyboard, Params, %A_Space%
		IniRead, KBD_ConfigureGUI%tempkbd%, %FileInfo%, Keyboard, ConfigureGUI, %A_Space%
		IniRead, KBD_DisplayCmd%tempkbd%, %FileInfo%, Keyboard, LayoutHelp, %A_Space%
		if (not KBD_DisplayCmd%tempkbd%)
			IniRead, KBD_DisplayCmd%tempkbd%, %FileInfo%, Keyboard, DisplayCmd, %A_Space%
		temptext := "*" . KBD_DisplayCmd%tempkbd% . "*"
		If ((KBD_DisplayCmd%tempkbd% = "") or (KBD_DisplayCmd%tempkbd% = " "))
		{
			; do nothing
		}
		else
		{
			KBD_DisplayCmd%tempkbd%  := KBD_Folder%tempkbd% . "\" . KBD_DisplayCmd%tempkbd%
		}

		IniRead, KbdKLID%tempkbd%, %FileInfo%, Keyboard, KLID, %A_Space%
	}

	dd := KBD_Folder%tempkbd%
	SetWorkingDir %dd%
	ConfigureKeyboard(tempkbd)
	SetWorkingDir %A_ScriptDir%
	return

InstallMore:
	TitleString:=GetLang(94)  ; Select a keyboard file...
	TempString:=GetLang(95) . " (*.inkey; *.zip)" ; Keyboard files (*.inkey; *.zip)
	FileSelectFile, ZipPathFile, 3,, %TitleString%, %TempString%
	If Not ErrorLevel
	{
		errorcheck:=installorupdatefromzip(ZipPathFile)
		if errorcheck<>0
			outputdebug Error encountered during keyboard install/update: %errorcheck%
		if errorcheck = 0
		{
			TempString:=GetLang(99) ; Installation complete.
			MsgBox,, %TitleString%, %TempString%

			; need to reload InKey
			needsRestart := 1

			; refresh ListView
			LV_Delete()
			FillKbdListAll()
			goto DoConfigure
		}
	}
	return

SaveTab1Changes() {
	global needsRestart, StoreUserSettingsInAppData, BaseSettingsFolder
	Loop % LV_GetCount()
	{
		RowNumberL := A_Index
		Gui +LastFound
		SendMessage, 4140, RowNumberL - 1, 0xF000, SysListView321  ; 4140 is LVM_GETITEMSTATE.  0xF000 is LVIS_STATEIMAGEMASK.
		BoxIsChecked := (ErrorLevel >> 12) - 1  ; This sets BoxIsChecked to true if RowNumberL is checked or false otherwise.
		LV_GetText(tmpCurrIni, RowNumberL, 3)
		if (StoreUserSettingsInAppData) {
			tmpCurrIni := BaseSettingsFolder "\" tmpCurrIni
		}
		IniRead, enabled, %tmpCurrIni%, Keyboard, Enabled, 1
		if (enabled <> BoxIsChecked) {
			IniWrite, %BoxIsChecked%, %tmpCurrIni%, Keyboard, Enabled
			needsRestart := 1
		}
	}
}

SaveTab2Changes() {
	global
outputdebug SaveTab2Changes
	Gui, 3:Submit, NoHide ; update variables with user selections
	UnderlyingLayout := SubStr(UnderlyingLayoutPairs, InStr(UnderlyingLayoutPairs, "|" . UnderlyingLayoutText . "|") - 8, 8)  ; bars ensure we don't match a name of which UnderlyingLayoutText is actually only a substring.  e.g. "US International" with "US"

	If ((OldStartWithWindows <> StartWithWindows) or (OldPortableMode <> PortableMode) or (OldFollowWindowsLocale <> FollowWindowsInputLanguage) or (OldLeaveKeyboardsLoaded <> LeaveKeyboardsLoaded) or (OldRefreshLangBarOnExit <> RefreshLangBarOnExit) or (OldRefreshLangBarOnLoad <> RefreshLangBarOnLoad) or (OldShowKeyboardNameBalloon <> ShowKeyboardNameBalloon) or (OldPreviewAtCursor <> PreviewAtCursor) or (OldUnderlyingLayout <> UnderlyingLayout) or (OldRotaPeriod <> rotaPeriod) or (OldUseAltLangWithoutPrompting <> UseAltLangWithoutPrompting) or (OldNoSplash <> NoSplash) or (CurrentLang <> CurrentLangText))
	{	; write new values to ini file
outputdebug options changed... iniwrite
		if (driveIsFixed)
			IniWrite, %StartWithWindows%, %InKeyINI%, InKey, StartWithWindows
		IniWrite, %PortableMode%, %InKeyINI%, InKey, PortableMode
		IniWrite, %NoSplash%, %InKeyINI%, InKey, NoSplash
		IniWrite, %FollowWindowsInputLanguage%, %InKeyINI%, InKey, FollowWindowsInputLanguage
		IniWrite, %LeaveKeyboardsLoaded%, %InKeyINI%, InKey, LeaveKeyboardsLoaded
		IniWrite, %RefreshLangBarOnExit%, %InKeyINI%, InKey, RefreshLangBarOnExit
		IniWrite, %RefreshLangBarOnLoad%, %InKeyINI%, InKey, RefreshLangBarOnLoad
		IniWrite, %UnderlyingLayout%, %InKeyINI%, InKey, UnderlyingLayout
		IniWrite, %ShowKeyboardNameBalloon%, %InKeyINI%, InKey, ShowKeyboardNameBalloon
		IniWrite, %PreviewAtCursor%, %InKeyINI%, InKey, PreviewAtCursor
		IniWrite, %rotaPeriod%, %InKeyINI%, InKey, SpeedRotaPeriod
		IniWrite, %UseAltLangWithoutPrompting%, %InKeyINI%, InKey, UseAltLangWithoutPrompting

		; actually make the changes requested
		If (driveIsFixed and (OldStartWithWindows != StartWithWindows))
			if (StartWithWindows)
				RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey, "%A_ScriptFullPath%"
			else
				RegDelete HKCU, Software\Microsoft\Windows\CurrentVersion\Run, InKey

		outputdebug CurrentLang=%CurrentLang%, NewLang=%CurrentLangText%
		If  (CurrentLang != CurrentLangText)
		{
			; copy new language file from Langs folder into InKey folder, overwriting Lang.ini
			NewLanguage = %A_WorkingDir%\Langs\%CurrentLangText%.ini
			outputdebug New language file=%NewLanguage%
			FileCopy, %NewLanguage%, %A_WorkingDir%\Lang.ini, 1
			CurrentLang := CurrentLangText
			needsRestart = 1
		}
		If ((OldPortableMode != PortableMode) or (OldUnderlyingLayout != UnderlyingLayout))
			needsRestart = 1
	}
}

SaveTab3Changes() {
	global
	Gui, 3:Submit, NoHide ; update variables with user selections
	if DefaultKbdHotkey<>
	{
		If DefaultKbdHotkey <> OldDefaultKbdHotkey
		{
			Hotkey, %OldDefaultKbdHotkey%, OnKbdHotkey, UseErrorLevel Off
			Hotkey, %DefaultKbdHotkey%, OnKbdHotkey, UseErrorLevel On
			IniWrite, %DefaultKbdHotkey%, %InKeyINI%, InKey, DefaultKbdHotkey
		}
	}
	else
	{
		If DefaultKbdHotkey <> OldDefaultKbdHotkey
		{
			Hotkey, %OldDefaultKbdHotkey%, OnKbdHotkey, UseErrorLevel Off
			IniWrite, %DefaultKbdHotkey%, %InKeyINI%, InKey, DefaultKbdHotkey
		}
	}
	if DefaultKbdDoubleTap<>
	{
		If DefaultKbdDoubleTap <> OldDefaultKbdDoubleTap
		{
			Hotkey, %OldDefaultKbdDoubleTap%, DblTapDefKbd, UseErrorLevel Off
			Hotkey, %DefaultKbdDoubleTap%, DblTapDefKbd, UseErrorLevel On
			IniWrite, %DefaultKbdDoubleTap%, %InKeyINI%, InKey, DefaultKbdDoubleTap
		}
	}
	else
	{
		If DefaultKbdDoubleTap <> OldDefaultKbdDoubleTap
		{
			Hotkey, %OldDefaultKbdDoubleTap%, DblTapDefKbd, UseErrorLevel Off
			IniWrite, %DefaultKbdDoubleTap%, %InKeyINI%, InKey, DefaultKbdDoubleTap
		}
	}
	if NextKbdHotkey<>
	{
		If NextKbdHotkey <> OldNextKbdHotkey
		{
			Hotkey, %OldNextKbdHotkey%, RequestNextKbd, UseErrorLevel Off
			Hotkey, %NextKbdHotkey%, RequestNextKbd, UseErrorLevel On
			IniWrite, %NextKbdHotkey%, %InKeyINI%, InKey, NextKbdHotkey
		}
	}
	else
	{
		If NextKbdHotkey <> OldNextKbdHotkey
		{
			Hotkey, %OldNextKbdHotkey%, RequestNextKbd, UseErrorLevel Off
			IniWrite, %NextKbdHotkey%, %InKeyINI%, InKey, NextKbdHotkey
		}
	}
	if NextKbdHotkey<>
	{
		If NextKbdHotkey <> OldNextKbdHotkey
		{
			Hotkey, %OldNextKbdHotkey%, RequestNextKbd, UseErrorLevel Off
			Hotkey, %NextKbdHotkey%, RequestNextKbd, UseErrorLevel On
			IniWrite, %NextKbdHotkey%, %InKeyINI%, InKey, NextKbdHotkey
		}
	}
	else
	{
		If NextKbdHotkey <> OldNextKbdHotkey
		{
			Hotkey, %OldNextKbdHotkey%, RequestNextKbd, UseErrorLevel Off
			IniWrite, %NextKbdHotkey%, %InKeyINI%, InKey, NextKbdHotkey
		}
	}
	if NextKbdDoubleTap<>
	{
		If NextKbdDoubleTap <> OldNextKbdDoubleTap
		{
			Hotkey, %OldNextKbdDoubleTap%, DblTapNextKbd, UseErrorLevel Off
			Hotkey, %NextKbdDoubleTap%, DblTapNextKbd, UseErrorLevel On
			IniWrite, %NextKbdDoubleTap%, %InKeyINI%, InKey, NextKbdDoubleTap
		}
	}
	else
	{
		If NextKbdDoubleTap <> OldNextKbdDoubleTap
		{
			Hotkey, %OldNextKbdDoubleTap%, DblTapNextKbd, UseErrorLevel Off
			IniWrite, %NextKbdDoubleTap%, %InKeyINI%, InKey, NextKbdDoubleTap
		}
	}
	if PrevKbdHotkey<>
	{
		If PrevKbdHotkey <> OldPrevKbdHotkey
		{
			Hotkey, %OldPrevKbdHotkey%, RequestPrevKbd, UseErrorLevel Off
			Hotkey, %PrevKbdHotkey%, RequestPrevKbd, UseErrorLevel On
			IniWrite, %PrevKbdHotkey%, %InKeyINI%, InKey, PrevKbdHotkey
		}
	}
	else
	{
		If PrevKbdHotkey <> OldPrevKbdHotkey
		{
			Hotkey, %OldPrevKbdHotkey%, RequestPrevKbd, UseErrorLevel Off
			IniWrite, %PrevKbdHotkey%, %InKeyINI%, InKey, PrevKbdHotkey
		}
	}
	if PrevKbdDoubleTap<>
	{
		If PrevKbdDoubleTap <> OldPrevKbdDoubleTap
		{
			Hotkey, %OldPrevKbdDoubleTap%, DblTapPrevKbd, UseErrorLevel Off
			Hotkey, %PrevKbdDoubleTap%, DblTapPrevKbd, UseErrorLevel On
			IniWrite, %PrevKbdDoubleTap%, %InKeyINI%, InKey, PrevKbdDoubleTap
		}
	}
	else
	{
		If PrevKbdDoubleTap <> OldPrevKbdDoubleTap
		{
			Hotkey, %OldPrevKbdDoubleTap%, DblTapPrevKbd, UseErrorLevel Off
			IniWrite, %PrevKbdDoubleTap%, %InKeyINI%, InKey, PrevKbdDoubleTap
		}
	}
	if ToggleKbdHotkey<>
	{
		If ToggleKbdHotkey <> OldToggleKbdHotkey
		{
			Hotkey, %OldToggleKbdHotkey%, RequestToggleKbd, UseErrorLevel Off
			Hotkey, %ToggleKbdHotkey%, RequestToggleKbd, UseErrorLevel On
			IniWrite, %ToggleKbdHotkey%, %InKeyINI%, InKey, ToggleKbdHotkey
		}
	}
	else
	{
		If ToggleKbdHotkey <> OldToggleKbdHotkey
		{
			Hotkey, %OldToggleKbdHotkey%, RequestToggleKbd, UseErrorLevel Off
			IniWrite, %ToggleKbdHotkey%, %InKeyINI%, InKey, ToggleKbdHotkey
		}
	}
	if ToggleKbdDoubleTap<>
	{
		If ToggleKbdDoubleTap <> OldToggleKbdDoubleTap
		{
			Hotkey, %OldToggleKbdDoubleTap%, DblTapToggleKbd, UseErrorLevel Off
			Hotkey, %ToggleKbdDoubleTap%, DblTapToggleKbd, UseErrorLevel On
			IniWrite, %ToggleKbdDoubleTap%, %InKeyINI%, InKey, ToggleKbdDoubleTap
		}
	}
	else
	{
		If ToggleKbdDoubleTap <> OldToggleKbdDoubleTap
		{
			Hotkey, %OldToggleKbdDoubleTap%, DblTapToggleKbd, UseErrorLevel Off
			IniWrite, %ToggleKbdDoubleTap%, %InKeyINI%, InKey, ToggleKbdDoubleTap
		}
	}
	if MenuHotkey<>
	{
		If MenuHotkey <> OldMenuHotkey
		{
			Hotkey, %OldMenuHotkey%, ShowKbdMenu, UseErrorLevel Off
			Hotkey, %MenuHotkey%, ShowKbdMenu, UseErrorLevel On
			IniWrite, %MenuHotkey%, %InKeyINI%, InKey, MenuHotkey
		}
	}
	else
	{
		If MenuHotkey <> OldMenuHotkey
		{
			Hotkey, %OldMenuHotkey%, ShowKbdMenu, UseErrorLevel Off
			IniWrite, %MenuHotkey%, %InKeyINI%, InKey, MenuHotkey
		}
	}

	if MenuDoubleTap<>
	{
		If MenuDoubleTap <> OldMenuDoubleTap
		{
			Hotkey, %OldMenuDoubleTap%, DblTapMenuKbd, UseErrorLevel Off
			Hotkey, %MenuDoubleTap%, DblTapMenuKbd, UseErrorLevel On
			IniWrite, %MenuDoubleTap%, %InKeyINI%, InKey, MenuDoubleTap
		}
	}
	else
	{
		If MenuDoubleTap <> OldMenuDoubleTap
		{
			Hotkey, %OldMenuDoubleTap%, DblTapMenuKbd, UseErrorLevel Off
			IniWrite, %MenuDoubleTap%, %InKeyINI%, InKey, MenuDoubleTap
		}
	}

	if ChangeSendingMode<>
	{
		If ChangeSendingMode <> OldChangeSendingMode
		{
			Hotkey, %OldChangeSendingMode%, ChangeSendingMode, UseErrorLevel Off
			Hotkey, %ChangeSendingMode%, ChangeSendingMode, UseErrorLevel On
			IniWrite, %ChangeSendingMode%, %InKeyINI%, InKey, ChangeSendingMode
		}
	}
	else
	{
		If ChangeSendingMode <> OldChangeSendingMode
		{
			Hotkey, %OldChangeSendingMode%, ChangeSendingMode, UseErrorLevel Off
			IniWrite, %ChangeSendingMode%, %InKeyINI%, InKey, ChangeSendingMode
		}
	}

	if ResyncHotkey<>
	{
		If ResyncHotkey <> OldResyncHotkey
		{
			Hotkey, %OldResyncHotkey%, DoResync, UseErrorLevel Off
			Hotkey, %ResyncHotkey%, DoResync, UseErrorLevel On
			IniWrite, %ResyncHotkey%, %InKeyINI%, InKey, ResyncHotkey
		}
	}
	else
	{
		If ResyncHotkey <> OldResyncHotkey
		{
			Hotkey, %OldResyncHotkey%, DoResync, UseErrorLevel Off
			IniWrite, %ResyncHotkey%, %InKeyINI%, InKey, ResyncHotkey
		}
	}
	if ReloadHotkey<>
	{
		If ReloadHotkey <> OldReloadHotkey
		{
			Hotkey, %OldReloadHotkey%, DoReload, UseErrorLevel Off
			Hotkey, %ReloadHotkey%, DoReload, UseErrorLevel On
			IniWrite, %ReloadHotkey%, %InKeyINI%, InKey, ReloadHotkey
		}
	}
	else
	{
		If ReloadHotkey <> OldReloadHotkey
		{
			Hotkey, %OldReloadHotkey%, DoReload, UseErrorLevel Off
			IniWrite, %ReloadHotkey%, %InKeyINI%, InKey, ReloadHotkey
		}
	}
	if GrabContextHotkey<>
	{
		If GrabContextHotkey <> OldGrabContextHotkey
		{
			Hotkey, %OldGrabContextHotkey%, GrabContext, UseErrorLevel Off
			Hotkey, %GrabContextHotkey%, GrabContext, UseErrorLevel On
			IniWrite, %GrabContextHotkey%, %InKeyINI%, InKey, GrabContextHotkey
		}
	}
	else
	{
		If GrabContextHotkey <> OldGrabContextHotkey
		{
			Hotkey, %OldGrabContextHotkey%, GrabContext, UseErrorLevel Off
			IniWrite, %GrabContextHotkey%, %InKeyINI%, InKey, GrabContextHotkey
		}
	}
	if AutoGrabContextHotkey<>
	{
		If AutoGrabContextHotkey <> OldAutoGrabContextHotkey
		{
			Hotkey, %OldAutoGrabContextHotkey%, MenuAutoGrab, UseErrorLevel Off
			Hotkey, %AutoGrabContextHotkey%, MenuAutoGrab, UseErrorLevel On
			IniWrite, %AutoGrabContextHotkey%, %InKeyINI%, InKey, AutoGrabContextHotkey
		}
	}
	else
	{
		If AutoGrabContextHotkey <> OldAutoGrabContextHotkey
		{
			Hotkey, %OldAutoGrabContextHotkey%, MenuAutoGrab, UseErrorLevel Off
			IniWrite, %AutoGrabContextHotkey%, %InKeyINI%, InKey, AutoGrabContextHotkey
		}
	}
}

OnTabChange:	; User has changed tabs.
	; OldTabNum := TabNum
	; Gui, 3:Submit, NoHide  ; 	Updates TabNum with new tab number
	; if (OldTabNum = 1)
		; SaveTab1Changes()
	; if (OldTabNum = 2)
		; SaveTab2Changes()
	; outputdebug TabNum: %OldTabNum%=>%TabNum%
	return

; OKConfigTab1:	; User pressed OK on Tab 1
	; SaveTab1Changes()
	; if (needsRestart) {
		; Reload
		; sleep 3000
	; }
	; Gui 3:Destroy
	; Gui, 1:Default
	; return

3OKButton:
	Gui, 3:Submit, NoHide  ; 	Updates TabNum with new tab number
	SaveTab1Changes()
	SaveTab2Changes()
	SaveTab3Changes()
	if (needsRestart) {
		Reload
		sleep 3000
	}
	Gui 3:Destroy
	currentconfigure=0
	Gui, 1:Default
	return

;CancelConfigTab1:
3GuiEscape:
3GuiClose:
3CancelButton:
	if (needsRestart) {
		Reload
		sleep 3000
	}
	Gui, 3:Destroy
	currentconfigure=0
	Gui, 1:Default
	return

#include InstallOrUpdateKeyboard.ahk