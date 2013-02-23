;~  maxstack := 1024  	; Constant indicating maximum number of items in stack.
;~  stackshift := 512	; Constant indicating number of items to discard from bottom of stack when maximum is reached.


ChangeSendingMode:
	currSendingMode++
	if (currSendingMode > 1) {
		currSendingMode := 0
	}
	if (currSendingMode = 0)
		modestr := "Normal"
	if (currSendingMode = 1)
		modestr := "Clipboard"

	OutputDebug ChangeSendingMode to %modestr%
	TrayTip,,Sending Mode: %modestr%
	; TODO: Save setting for this app
	return

CommitKeystroke(ByRef DelText, ByRef AddText="", uFlags=0) {
; Send  the %AddText after deleting the %DelTxt, updating both the context stack and the keystroke history stack.
	global
	_ChangeText(DelText, AddText, uFlags)

	; Add this event to the keystroke history
	DelStack.Insert(DelText)
	AddStack.Insert(AddText)
}

UndoKeystroke() {
; Pop a keystroke event of the stack, and _ChangeText to reverse it.
; if nothing on the keystroke stack, send a {BS}
	global
	CurrPhase := 0					; Phase is always cleared
	if (CurrDeadkey != 0) {		; If Deadkey was set, clearing it is all the undoing of keystroke that we need to do right now.
			CurrDeadkey := 0
			return
	}
	if (DelStack.MaxIndex() > DelStack.MinIndex()) {  ; If there is keystroke history, pop the most recent event off, and
		_ChangeText(AddStack.Remove(AddStack.MaxIndex()), DelStack.Remove(DelStack.MaxIndex()))  ; delete the stuff from the AddStack, then add the stuff from the DeleteStack
	} else {		; there is insufficient keystroke history
		_DoPureBackSp()
	}
}

_DoPureBackSp() {
; Send a backspace.  If there was context, remove from end of context as much as one {BS} will have eliminated.  This is at least the case for SMP chars. Maybe others too?  Maybe depends on whether thisAppDoesGreedyBackspace?
; Should only be called when there is no longer any keystroke history to work with.
	global
; DEBUG>>
	if (AddStack.MaxIndex() != AddStack.MinIndex())
		OutputDebug ********* %A_LineNumber% ASSERTION FAILED.  Keystroke history stack should have been emptied by now.
; <<DEBUG
	Send {BS}
	;~ if ((cc >= 0xDC00) and (cc <= 0xDFFF)) {  ; If we're about to delete the trail surrogate (range DCC0-DFFF), BS will delete the leading surrogate too. (range D800-DBFF) We just need to ensure it gets deleted from history too.
	stackIdx -=  (ctx()>>10 = 0x37) ? 2 : 1   ; that is,  if (DC00 <= ctx() <= DFFF), delete the extra code unit (range D800-DBFF)  from the context stack too
	if (stackIdx < 0 or thisAppDoesGreedyBackspace)
		stackIdx := 0
	CurrPhase := 0
	CurrDeadkey := 0
	LastRotId := 0
}

_ChangeText(ByRef DelText, byref AddText, uFlags=0) {
; All changes to the text in the app come either through here or through _DoPureBackSp (when there is no context stack to work with).
; This also updates the context stack accordingly, but does not affect the Keystroke stack.
; This is not called directly except by CommitKeystroke and UndoKeystroke, which also update the Keystroke stack.
	global
;~ TrayTip,, _ChangeText("%DelText%" "%AddText%")
	; Back up as many times as necessary to delete the DelText.
	local  unitsToBack := StrLen(DelText)
;>>
	local dbgStr := ctxStr(unitsToBack)
	if (dbgStr != DelText)
		OutputDebug %A_LineNumber% ASSERTION FAILED: DelText=%DelText%,  from stack=%dbgStr%
;<<

	if (unitsToBack>0) {

		; Back up %unitsToBack% number of UTF16 code units.
		if (thisAppDoesGreedyBackspace) {

			; Back up by cutting a chunk of text to the clipboard. This doesn't work in contexts where shift+left does not select text to the left.  e.g. Often in Excel.
			OutputDebug avoiding greedy backspace
			local stillToBack := unitsToBack
			local buf
			Clipsaved := ClipboardAll  		; Preserve clipboard state while we do this
			Loop {
				clipboard =
				Send +{Left}^x			; Send Shift+Left to select, and then Ctrl+X to cut
				ClipWait 10				; Wait for clipboard
				buf := Clipboard
				numDeleted := StrLen(buf)  ; See how many chars were deleted
				stillToBack -= numDeleted 	; See how many we still need to back up over (or need to add back, if negative)
				Outputdebug stillToBack = %stillToBack%, numDeleted = %numDeleted%
				if stillToBack <= 0
					break
			}
			stillToBack *= -1
			local qqStr := strGet(buf, 0, stillToBack)
			local dbgTest := ""
			Loop %stillToBack% 					; Add them back
			{
				local qq := numGet(buf, (A_Index-1)*2, "UShort")
				dbgTest .= Chr(qq)
				outputdebug Added back %qq%
			}
			Clipboard := Clipsaved	; Restore the original clipboard.
			Clipsaved =		; Free the memory in case the clipboard was very large.
			if (dbgTest != qqStr) {
					OutputDebug ASSERTION FAILED %A_Linenumber%: didnt match			; TODO delete after testing
			}

		} else {

			; Back up the normal way, using {BS}
			local  ctBS := unitsToBack
			loop %unitsToBack% {
				local cc  := NumGet(DelText, (A_Index - 1) * 2, "UShort")
				;~ if ((cc >= 0xDC00) and (cc <= 0xDFFF)) {  ; If we're about to delete the trail surrogate (range DCC0-DFFF), BS will delete the leading surrogate too. (range D800-DBFF) We just need to ensure it gets deleted from history too.
				if (cc>>10 = 0x37) { ; that is, DC00 <= cc <= DFFF
					OutputDebug use one less BS due to trail surrogate: %cc%
					ctBS -= 1
				}
			}
			;~ OutputDebug 			SendInput {BS %ctBS%}
			SendInput {BS %ctBS%}
		}

		; Now adjust the stack
		stackIdx -= unitsToBack
		if stackIdx < 0
			stackIdx := 0
	}

	; Now Send the text
	local numCh
	numCh := StrLen(AddText)
	if (numCh) {
		SendTextToApp(AddText)  ; Typically equivalent to:   SendRaw %data%

		Loop %numCh% {  ; Now add to the context stack
			push(NumGet(AddText, (A_Index-1)*2, "UShort"), uFlags)
		}
	}
	CurrPhase := 0
	CurrDeadkey := 0
	CurrBS := 0
	LastRotId := 0
	return 3 ; OK
}

;~ ; BackCt is count of utf16 code units.
;~ CommitKeystrokeOld(BackCt, ByRef AddText="", uFlags=0) {  ; ToDo:  Maintain a  keystroke stack by which keystrokes can be undone
	;~ global

	;~ ; First back up the specified number of characters
	;~ if (BackCt>0) {
		;~ local di := SendBkSpc(BackCt)  ; di returned is the number of UTF-16 code units by which to change the stack index  (May be 2 for an SMP char)

		;~ if (di > stackIdx)
			;~ di := stackIdx	; prevent overflow

		;~ stackIdx -= di
		;~ if stackIdx < 0
			;~ stackIdx := 0
	;~ }

	;~ ; Now Send the text
	;~ local numCh
	;~ numCh := StrLen(AddText)
	;~ if (numCh) {
		;~ SendTextToApp(AddText)  ; Typically equivalent to:   SendRaw %data%

		;~ Loop %numCh% {  ; Now add to the context stack
			;~ push(NumGet(AddText, (A_Index-1)*2, "UShort"), uFlags)
		;~ }
	;~ }
	;~ CurrPhase := 0
	;~ CurrDeadkey := 0
	;~ return 3 ; OK
;~ }

; Send UTF-16 text string to the active application
SendTextToApp(s) {
	global currSendingMode
	global	CurrPhase := 0   ; TEMPORARY, until this function is only called by CommitKeystroke
	global	CurrDeadkey := 0   ; TEMPORARY, until this function is only called by CommitKeystroke

	if (currSendingMode = 0) {
		SendRaw %s%
	} else {  ; if mode is clipboard
		Critical
		ClipSavedL := ClipboardAll   ; Save the entire clipboard to a temporary variable
		Clipboard =
		Clipboard := s
		Sleep, 200 ; helps to prevent PASTE from pasting in the original clipboard. not 100% foolproof though unless made very long
		ClipWait, 1
		Send +{INS}
		; BUG: occasionally this shift key gets applied to keys being typed, esp for holding key down.
		Sleep, 50 ; see http://www.autohotkey.com/forum/viewtopic.php?p=159301#159306
		Clipboard := ClipSavedL   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
		ClipSavedL =   ; Free the memory in case the clipboard was very large.
		Critical, Off
	}
}

; Send a character (up to character 0xFFFF only)
SendChar16(c) {
	SendTextToApp(Chr(c))
}


Send_WM_COPYDATA(Kbd, cmdID, ByRef StringToSend)  ; ByRef saves a little memory in this case.
; This function sends the specified number and string to the window of the specified keyboard, and returns the reply.
; struct COPYDATASTRUCT    - size: A_PtrSize*2+4
	;             UPtr   dwData  (4 or 8 bytes)  Offset: 0.           Value to be passed.
	;             UInt   cbData  (4 bytes)       Offset: A_PtrSize.   The size, in bytes, of the data pointed to by the lpData member.
	;             UPtr   lpData  (4 or 8 bytes)  Offset: A_PtrSize+4. Ptr to data to be passed.
{
	VarSetCapacity(CopyDataStruct, A_PtrSize*2+4, 0)  ; Set up the structure's memory area.
	NumPut(cmdID, CopyDataStruct, 0, "UPtr")  ;
	DataSize := (StrLen(StringToSend) + 1) * 2		; First set the structure's cbData member to the size of the string, including its zero terminator:
	NumPut(DataSize, CopyDataStruct, A_PtrSize, "UInt")
	NumPut(&StringToSend, CopyDataStruct, A_PtrSize+4, "UPtr")  ; Set lpData to point to the string itself.
	r := DllCall("SendMessage", UInt, GetKbdHwnd(Kbd), UInt, 0x4A, UInt, 0, UInt, &CopyDataStruct)
	if (ErrorLevel) {
		SoundPlay *16
		outputdebug ************ CRITICAL ERROR: Send_WM_COPYDATA(%Kbd%, %cmdID%, %StringToSend%) failed!
	}
	return r
}


setupCallbacks() {
	OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA.  It won't work to use a different message number.
	OnMessage(0x8010, "OnSendChar")
	OnMessage(0x8011, "OnCtx")
	OnMessage(0x8012, "OnFlags")
	OnMessage(0x8013, "OnBack")
	;~ OnMessage(0x8014, "OnDeleteChar")
	OnMessage(0x8015, "OnUndoLast")
	OnMessage(0x8019, "OnBackspace")
	OnMessage(0x8016, "OnEnter")
	OnMessage(0x8017, "OnTab")
	OnMessage(0x8018, "OnSpace")
	OnMessage(0x8020, "OnKbdInit")
	OnMessage(0x8021, "OnSetPhase")
	OnMessage(0x8022, "OnIfPhase")
	OnMessage(0x8023, "OnGetDeadkey")
	OnMessage(0x8031, "OnSetDeadkey")
	OnMessage(0x8032, "OnIfDeadkey")
	OnMessage(0x8033, "OnGetDeadkey")
	OnMessage(0x10, "On_WM_CLOSE")
}

OnSetPhase(nPhaseNum) {
	global
	CurrPhase := nPhaseNum
}

OnIfPhase(nPhaseNum) {
	global
	return  (CurrPhase=nPhaseNum) ? 1 : 0
}

OnGetPhase() {
	global
	return CurrPhase
}

OnSetDeadkey(nDeadkeyNum) {
	global
	CurrDeadkey := nDeadkeyNum
}

OnIfDeadkey(nDeadkeyNum) {
	global
	return  (CurrDeadkey=nDeadkeyNum) ? 1 : 0
}

OnGetDeadkey() {
	global
	return CurrDeadkey
}

OnKbdInit(ProtocolID, KbdID, msg, hwnd) {
	;~ global
	; TODO: Check that Protocol ID is at least whatever we need it to be.
	;~ Outputdebug Got test message (%msg%) from kbd #%kbdid%, file #%fileid% sent to hwnd %hwnd%
	;~ DllCall("QueryPerformanceCounter", "Int64 *", CounterAfter)
	;~ DllCall("QueryPerformanceFrequency", "Int64 *", f)
	;~ x := (CounterAfter - CounterBefore) * 1000 / f
	;~ outputdebug % "Kbd #" . kbdID . " took " . x . " ms to launch"
	; % (necessary for Notepad++ AHK filter to correctly colorcode the code!)
	return GetKbdHwnd(kbdid)
}

On_WM_CLOSE() {
	ExitApp
}

	; Call at any time to erase the entire context.
initContext()
{
	global
	CurrPhase := 0
	CurrDeadkey := 0
	CurrBS := 0
	LastRotId := 0
	DelStack := []
	AddStack := []
	ctxStack =
	;~ LastRotBack =

	stackIdx = 0
	varSetCapacity(ctxStack, 2048, 0)		; 2048 = maxstack * 2
	varSetCapacity(flagStack, 4096, 0)		; 4096 = maxstack * 4
		;setformat integerfast, d
}

/*
Receive_WM_COPYDATA(wParam, lParam)
{
	StringAddress := NumGet(lParam + 8)  ; lParam+8 is the address of CopyDataStruct's lpData member.
	CopyOfData := StrGet(StringAddress)  ; Copy the string out of the structure.
	; Show it with ToolTip vs. MsgBox so we can return in a timely fashion:
	ToolTip %A_ScriptName%`nReceived the following string:`n%CopyOfData%`nct=%wParam%
	return true  ; Returning 1 (true) is the traditional way to acknowledge this message.
}
*/

Receive_WM_COPYDATA(wParam, lParam)
{	; This function can receive string data from a keyboard.
	; Any processing done in response must return quickly. If necessary, set a timer to kick off a longer process.
	global rotaPeriod
	dwSize := NumGet(lParam+0, A_PtrSize, "UInt")  ;  address of CopyDataStruct's cbData member.
	StringAddress := NumGet(lParam + A_PtrSize+4, "UPtr")  ; address of CopyDataStruct's lpData member.
	if (dwSize = 0)
		StringData := ""
	else
	{
		VarSetCapacity(StringData, dwSize, 0)
		DllCall("MSVCRT\memcpy", "str", StringData, "UPtr", StringAddress, "uint", dwSize)  ; Copy the string out of the structure.

		;~ StringData := StrGet(NumGet(lParam+0, A_PtrSize*2))  ; Copy the string out of the structure.  ; lParam+8 is the address of CopyDataStruct's lpData member. ; Assumed null-terminated.

		;~ SetFormat IntegerFast, H
		dwNum := NumGet(lParam+0, 0, "UPtr")  ; specifying MyVar+0 forces the number in MyVar to be used instead of the address of MyVar itself
		;~ dwNum += 0
		;~ SetFormat IntegerFast, d

		; ToolTip %A_ScriptName%`nReceived the following string:`n%StringData%`ndwNum=%dwNum%`ndwSize=%dwSize%'`wParam=%wParam%	; //DEBUG
		;~ OutputDebug %A_ScriptName%`nReceived the following string:`n%StringData%`nwParam=%wParam%`ndwNum=%dwNum%`ndwSize=%dwSize%

		;~ outputdebug %A_ScriptName% received string message: %StringData%

		; Handle string passed as a TrayTipQ command (0x9001)
		if (dwNum = 0x9001 and RegExMatch(StringData,"^(?P<text>.*)\|(?P<title>.*)\|(?P<ms>.+)", ov_)) {
			outputdebug received tip message: %ov_text%, %ov_title%, %ov_ms%
			TrayTipQ(ov_text, ov_title, ov_ms)
;~ 		SetFormat IntegerFast, D
			return 3
		}

		;~ ; Handle string passed as a ReplaceChar command (0x9002)
		;~ if (dwNum = 0x9002 and RegExMatch(StringData,"^(?P<ch>.*),(?P<nc>.*),(?P<ep>.+),(?P<fl>.+)", ov_)) {
			;~ outputdebug received ReplaceChar message: %ov_ch%, %ov_nc%, %ov_ep%, %ov_fl%
			;~ ReplaceChar(ov_ch, ov_nc, ov_ep, ov_fl)
			SetFormat IntegerFast, D
			;~ return 3
		;~ }

		; Handle string passed as a InCase command (0x9020)
		if (dwNum = 0x9020) {
			if (RegExMatch(StringData,"^(?:A:(?P<A>[^\x{1e}]*)\x{1e})?(?:S:(?P<S>[^\x{1e}]*)\x{1e})?(?:Sf:(?P<Sf>[^\x{1e}]*)\x{1e})?(?:R:(?P<R>[^\x{1e}]*)\x{1e})?(?:W:(?P<W>[^\x{1e}]*)\x{1e})?(?:Wf:(?P<Wf>[^\x{1e}]*)\x{1e})?(?:U:(?P<U>[^\x{1e}]*)\x{1e})?(?:E:(?P<E>[^\x{1e}]*)\x{1e})?(?:Ef:(?P<Ef>[^\x{1e}]*)\x{1e})?", ov_)) {
				;~ OutputDebug received TryThis: A=>"%ov_A%" S=>"%ov_S%" Sf=>"%ov_Sf%" R=>"%ov_R%" W=>"%ov_W%" Wf=>"%ov_Wf%" E=>"%ov_E%" Ef=>"%ov_Ef%"
				if (ov_A and ov_S)
					return InContextSend(ov_A, ov_S, ov_E, ov_Sf ? ov_Sf : 0, ov_Ef ? ov_Ef : 0)
				if (ov_R and ov_W and ov_U)
					return InContextReplaceUsingMap(ov_A, ov_R, ov_W, ov_U, ov_E, ov_Wf ? ov_Wf : 0, ov_Ef ? ov_Ef : 0)
				if (ov_R and ov_W)
					return InContextReplace(ov_A, ov_R, ov_W, ov_E, ov_Wf ? ov_Wf : 0, ov_Ef ? ov_Ef : 0)
			}
			TrayTip, Syntax error in InCase() command:,%StringData%
			return 2
		}

		; Handle string passed as a InsertChar command (0x9003)
		if (dwNum = 0x9003 and RegExMatch(StringData,"^(?P<ch>.*),(?P<fl>.+)", ov_)) {
			outputdebug received InsertChar message: %ov_ch%, %ov_fl%
			InsertChar(ov_ch, ov_fl)
			;~ SetFormat IntegerFast, D
			return 3
		}

		;~ ; Handle string passed as a InContextSend command (0x9015)
		;~ if (dwNum = 0x9015 and RegExMatch(StringData,"^(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)", grp)) {
			;~ outputdebug received InContextSend message: %grp1%, %grp2%, %grp3%, %grp4%, %grp5%
			;~ return InContextSend(grp1, grp2, grp3, grp4, grp5)
		;~ }

		;~ ; Handle string passed as a InContextReplace command (0x9016)
		;~ if (dwNum = 0x9016 and RegExMatch(StringData,"^(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)", grp)) {
			;~ outputdebug received InContextSend message: %grp1%, %grp2%, %grp3%, %grp4%, %grp5%, %grp6%
			;~ return InContextReplace(grp1, grp2, grp3, grp4, grp5, grp6)
		;~ }

		; Handle string passed as a RegisterRota command (0x9004)
		if (dwNum = 0x9004 and RegExMatch(StringData,"^(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)\x{1e}(.*)", grp)) {
			RegisterRota(grp1, grp2, grp3, grp4, grp5)  ; id, rotaSets, defTxt, style, uFlags
			return 3
		}

		; Handle string passed to register rota by InRota command (0x9024)
		if (dwNum = 0x9024 and RegExMatch(StringData,"^(?P<ID>\w+)\x{1e}M:(?P<RS>[^\x{1e}]+)\x{1e}(?:E:(?P<E>[^\x{1e}]*)\x{1e})?(?:Ef:(?P<Ef>[^\x{1e}]*)\x{1e})?", ov_)) {
			RegisterMap(ov_ID, ov_RS, ov_E, 0, ov_Ef ? ov_Ef : 0)  ; id, rotaSets, defTxt, style, uFlags
			;~ OutputDebug *********** ov̠E = [%ov_E%]
			return 3  ; TODO: check that if there is no E: this time but there was last time, is E set to empty??
		}

		; Handle string passed as a DoRota command (0x9005)
		if (dwNum = 0x9005) {
			;~ outputdebug ata message: %StringData%
			return DoRota(StringData)
		}


		; Handle string passed as a FatalError command (0x9006)
		if (dwNum = 0x9006) {
			global KbdHKL0
			ChangeLanguage(KbdHKL0)
			RequestKbd(0)
			MsgBox %StringData%
			return 3
		}

		; Handle string passed as a ToolTipU command (0x9007)
		if (dwNum = 0x9007 and RegExMatch(StringData,"^(?P<text>.*)\|(?P<ms>.+)", ov_)) {
			outputdebug received tip message: %ov_text%, %ov_ms%
			UTip(ov_text, ov_ms ? ov_ms : rotaPeriod)
			return 3
		}

		; Handle string passed as a PreviewChar command (0x9008)
		if (dwNum = 0x9008 and RegExMatch(StringData,"^(?P<cc>.*)\|(?P<ms>.+)", ov_)) {
			outputdebug received PreviewChar message: %ov_cc%, %ov_ms%
			global prevbuf
			varsetcapacity(prevbuf, 4, 0)
			numput(ov_cc, prevbuf, 0, "UShort")
			UTip(prevbuf, ov_ms ? ov_ms : rotaPeriod)
			return 3
		}

		; Handle string passed as a SendRotaChar command (0x9009)
		if (dwNum = 0x9009 and RegExMatch(StringData,"^(?P<id>.+?)\|(?P<def>.+?)\|(?P<flg>.+)", ov_)) {
			outputdebug received SendRotaChar message: %ov_id%, %ov_def%, %ov_flg% [%StringData%]
			SendRotaChar(ov_id, ov_def, ov_flg)
			return 3
		}

		; Handle string passed as a SendChars command (0x900A)
		if (dwNum = 0x900A) {
			outputdebug received SendChars message
			TrayTip,,This keyboard uses the SendChars() function. It should be updated to use Send() instead.
			return SendChars(StringData)
		}

		; Handle string passed as a Send command (0x901A)
		if (dwNum = 0x901A) {
			outputdebug %A_LineNumber%: Send("%StringData%")
			return CommitKeystroke("", StringData, wParam)
		}

		;~ ; Handle string passed as a InsertChars command (0x900B)
		;~ if (dwNum = 0x900B) {
			;~ outputdebug received InsertChars message
			;~ return InsertChars(StringData)
		;~ }


	}
	setformat integerfast, H
	dwNum += 0
	Outputdebug ** ERROR: %A_ScriptName% has no handler for received string: %dwNum%, "%StringData%"
	setformat integerfast, d
	return 2  ; Tell sender that we didn't process this string
}

SendChars(ByRef data) {
	local uFlags
	local numCh
	uFlags := NumGet(data, 0, "UInt")
	numCh := NumGet(data, 4, "UShort")
	;outputdebug SendChars: uFlags=%uFlags%, numCh=%numCh%
	if (numCh > 32)
		return 2  ; guard against bad parameters
	Loop % numCh
		SendChar(NumGet(data, A_Index * 2 + 4, "UShort"), uFlags)
	return 3 ; OK
}


;~ InsertChars(ByRef data) {
	;~ local ii
	;~ uFlags := NumGet(data, 0, "UInt")
	;~ pos := NumGet(data, 4, "UShort")
	;~ numCh := NumGet(data, 6, "UShort")
	;~ OutputDebug insertchars: %uFlags%, %pos%, %numCh%
	;~ if (numCh > 32 or pos > 32)
		;~ return 2 ; guard against bad parameters
	;~ Loop % pos	; Remember these characters
	;~ {
		;~ ctx%A_Index% := ctx(A_Index)
		;~ flg%A_Index% := flags(A_Index)
	;~ }
	;~ local delTxt := ctxStr(pos)
	;~ local addTxt := ""
	;~ Loop % numCh
		;~ addTxt .= Chr(NumGet(data, A_Index * 2 + 6, "UShort"))
	;~ ii := pos
	;~ Loop % pos
	;~ {
		;~ addTxt .= Chr(ctx%ii%)
		;~ ii--
	;~ }
	;~ CommitKeystroke(delTxt, addTxt, uFlags)
	;~ return 3 ; OK
;~ }

SendRotaChar(id, u, uFlags) {
	SendChar(u, uFlags)
	if (rotStyle%id% & 16)
		DoPreviewRota(id)
}

; ________________________________________________________________________________

RegisterRota(ByRef id, ByRef rotaSets, ByRef defTxt, style, flags) {   ; (id, def, flags, back, style, list) {
; A rota separates segments with space, marks a set as non-looping by using a tab, and separates strings with newline (or tab).
; defTxt is always a separate parameter.   Expiring rota is indicated by (flag & 8)
	global
;~ dumpStr(rotaSets, "RegisterRota begin:")
	rotDef%id% := defTxt
	rotFlags%id% := flags
	;~ rotBack%id% := back
	rotStyle%id% := style
	RotSetStart%id% = 0
	;~ outputdebug RegisterRota(%id%, %defTxt%, %style%, %flags%
	;~ ToolTip RegisterRota(%id%; %defTxt%; %flags%; %back%; %style%; %rotaSets%)
	rotaSets .= Chr(10)
	if (style & 1)  ; Single-line list.  Sets were delimited with tabs.
		StringReplace rotaSets, rotaSets, %A_Tab%, `n, All
	;VarSetCapacity(rotList%id%, StrLen(rotaSets), 0)
	rotCt%id% := StrLen(rotaSets) + 1
	rotList%id% := RegExReplace(RegExReplace(RegExReplace(rotaSets, " ", chr(0x11)), "\t", chr(0x12)), "\n", chr(0x13))  ; Replace space with x11, tab with x12, newline with x13.
;	outputdebug % "rotCt = " . rotCt%id%
;~ dumpStr(rotList%id%, "RegisterRota final:")
	VarSetCapacity(rotListR%id%, rotCt%id% * 2, 0)
	local stak =
	local outIdx = 0
	Loop  % rotCt%id%
	{  ; This loop reverses the internal character order of strings longer than a single character.
		local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		if (v >=0x11 and v <= 0x13) {
			Loop, parse, stak, `,
				; When we reach the blank item at the end of the list, store the space or tab.
				NumPut(A_LoopField ? A_LoopField : v, rotListR%id%, 2 * outIdx++, "UShort")
			stak =
		} else
			stak := v . "," . stak
	}
	if (style & 2) {
		; This is an implicitly non-looping rota.  Replace the last x11 in each set with x12 so that
		; when DoRota is scanning through, it won't match the last item in the set.
		outIdx := rotCt%id% - 2
		local foundNL = 1
		Loop
		{	if (outIdx <= 0)
				break
			v := NumGet(rotListR%id%, outIdx * 2, "UShort")
			if (v = 0x11 and foundNL = 1) {
				NumPut(0x12, rotListR%id%, outIdx * 2, "UShort")
				foundNL = 0
			} else if (v = 0x13)
				foundNL = 1
			else if (v = 0x12)
				foundNL = 0
			outIdx--
		}
	}
;~ ; DEBUG>>
	;~ dbg := ""
	;~ SetFormat integerfast, H
	;~ Loop  % rotCt%id%
	;~ {  ; This loop reverses the internal character order of strings longer than a single character.
		;~ local v := NumGet(rotListR%id%, (A_Index - 1) * 2, "UShort")
		;~ if (v >=32 and v <= 255)
			;~ dbg .= chr(v)
		;~ else
			;~ dbg .= "<" v ">"
	;~ }
	;~ OutputDebug RegisterRota reversed: [%dbg%]
	;~ SetFormat integerfast, d
;~ ;<<DEBUG
}

; ________________________________________________________________________________
interpolate(ByRef str) {
	;local cc, dd
	setformat integerfast, H
	Loop {
		if (RegExMatch(str, "O)\\x\{([0-9a-fA-F]+)\}", match)) {
			str := SubStr(str, 1, match.Pos[0] - 1) chr("0x" match.Value[1]) substr(str, match.Pos[0] + match.Len[0])
		} else
			break
	}
	setformat integerfast, D
	return str
}


RegisterMap(ByRef id, ByRef rotaSets, ByRef defTxt, style, flags) {   ; (id, def, flags, back, style, list) {
; A map separates segments with "→" or "⇛", marks a string as looping with "↺"
	global
	rotDef%id% := defTxt
	rotFlags%id% := flags ? flags : 0
	rotStyle%id% := style
	RotSetStart%id% = 0
	;~ rotaSets .= chr(19)
;~ dumpStr(rotaSets, "RegisterMap begin:")
	if (InStr(rotaSets, "⇛")) 		; If any multi-tap arrows were used, set style to expiring.
			rotStyle%id% := rotStyle%id% | 8

	rotaSets := RegExReplace(rotaSets, "→|⇛", chr(0x11))   ; Replace arrows with x11
	rotaSets := RegExReplace(rotaSets, "↺", chr(0x14))   ; Replace loop arrow with x14
	interpolate(rotaSets)							; Now convert \x{} expressions into actual characters, which might theoretically include our literal arrow characters.

	local match
	if (RegExMatch(rotaSets, "O)^\x{11}([^\x{11}-\x{14}]+)", match))  {   ; Initial arrow means set default text to first segment.
			rotaSets := SubStr(rotaSets, 2)
			if (strlen(defTxt) = 0)
				rotDef%id% := match.Value[1]
	}

	rotaSets := RegExReplace(rotaSets, "\x{11}(?=[^\x{11}-\x{14}]*\x{13})", chr(0x12))   ; Any time x11 is the last control character before x13 (no intervening loop arrow x14), replace it with x12
	rotaSets := RegExReplace(rotaSets, chr(0x14),  "")      ; now we can nuke all x14

	rotList%id% := rotaSets
;~ dumpStr(rotaSets, "RegisterMap final:")
	rotCt%id% := StrLen(rotList%id%) + 1
;	outputdebug % "rotCt = " . rotCt%id%
	VarSetCapacity(rotListR%id%, rotCt%id% * 2, 0)
	local stak =
	local outIdx = 0
	Loop  % rotCt%id%
	{  ; This loop reverses the internal character order of strings longer than a single character.
		local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		if (v >=0x11 and v <= 0x13) {
			Loop, parse, stak, `,
				; When we reach the blank item at the end of the list, store the space or tab.
				NumPut(A_LoopField ? A_LoopField : v, rotListR%id%, 2 * outIdx++, "UShort")
			stak =
		} else
			stak := v . "," . stak
	}

;~ ; DEBUG>>
	;~ dbg := ""
	;~ SetFormat integerfast, H
	;~ Loop  % rotCt%id%
	;~ {  ; This loop reverses the internal character order of strings longer than a single character.
		;~ local v := NumGet(rotListR%id%, (A_Index - 1) * 2, "UShort")
		;~ if (v >=32 and v <= 255)
			;~ dbg .= chr(v)
		;~ else
			;~ dbg .= "<" v ">"
	;~ }
	;~ OutputDebug RegisterMap reversed: [%dbg%]
	;~ SetFormat integerfast, d
;~ ;<<DEBUG
}

; ________________________________________________________________________________
DoRota(id) {
; In the rotList and rotListR arrays, chr(17) separates segments, chr(18) separates the last segment of a non-looping rota, and chr(19) separates mapping strings.
	global
	static rotTime = 0
	Gui 2:Hide
	SetFormat integerfast, d

	if (rotStyle%id% & 8) {
		local priorRT := rotTime
		rotTime := A_TickCount
		if ((rotTime - priorRT > rotaPeriod) or (flags() <> rotFlags%id%)) {
		;~ if (rotTime - priorRT > rotaPeriod) {
			;showflags()
			local ms := rotTime - priorRT
			outputdebug % "rota expired or not match flags: " . priorRT . "|" . rotTime . " [" . ms . "] " . rotaPeriod . ", " . flags() . ", " . rotFlags%id%
			if (rotDef%id%)
				CommitKeystroke("", rotDef%id%, rotFlags%id%)
			if (rotStyle%id% & 16)
				DoPreviewRota(id)
			return 3
		}
	}

	local newString := 1
	local matchedCols := 0
	if (id <> LastRotID)
		RotSetStart%id% := 0
	local endPoint
	endPoint := RotSetStart%id%
	local idx := RotSetStart%id%
	local ct := rotCt%id%
	;~ outputdebug DoRota(%id%) with idx=%idx% and ct=%ct%
	if (idx > ct)
		outputdebug *** ERROR: DoRota(%id%) with idx=%idx% > ct=%ct%
	;~ outputdebug DoRota(%id%), ct=%ct%, ep=%endpoint%, idx=%idx%
	if (not rotCt%id%)
		return 4	;  No such rota.  Keyboard programmer error.
	local firstTime = 1
	Loop {
		;~ outputdebug Loop[%idx%]
		if (firstTime)
			firstTime =
		else if (idx = endPoint) {  ; We've come all the way back around
						outputdebug DoRota [%id%] list not matched
						;~ ; DEBUG>>
							;~ dbg := ""
							;~ SetFormat integerfast, H
							;~ Loop  % rotCt%id%
							;~ {  ; This loop reverses the internal character order of strings longer than a single character.
								;~ local v := NumGet(rotListR%id%, (A_Index - 1) * 2, "UShort")
								;~ if (v >=32 and v <= 255)
									;~ dbg .= chr(v)
								;~ else
									;~ dbg .= "<" v ">"
							;~ }
							;~ OutputDebug rotListR: [%dbg%]
							;~ SetFormat integerfast, d
							;~ showstack()
						;~ ;<<DEBUG


			if (strlen(rotDef%id%) > 0)
				CommitKeystroke("", rotDef%id%, rotFlags%id%)
			if (rotStyle%id% & 16)
				DoPreviewRota(id)
			return  (strlen(rotDef%id%) > 0) ? 2 : 3  		; 2=something sent..  3=nothing sent.
		}
		local val := numGet(rotListR%id%, idx * 2, "UShort")
		;~ outputdebug val = %val%, rotCt%id%[%idx%]
		if (val >=17 and val <= 19) {
			if (matchedCols)
				break
			if (val <> 18)
				newString := 1
			idx++
			if (idx = rotCt%id%)
				idx = 0
			if (val = 19)
				RotSetStart%id% := idx
			;~ outputdebug eos: val=%val%, newstring=%newstring%,  next idx=%idx%
			continue
		}
		if (matchedCols = 0 and newString = 0) {
			idx++
			if (idx = rotCt%id%)
				idx = 0
			 ;~ outputdebug skipping. next idx=%idx%
			continue
		}
		newString := 0

		local toMatch := ctx(matchedCols + 1)
		matchedCols := (val = toMatch) ? matchedCols + 1 : 0
		idx++
		if (idx = rotCt%id%)
			idx = 0
		 ;~ outputdebug val=%val%, matchedcols=%matchedcols%, next idx=%idx%
	}
; Found Match
	 ;~ outputdebug last Character to replace by rotation: %toMatch%
	 ;~ outputdebug idx=%idx%, matchedcols=%matchedCols%,

	if (val = 17 or val = 18)
		idx++
	else
		idx := RotSetStart%id%

	local startIdx := idx
	Loop
	{	val := numGet(rotList%id%, idx * 2, "UShort")  ; Get it from the non-reversed list
		;~ outputdebug val = %val%
		if (val >=17 and val <= 19)
			break
		;~ OutputDebug % "Rota SendChar: " . chr(val)
		;~ SendChar(val, rotFlags%id%)
		LastRotChar := val  ;  is  this from a single-character-in-the-rota mindset?
		idx++
	}
	;~ OutputDebug matchedCols = %matchedCols%
	CommitKeystroke(ctxStr(matchedCols), StrGet(&rotList%id% + StartIdx * 2 , idx-StartIdx), rotFlags%id%)

	;~ LastRotBack := rotBack%id%
	LastRotId := id
	if (rotStyle%id% & 16)
		DoPreviewRota(id)
	return 2  ; sucessfully handled
}

; ________________________________________________________________________________

InContextSend(ByRef FindRegEx, ByRef SendTxt, ByRef ElseTxt="", uSendFlags=0, uElseFlags=0) {
	global
	if (RegExMatch(StrGet(&ctxStack, stackIdx), FindRegEx . "$")) {
		CommitKeystroke("", SendTxt, uSendFlags)
		return 2 ; match found
	}
	if (ErrorLevel) {
		TrayTip, InContextSend: "%find%" "%newText%", RegExMatch ERROR: %ErrorLevel%
		return 4 ; regex error
	}
	if (ElseTxt != "") {
		CommitKeystroke("", ElseTxt, uElseFlags)
		return 2
	}
	return 3  ; no match
}

InContextReplace(ByRef AfterRegEx, ByRef FindRegEx, ByRef ReplaceTxt, ByRef ElseTxt="", uSendFlags=0, uElseFlags=0) {
	global
	local context, c2, match, foundPos, repCt, delTxt, addTxt
	context := StrGet(&ctxStack, stackIdx)
	;~ foundPos := RegExMatch(context, "(" . AfterRegEx . ")" . FindRegEx . "$", match) + StrLen(match1)
	foundPos := RegExMatch(context, "O)(" . AfterRegEx . ")" . FindRegEx . "$", match)
	LBLen := match.Len(1)
	if (ErrorLevel) {
		TrayTip, InLBContextReplace: "%FindRegEx%" "%ReplaceTxt%", RegExMatch ERROR: %ErrorLevel%
		return 4 ; regex error
	}
	OutputDebug %A_Linenumber%: foundPos = %foundPos%, match = %match%, LBLen = %LBLen%
	foundPos += LBLen

	if (foundPos) {
		c2 := RegExReplace(context, FindRegEx . "$", ReplaceTxt, repCt, 1)
		if (ErrorLevel) {
			TrayTip, InContextSend: "%FindRegEx%" "%ReplaceTxt%", RegExReplace ERROR: %ErrorLevel%
			return 4 ; regex error
		}
		if (repCt) {
			delTxt := SubStr(context, foundPos)
			addTxt := SubStr(c2, foundPos)
			;~ delCt := stackIdx - foundPos + 1
			CommitKeystroke(delTxt, addTxt, uSendFlags)
			;~ TrayTip,, Replace [%delTxt%] (len=%delCt%) with [%addTxt%].
			return 2 ; match found
		}
	}
	if (ElseTxt != "") {
		CommitKeystroke("", ElseTxt, uElseFlags)
		return 2
	}
	;~ TrayTip, Not Matched:[%FindRegEx%], %context%
	return 3  ; no match
}


InContextReplaceUsingMap(ByRef AfterRegEx, ByRef FindRegEx, ByRef ReplaceTxt, ByRef Map, ByRef ElseTxt="", uSendFlags=0, uElseFlags=0) {
	global
	local context, c2, match, foundPos, repCt, delTxt, addTxt, alts, altFind
	alts := "(?P<MAP>"
	;~ mapTo := Object()		; Sadly, associative array indexes are compared case-insensitively.  We can use associative arrays once AHK fixes this.
	;~ if (InStr(Map, "⇛")) 		; ToDo:  If any multi-tap arrows were used, treat them as such.
;~ dumpstr(Map, "usingMap begin:")
	Map := RegExReplace(Map, "→|⇛", chr(0x11))   ; Replace arrows with x11
	Map := RegExReplace(Map, "↺", chr(0x12))   ; Replace looping arrow with x12 before we interpolate
	interpolate(Map)
;~ dumpstr(Map, "usingMap final:")
	mapTo := chr(0x11) RegExReplace(Map, "([^\x{11}-\x{13}]+)((?:\x{11}[^\x{11}-\x{13}]+)+)\x{12}", "$1$2" chr(0x11) "$1")   ; Replace looping arrow with a mapping to the first sequence in the string, saving this as the MapTo table.
	alts := RegExReplace(Map, "([^\x{11}-\x{13}]+|\x{12})(?=\x{13})", "")   ; nuke x12 or last segment if no x12; this string now contains only the map-FROM elements
	alts := RegExReplace(alts, "[\\\$.*+\{\}\[\]\(\)\|\^]", "\$0")  ; quote meta chars
	alts := "(?P<MAP>" SubStr(RegExReplace(alts, "[\x{11}-\x{13}]+", "|"), 1, -1) ")"   ; join with | alternation operator
	;~ local delim := chr(0x13)
	;~ Loop, Parse, Map, %delim%		; This loop builts %alts%
	;~ {
		;~ newAlts := RegExReplace(A_LoopField, chr(0x12), "")			; drop the final (target only) item
		;~ newAlts := RegExReplace(newAlts, "\s+", "|") 	;
		;~ alts .= newAlts "|"
		;~ mapTo .= chr(0x11) newMap chr(0x13)
	;~ }
;~ dumpstr(Mapto, "usingMap MapTo:")


	; Replace $F in the FindRegEx with a pattern of all mapped-FROM strings.  e.g.  (?P<MAP>a|e|i|o\u)
	altFind := RegExReplace(FindRegex, "\$F", alts)
	;~ OutputDebug "RegExReplace(" FindRegex ", '\$F', SubStr(alts, 1, -1) . ')') =>" altFind
	;~ OutputDebug %A_LineNumber%: RegExReplace("%FindRegex%", "\$F", "%alts%") => %altFind%
	if (not altFind) {
		TrayTip, Error in Replace usingMap, Missing $F in FindRegEx
		return 3
	}

	context := StrGet(&ctxStack, stackIdx)
	;~ OutputDebug context = %context%
	;~ foundPos := RegExMatch(context, "(" . AfterRegEx . ")" . FindRegEx . "$", match) + StrLen(match1)
	local needle := "O)(" AfterRegEx  ")" altFind "$"
	foundPos := RegExMatch(context, needle, match)
	;~ OutputDebug %A_LineNumber%: Regexmatch("%context%", "%needle%", match) => %foundPos%
	LBLen := match.Len(1)
	if (ErrorLevel) {
		TrayTip, Error in Replace usingMap, match stage 3: "%altFind%"
		return 4 ; regex error
	}
	altFound := "\Q" match.MAP "\E"
	;~ OutputDebug altfound = %altfound%
	needle := "[\x{11}\x{13}]" altFound "\x{11}([^\n\x{11}-\x{13}]+)"
	fp := RegExMatch(mapTo, needle, grp)
	;~ OutputDebug %A_LineNumber%: RegExMatch(mapTo, "%needle%", grp)  => %fp%, grp1 = %grp1%
	altRepCh := grp1
	;~ altRepCh := mapTo[altFound]
	;~ OutputDebug %A_Linenumber%: foundPos = %foundPos%, LBLen = %LBLen%, altFound=%altFound%, altRepCh=%altRepCh%, fp=%fp%
	foundPos += LBLen

	if (foundPos) {
		;~ altFind := RegExReplace(FindRegex, "\$F", "\Q" altFound "\E")   ; TODO: add \q \e back in here and above
		altFind := RegExReplace(FindRegex, "\$F", altFound )
		altRep := RegExReplace(ReplaceTxt, "\$R", altRepCh)
		;~ OutputDebug Final: altFind="%altFind%", altRep="%altRep%"
		if (not altRep) {
			TrayTip, Error in Replace usingMap, Missing $R in FindRegEx
			return 3
		}
		c2 := RegExReplace(context, altFind . "$", altRep, repCt, 1)
		if (ErrorLevel) {
			TrayTip, Error in Replace usingMap: "%altFind%" "%altRep%", RegExReplace ERROR: %ErrorLevel%
			return 4 ; regex error
		}
		if (repCt) {
			delTxt := SubStr(context, foundPos)
			addTxt := SubStr(c2, foundPos)
			;~ delCt := stackIdx - foundPos + 1
			CommitKeystroke(delTxt, addTxt, uSendFlags)
			;~ TrayTip,, Replace [%delTxt%] (len=%delCt%) with [%addTxt%].
			return 2 ; match found
		}
	}
	if (ElseTxt != "") {
		CommitKeystroke("", ElseTxt, uElseFlags)
		return 2
	}
	;~ TrayTip, Not Matched:[%FindRegEx%], %context%
	return 3  ; no match


}
						; ov_A, ov_R, ov_W, ov_M, ov_E, ov_Wf, ov_Ef) {

;~ InContextReplace(FindRegEx, ReplaceTxt, ElseTxt="", uSendFlags=0, uElseFlags=0) {
	;~ global
	;~ local context, c2, match, foundPos, repCt, delTxt, addTxt
	;~ context := StrGet(&ctxStack, stackIdx)
	;~ foundPos := RegExMatch(context, FindRegEx . "$", match)
	;~ if (ErrorLevel) {
		;~ TrayTip, InContextReplace: "%FindRegEx%" "%ReplaceTxt%", RegExMatch ERROR: %ErrorLevel%
		;~ return 4 ; regex error
	;~ }
	;~ OutputDebug foundPos = %foundPos%, match = %match%

	;~ if (foundPos) {
		;~ c2 := RegExReplace(context, FindRegEx . "$", ReplaceTxt, repCt, 1)
		;~ if (ErrorLevel) {
			;~ TrayTip, InContextSend: "%FindRegEx%" "%ReplaceTxt%", RegExReplace ERROR: %ErrorLevel%
			;~ return 4 ; regex error
		;~ }
		;~ if (repCt) {
			;~ delTxt := SubStr(context, foundPos)
			;~ addTxt := SubStr(c2, foundPos)
			;~ delCt := stackIdx - foundPos + 1
			;~ CommitKeystrokeOld(delCt)
			;~ CommitKeystroke("", addTxt, uSendFlags)
			;~ TrayTip,, Replace [%delTxt%] (len=%delCt%) with [%addTxt%].
			;~ return 2 ; match found
		;~ }
	;~ }
	;~ if (ElseTxt != "") {
		;~ CommitKeystroke("", ElseTxt, uElseFlags)
	;~ }
	;~ TrayTip, Not Matched:[%FindRegEx%], %context%
	;~ return 3  ; no match
;~ }


DoPreviewRota(id) {
	global
	local setStart := RotSetStart%id%

	; stak =
	; Loop  % rotCt%id%
	; {
		; local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		; outputdebug loop %v%
		; stak :=  stak . a8, a8 . v
	; }

	; outputdebug % "ct=" . rotCt%id% . ",  stak=" . stak
	local newString := 1
	local matchedCols := 0
	local endPoint
	endPoint := setStart
	local idx := setStart
	local ct := rotCt%id%
	if (setStart > ct) {
		outputdebug *** ERROR: DoPreviewRota called with setStart=%setStart% > ct=%ct%
		return
	}
	;outputdebug DoPreviewRota(%id%), ct=%ct%, ss=%setstart%, ep=%endpoint%, idx=%idx%
	local firstTime = 1
	Loop {
		; outputdebug Loop[%idx%]
		if (firstTime)
			firstTime =
		else if (idx = endPoint) {  ; We've come all the way back around
			outputdebug DoPreviewRota [%id%] list not matched
			return
		}
		local val := numGet(rotListR%id%, idx * 2, "UShort")
		;outputdebug val = %val%, rotCt%id%[%idx% * 2]
		if (val = 32 or val = 10 or val=9) {
			if (matchedCols)
				break
			if (val <> 9)
				newString := 1
			idx++
			if (idx = rotCt%id%)
				idx = 0
			if (val = 10)
				setStart := idx
			;outputdebug eos: val=%val%, newstring=%newstring%, setstart=%setstart%.  next idx=%idx%
			continue
		}
		if (matchedCols = 0 and newString = 0) {
			idx++
			if (idx = rotCt%id%)
				idx = 0
			 ;outputdebug skipping. next idx=%idx%
			continue
		}
		newString := 0

		local toMatch := ctx(matchedCols + 1)
		matchedCols := (val = toMatch) ? matchedCols + 1 : 0
		idx++
		if (idx = rotCt%id%)
			idx = 0
		 ;outputdebug val=%val%, matchedcols=%matchedcols%, next idx=%idx%
	}
; Found Match
	; outputdebug last Character to replace by rotation: %toMatch%
	; outputdebug idx=%idx%, matchedcols=%matchedCols%, setStart=%setStart%

	if (val = 32 or val = 9)
		idx++
	else
		idx := setStart

	local pbuf
	varsetcapacity(pbuf, 256, 0)
	local pidx = 0
	Loop
	{	val := numGet(rotList%id%, idx * 2, "UShort")  ; Get it from the non-reversed list
		;outputdebug val = %val%
		if (val = 32 or val = 10 or val = 9)
			break
		numput(val, pbuf, pidx * 2, "UShort")
		pidx++	; TODO: Check that we don't overflow our buffer!!!
		; LastRotChar := val
		idx++
	}
	OutputDebug utip: %pbuf%
	;~ TrayTip,, %pbuf%
	;~ UTip(pbuf, rotaPeriod)
	; LastRotBack := rotBack%id%
	; LastRotId := id
	return
}

OnCtx(pos){
	return ctx(pos)
}

; Get the value of a character at a specified position back in the context.
; e.g.  ctx(2) returns the value of the 2nd-most-recent character of the context.
ctx(pos = 1)
{
	global
	local x := stackIdx - pos
	if x >= 0
		return numGet(ctxStack, x * 2, "UShort")
	return 0
}

OnFlags(pos) {
	return flags(pos)
}

; Get the flags at a specified position back in the context.
; e.g.  flags(2) returns the flags for the the 2nd-most-recent character of the context.
flags(pos = 1)
{
	global
	local x := stackIdx - pos
	if x >= 0
		return numGet(flagStack, x * 4, "UInt")
	return 0
}

; Backspace was tapped.  Undo last keystroke/action.
OnUndoLast() {
	Gui 2:Hide
	global currBS
	BSCt := currBS + 1
	if (BSCt < 4) 		; TODO:  This is currently hard-coded so that after 4 Undo actions, we'll just start doing pure backspaces.
									; Actually, sometimes a true undo would back up more than one BS (e.g. NFD), and 4 is too arbitrary.  May need to be based on a collapsed history.
		UndoKeystroke()	; Also clears currBS
	else
		SendBackspace()
	currBS := BSCt
}

; Perhaps called directly by Shift+BS.  Send BS without replacing intermediate stages.  Nuke any keystroke history.
SendBackspace() {
	global
	Gui 2:Hide
	if (AddStack.MaxIndex() != 0) {
		AddStack := []
		DelStack := []
	}
	_DoPureBackSp()
}

OnBack(ct) {
	Gui 2:Hide
	Loop %ct%
	{
		SendBackspace()
	}
}


OnEnter() {
	Gui 2:Hide
	Send {Enter}
	push(13)
}

OnTab() {
	Gui 2:Hide
	Send {Tab}
	push(9)
}

OnSpace() {
	Gui 2:Hide
	Send {Space}
	push(32)
}

; Send a character, optionally remembering a 32-bit flags value associated with it
OnSendChar(wParam, lParam) {
	Gui 2:Hide
	SendChar(wParam, lParam)
	return 1
}

SendChar(ch, uFlags=0) {
	;setformat integerfast, d
	;~ v := ch + 0
	;outputdebug SendChar: %ch% (%v%), %uFlags%
	if (ch <= 0xffff) {
		if (ch>1) {
			CommitKeystroke("", chr(ch), uFlags)
		} else {
			TrayTip,, This keyboard uses SendChar(ch flags) with ch of 0 or 1. `nIt should be updated to use SetPhase() or SetDeadkey() instead.
			push(ch, uFlags)
		}
	} else {  ; SMP character. Convert to surrogate pair
		;~ SetFormat integerfast, hex
		ch -= 0x10000
		lead := (0xd800 | (ch >> 10))
		trail := (0xdc00 | (ch & 0x3ff))
		c := Chr(lead) . chr(trail)
		CommitKeystroke("", c, uFlags)
		;~ SendTextToApp(c)
		;~ push(lead, uFlags)
		;~ push(trail, uFlags)
	}
	;~ global LastRotBack =
	showstack()	; //DEBUG
}

;~ SendSMPChar(lead, trail, uFlags=0) {
	;~ push(lead, uFlags)
	;~ push(trail, uFlags)
	;~ SendRawText(Chr(lead) . Chr(trail))
	;~ global LastRotBack =
	;~ showstack()	; //DEBUG

;~ }

;~ OnDeleteChar(numCharsToDel, endingPos) {
	;~ Gui 2:Hide
	;~ return DeleteChar(numCharsToDel, endingPos)
;~ }

; DeleteChar(1,1) is virtually equivalent to a backspace.
; DeleteChar(2, 3) when context is "abXXcd" will delete the 2 X'es that end 3 characters back.
;~ DeleteChar(numCharsToDel=1, endingPos=1) {
	;~ global
	;~ ;outputdebug DeleteChar(%numCharsToDel%, %endingPos%)
	;~ local toBack := numCharsToDel + endingPos - 1
	;~ if (stackIdx < toBack) {
		;~ outputdebug Not enough on the stack to back up %toBack% chars
		;~ SoundPlay *-1
		;~ return 1
	;~ }
	;~ SendBkSpc(toBack)
	;~ ; Add back chars that were to the right of endingPos
	;~ Loop % endingPos - 1  ; %
	;~ {
		;~ local cc := endingPos - A_Index
		;~ local v := ctx(cc)
		;~ local f := flags(cc)
		;~ SendChar16(v)
		;~ local p := stackIdx - cc - numCharsToDel  ; BUG: Check we're not going back too far
		;~ numPut(v, ctxStack, 2*p, "UShort")
		;~ numPut(f, flagStack, 4*p, "UInt")
	;~ }
	;~ stackIdx -= numCharsToDel
	;~ if stackIdx < 0
		;~ stackIdx = 0
	;~ ;showstack()	; //DEBUG
	;~ return 0
;~ }

; Replace one or more characters with a specified character.
; The characters to replace are identified by their count and their ending position.
; e.g. If the context is "abXXde", then ReplaceChar(42, 2, 3) will make it "ab*de".
ReplaceChar(u, numCharsToRep=1, endingPos=1, uFlags=0) {
	global
	Gui 2:Hide
	outputdebug ReplaceChar(%u%, %numCharsToRep%, %endingPos%, %uFlags%)
	outputdebug stackIdx=%stackIdx%  endingPos=%endingPos%
	local toBack := numCharsToRep + endingPos - 1
	if (stackIdx < toBack) {
		outputdebug Not enough on the stack to back up %toBack% chars
		SoundPlay *-1	;
		return 1
	}
	CommitKeystroke(ctxStr(toBack), Chr(u), uFlags)
							;~ SendBkSpc(toBack)
							;~ SendChar16(u)
							;~ NumPut(u, ctxStack, 2*(stackIdx - (numCharsToRep + endingPos - 1)), "UShort")
							;~ NumPut(uFlags, flagStack, 4*(stackIdx - (numCharsToRep + endingPos - 1)), "UInt")
							;~ ; Add back chars that were to the right of endingPos
							;~ Loop % endingPos - 1  ; %
							;~ {
								;~ local cc := endingPos - A_Index
								;~ local v := ctx(cc)
								;~ local f := flags(cc)
								;~ SendChar16(v)
								;~ local p := stackIdx - cc - (numCharsToRep - 1)  ; BUG: Check we're not going back too far
								;~ numPut(v, ctxStack, 2*p, "UShort")
								;~ numPut(f, flagStack, 4*p, "UInt")
							;~ }
							;~ stackIdx -= (numCharsToRep - 1)
							;~ if stackIdx < 0
								;~ stackIdx = 0
							;~ ;showstack()	; //DEBUG
	return 0
}


; Insert a character (whose code is u) immediately prior to the most recent character.
InsertChar(u, uFlags=0) {
	Gui 2:Hide
	;outputdebug InsertChar(%u%)
	vl := ctx()
	fl := flags()
	ReplaceChar(u, 1, 1, uFlags)
	SendChar(vl, fl)
	;showstack()	; //DEBUG
}

; Temporary way to toggle our Back behavior in CommitKeystroke().
; This may need to be a user preference for certain apps/windows that eat more than one char
; when you press Backspace.
$^+Backspace::
thisAppDoesGreedyBackspace := NOT thisAppDoesGreedyBackspace
gb := thisAppDoesGreedyBackspace ? OnString : OffString
TempString:=GetLang(61) ; Handling of greedy backspace is
TrayTipQ(TempString . " " . gb)
return

; The equivalent of sending ct number of Backspace characters, except that a mode is supported
; to handle apps that delete entire character sequences with a single backspace.
; Does not use or affect the context stack, so keyboards should never call this directly,
; but should call CommitKeystroke() instead.
; Returns the number of UTF-16 code units removed, so that the stack can be adjusted accordingly.  e.g. One SMP char = 2 UTF-16 code units.
SendBkSpc(ct=1) {  ; BUG:  some callers of this function are providing a ct parameter of the number of  code units to back up, not number of BS to do.  ?????!
	global
	CurrPhase := 0   ; TEMPORARY, until this function is only called by CommitKeystroke
	CurrDeadkey := 0   ; TEMPORARY, until this function is only called by CommitKeystroke

	local di := 0
	;~ outputdebug SendBkSpc: [%ct%]
	if (ct > 20 or ct="") {  ; Can cause program to crash otherwise.  May happen if user got parameters switched on ReplaceChar etc.
		outputdebug Maximum simultaneous backspaces is 20
		return
	}
	loop %ct% {
		local toBack := 1
		local cc := ctx()
		;~ outputdebug cc = %cc%
		;~ if ((cc >= 0xDC00) and (cc <= 0xDFFF)) {  ; If we're about to delete the trail surrogate (range DCC0-DFFF), BS will delete the leading surrogate too. (range D800-DBFF) We just need to ensure it gets deleted from history too.
		if (cc>>10 = 0x37) { ; that is, DC00 <= cc <= DFFF
			OutputDebug Deleting trail surrogate: %cc%
			toBack += 1
			di += 1
		}
		if (thisAppDoesGreedyBackspace) {
			OutputDebug avoiding greedy backspace
			Clipsaved := ClipboardAll  		; Preserve clipboard state while we do this
			Loop {
				clipboard =
				Send +{Left}^x			; Send Shift+Left to select, and then Ctrl+X to cut
				ClipWait 10				; Wait for clipboard
				buf := Clipboard
				numDeleted := StrLen(buf)  ; See how many chars were deleted
				toBack -= numDeleted 	; See how many we still need to back up over (or need to add back, if negative)
				Outputdebug toBack = %toBack%, numDeleted = %numDeleted%
				if toBack <= 0
					break
			}
			toback *= -1
			Loop %toBack% 					; Add them back
			{
				local qq := numGet(buf, (A_Index-1)*2, "UShort")
				SendChar16(qq)
				outputdebug Added back %qq%
			}
			Clipboard := Clipsaved	; Restore the original clipboard.
			Clipsaved =		; Free the memory in case the clipboard was very large.
		} else {
			;~ OutputDebug send normal BS
			Send {BS}  ; Assumes that each BS will eat only one BMP or SMP character
		}
		di += 1
	}
	buf =
	return di
}



; ================================

; Currently the context stack works like this:  When the stack gets full, the bottom half of the stack is
; discarded, and the top half is shifted down to the bottom.

; It should be rewritten like this: The stack is circular.  We keep track of pointers to the first and last
; valid items as startIdx and endIdx.  If it grows past the end of the array, we wrap around to overwrite
; the beginning, pushing the startIdx up.  When startIdx is higher than endIdx, it means we have previously
; wrapped around.

; Numbers on the context stack are 16 bits. Numbers on the flag stack are 32 bits.

; --------------------------------
; Push an item onto the stack
push(n, uFlags=0)
{
	global
	if stackIdx = 1024   ; 1024 = %maxstack%	; If the stack is full, drop the %stackshift% oldest items, and shift everything down.
	{
		Loop 512     ;   512 = maxstack - stackshift
		{
			numput(numGet(ctxStack,2*(A_Index  + 511), "UShort"), ctxStack, 2*(A_Index - 1), "UShort")			; 511 = stackshift - 1
			numput(numGet(flagStack,4*(A_Index  + 511), "UInt"), flagStack, 4*(A_Index - 1), "UInt")		; 511 = stackshift - 1
		}
		stackIdx -= 512     ; 512 = stackshift
	}
	numPut(n, ctxStack, 2*stackIdx, "UShort")
	numPut(uFlags, flagStack, 4*stackIdx, "UInt")
	stackIdx++
}

refreshStack(ByRef s) ; Reset the context stack to the provided string
{
	global
	ctxStack := s
	stackIdx := strlen(ctxStack)
	; now zero out the contents of the flagStack
	loop %stackIdx% {
		NumPut(0, flagStack, 4*(A_Index - 1), "UInt")
	}
}

ctxStr(codeUnits) {
; return the string at the end of the context stack up to %codeUnits% in length.
	global
	if (codeUnits > stackIdx)
		codeUnits := stackIdx
	;~ return StrGet(ctxStack, (stackIdx-codeUnits)*2, codeUnits)
	return StrGet(&ctxStack +(stackIdx-codeUnits)*2, codeUnits)
}
; DEBUG>>

;A debug routine to show the stack
showstack()
{
	global
	local v
	local s =
	local s2 =
	SetFormat integerfast, H
	Loop %stackIdx%
	{
		v := numGet(ctxStack,2*(A_Index - 1), "UShort")
		s = %s%|%v%
	}

	s2 := StrGet(&ctxStack, stackIdx)
	OutputDebug ctxStack: %s2%
	outputdebug ctxStack: %s%   [idx = %stackIdx%]
	;~ showflags()
	SetFormat integerfast, d
}
;A debug routine to show the flags
showflags()
{
	global
	local v
	local s =
	Loop %stackIdx%
	{
		v := numGet(flagStack,4*(A_Index - 1), "UInt")
		s = %s%|%v%
	}
	outputdebug flagStack: %s%   [idx = %stackIdx%]
}


; <<DEBUG

; Pop an item off the stack
/*  Unused
pop()
{
	global
	if stackIdx = 0
		return ""
	return numGet(ctxStack,--stackIdx * 2)
}
*/

dumpStr(byref str, byref txt, len=-1)
{
	if (len=-1)
		len := strlen(str)
	s := "["
	setformat integerfast, H
	Loop %len%
	{
		v := numGet(str,2*(A_Index - 1), "UShort")
		if (v<32 or v>254)
			s .= "<" v ">"
		else
			s .= chr(v)
	}
	s .= "]"
	setformat integerfast, D
	OutputDebug %txt% %s%
}
