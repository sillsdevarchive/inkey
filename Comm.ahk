Send_WM_COPYDATA(Kbd, dwNum, ByRef StringToSend)  ; ByRef saves a little memory in this case.
; This function sends the specified number and string to the window of the specified keyboard, and returns the reply.
{
	VarSetCapacity(CopyDataStruct, 12, 0)  ; Set up the structure's memory area.
	NumPut(dwNum, CopyDataStruct, 0)  ;
	NumPut(StrLen(StringToSend) + 1, CopyDataStruct, 4)  ;     ; Set the structure's cbData member to the size of the string, including its zero terminator: OS requires that this be done.
	NumPut(&StringToSend, CopyDataStruct, 8)  ; Set lpData to point to the string itself.
	r := DllCall("SendMessage", UInt, GetKbdHwnd(Kbd), UInt, 0x4A, UInt, 0, UInt, &CopyDataStruct)
	if (ErrorLevel) {
		SoundPlay *16
		outputdebug ************ CRITICAL ERROR: Send_WM_COPYDATA(%Kbd%, %dwNum%, %StringToSend%) failed!
	}
	return r
}

setupCallbacks() {
	OnMessage(0x4a, "Receive_WM_COPYDATA")  ; 0x4a is WM_COPYDATA.  It won't work to use a different message number.
	OnMessage(0x8010, "OnSendChar")
	OnMessage(0x8011, "OnCtx")
	OnMessage(0x8012, "OnFlags")
	OnMessage(0x8013, "OnBack")
	OnMessage(0x8014, "OnDeleteChar")
	OnMessage(0x8015, "OnUndoLast")
	OnMessage(0x8016, "OnEnter")
	OnMessage(0x8017, "OnTab")
	OnMessage(0x8018, "OnSpace")
	OnMessage(0x8020, "OnKbdInit")
	OnMessage(0x10, "On_WM_CLOSE")
}

OnKbdInit(ProtocolID, KbdID, msg, hwnd) {
	global
	; TODO: Check that Protocol ID is at least whatever we need it to be.
	Outputdebug Got test message (%msg%) from kbd #%kbdid%, file #%fileid% sent to hwnd %hwnd%
	DllCall("QueryPerformanceCounter", "Int64 *", CounterAfter)
	DllCall("QueryPerformanceFrequency", "Int64 *", f)
	x := (CounterAfter - CounterBefore) * 1000 / f
	outputdebug % "Kbd #" . kbdID . " took " . x . " ms to launch"
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
	maxstack = 1024  	; Constant indicating maximum number of items in stack.
	stackshift = 512	; Constant indicating number of items to discard from bottom of stack when maximum is reached.
	ctxStack =
	LastRotBack =

	stackIdx = 0
	varSetCapacity(ctxStack, maxstack * 4, 0)
	varSetCapacity(flagStack, maxstack * 4, 0)
		;setformat integer, d
}

Receive_WM_COPYDATA(wParam, lParam)
{	; This function can receive string data from a keyboard.
	; Any processing done in response must return quickly. If necessary, set a timer to kick off a longer process.
	dwNum := NumGet(lParam + 0)  ; specifying MyVar+0 forces the number in MyVar to be used instead of the address of MyVar itself
	SetFormat integer, H
	dwNum += 0
	SetFormat integer, d
	dwSize := NumGet(lParam + 4)  ; lParam+4 is the address of CopyDataStruct's cbData member.
	StringAddress := NumGet(lParam + 8)  ; lParam+8 is the address of CopyDataStruct's lpData member.
	; StringLength := DllCall("lstrlen", UInt, StringAddress)
   ;outputdebug Receiving: dwNum=%dwNum%, dwSize=%dwSize%
   if (dwSize <= 0)
		StringData := ""
	else
	{
		VarSetCapacity(StringData, dwSize, 0)
		;DllCall("lstrcpy", "str", StringData, "uint", StringAddress)  ; Copy the string out of the structure.
		DllCall("MSVCRT\memcpy", "str", StringData, "uint", StringAddress, "uint", dwSize)  ; Copy the string out of the structure.
		outputdebug %A_ScriptName% received string message: %StringData%

		; Handle string passed as a TrayTipQ command (0x9001)
		if (dwNum = 0x9001 and RegExMatch(StringData,"^(?P<text>.*)\|(?P<title>.*)\|(?P<ms>.+)", ov_)) {
			outputdebug received tip message: %ov_text%, %ov_title%, %ov_ms%
			TrayTipQ(ov_text, ov_title, ov_ms)
			return 3
		}

		; Handle string passed as a ReplaceChar command (0x9002)
		if (dwNum = 0x9002 and RegExMatch(StringData,"^(?P<ch>.*),(?P<nc>.*),(?P<ep>.+),(?P<fl>.+)", ov_)) {
			outputdebug received ReplaceChar message: %ov_ch%, %ov_nc%, %ov_ep%, %ov_fl%
			ReplaceChar(ov_ch, ov_nc, ov_ep, ov_fl)
			return 3
		}

		; Handle string passed as a InsertChar command (0x9003)
		if (dwNum = 0x9003 and RegExMatch(StringData,"^(?P<ch>.*),(?P<fl>.+)", ov_)) {
			outputdebug received InsertChar message: %ov_ch%, %ov_fl%
			InsertChar(ov_ch, ov_fl)
			return 3
		}

		; Handle string passed as a RegisterRota command (0x9004)
		if (dwNum = 0x9004 and RegExMatch(StringData,"^(?P<id>.+?)\|(?P<def>.+?)\|(?P<flg>.+?)\|(?P<back>.+?)\|(?P<style>.+?)\|(?P<list>.*)", ov_)) {
			;outputdebug received RegisterRota message: %ov_id%, %ov_def%, %ov_back%, %ov_style%, %ov_list%
			RegisterRota(ov_id, ov_def, ov_flg, ov_back, ov_style, ov_list)
			return 3
		}

		; Handle string passed as a DoRota command (0x9005)
		if (dwNum = 0x9005) {
			outputdebug received DoRota message: %StringData%
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
			U8Tip(ov_text, ov_ms ? ov_ms : rotaPeriod)
			return 3
		}

		; Handle string passed as a PreviewChar command (0x9008)
		if (dwNum = 0x9008 and RegExMatch(StringData,"^(?P<cc>.*)\|(?P<ms>.+)", ov_)) {
			outputdebug received tip message: %ov_cc%, %ov_ms%
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
			return SendChars(StringData)
		}

		; Handle string passed as a InsertChars command (0x900B)
		if (dwNum = 0x900B) {
			outputdebug received InsertChars message
			return InsertChars(StringData)
		}

	}
	setformat integer, h
	dwNum += 0
	Outputdebug ** ERROR: %A_ScriptName% has no handler for received string: %dwNum%, "%StringData%"
	setformat integer, d
	return 2  ; Tell sender that we didn't process this string
}

SendChars(ByRef data) {
	uFlags := NumGet(data, 0) ; "UInt"
	numCh := NumGet(data, 4, "UShort")
	;outputdebug SendChars: uFlags=%uFlags%, numCh=%numCh%
	if (numCh > 32)
		return 2  ; guard against bad parameters
	Loop % numCh
		SendChar(NumGet(data, A_Index * 2 + 4, "UShort"), uFlags)
	return 3 ; OK
}

InsertChars(ByRef data) {
	uFlags := NumGet(data, 0) ; "UInt"
	pos := NumGet(data, 4, "UShort")
	numCh := NumGet(data, 6, "UShort")
	if (numCh > 32 or pos > 32)
		return 2 ; guard against bad parameters
	Loop % pos	; Remember these characters   TODO:  directly manipulate the stacks
	{
		ctx%A_Index% := ctx(A_Index)
		flg%A_Index% := flags(A_Index)
	}
	Back(pos)
	Loop % numCh
		SendChar(NumGet(data, A_Index * 2 + 6, "UShort"), uFlags)
	ii := pos
	Loop % pos
	{
		SendChar(ctx%ii%, flg%ii%)
		ii--
	}
	return 3 ; OK
}

SendRotaChar(id, u, uFlags) {
	SendChar(u, uFlags)
	if (rotStyle%id% & 16)
		DoPreviewRota(id)
}

RegisterRota(id, def, flags, back, style, list) {
	global
	rotDef%id% := def
	rotFlags%id% := flags
	rotBack%id% := back
	rotStyle%id% := style
	RotSetStart%id% = 0
	outputdebug RegisterRota(%id%, %def%, %flags%, %back%, %style%, ...)
	list .= Chr(10)
	if (style & 1)  ; Single-line list.  Sets were delimited with tabs.
		StringReplace list, list, %A_Tab%, `n, All
	;VarSetCapacity(rotList%id%, StrLen(list), 0)
	rotCt%id% := StrLen(list) + 1
	rotList%id% := list
;	outputdebug % "rotCt = " . rotCt%id%
	VarSetCapacity(rotListR%id%, rotCt%id% * 2, 0)
	local stak =
	local outIdx = 0
	Loop  % rotCt%id%
	{  ; This loop reverses the internal character order of strings longer than a single character.
		local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		if (v = 32 or v = 9 or v = 10) {
			Loop, parse, stak, `,
				; When we reach the blank item at the end of the list, store the space or tab.
				NumPut(A_LoopField ? A_LoopField : v, rotListR%id%, 2 * outIdx++, "UShort")
			stak =
		} else
			stak := v . "," . stak
	}
	if (style & 2) {
		; This is an implicitly non-looping rota.  Replace the last space in each set with tab so that
		; when DoRota is scanning through, it won't match the last item in the set.
		outIdx := rotCt%id% - 2
		local foundNL = 1
		Loop
		{	if (outIdx <= 0)
				break
			v := NumGet(rotListR%id%, outIdx * 2, "UShort")
			if (v = 32 and foundNL = 1) {
				NumPut(9, rotListR%id%, outIdx * 2, "UShort")
				foundNL = 0
			} else if (v = 10)
				foundNL = 1
			else if (v = 9)
				foundNL = 0
			outIdx--
		}
	}
;	outputdebug % "rotListR = " . rotListR%id%

	; stak =
	; Loop  % rotCt%id%
	; {
		; local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		; stak := stak . a8, a8 . v
	; }
	; outputdebug stak=%stak%
}

DoRota(id) {
	global
	static rotTime = 0
	Gui 2:Hide

	if (rotStyle%id% & 8) {
		local priorRT := rotTime
		rotTime := A_TickCount
		if ((rotTime - priorRT > rotaPeriod) or (flags() <> rotFlags%id%)) {
			showflags()
			local ms := rotTime - priorRT
			outputdebug % "rota expired or not match flags: " . priorRT . "|" . rotTime . " [" . ms . "] " . rotaPeriod . ", " . flags() . ", " . rotFlags%id%
			if (rotDef%id%)
				SendChar(rotDef%id%, rotFlags%id%)
			if (rotStyle%id% & 16)
				DoPreviewRota(id)
			return 3
		}
	}
	; stak =
	; Loop  % rotCt%id%
	; {
		; local v := NumGet(rotList%id%, (A_Index - 1) * 2, "UShort")
		; outputdebug loop %v%
		; stak :=  stak . a8, a8 . v
	; }

	outputdebug % "ct=" . rotCt%id% . ",  stak=" . stak
	outputdebug DoRota(%id%) with idx=%idx% and ct=%ct%
	local newString := 1
	local matchedCols := 0
	if (id <> LastRotID or ctx() <> LastRotChar)
		RotSetStart%id% := 0
	local endPoint
	endPoint := RotSetStart%id%
	local idx := RotSetStart%id%
	local ct := rotCt%id%
	if (idx > ct)
		outputdebug *** ERROR: DoRota(%id%) with idx=%idx% > ct=%ct%
	;outputdebug DoRota(%id%), ct=%ct%, ep=%endpoint%, idx=%idx%
	if (not rotCt%id%)
		return 4	;  No such rota.  Keyboard programmer error.
	local firstTime = 1
	Loop {
		outputdebug Loop[%idx%]
		if (firstTime)
			firstTime =
		else if (idx = endPoint) {  ; We've come all the way back around
			outputdebug DoRota [%id%] list not matched
			if (rotDef%id%)
				SendChar(rotDef%id%, rotFlags%id%)
			if (rotStyle%id% & 16)
				DoPreviewRota(id)
			return 3
		}
		local val := numGet(rotListR%id%, idx * 2, "UShort")
		outputdebug val = %val%, rotCt%id%[%idx%]
		if (val = 32 or val = 10 or val=9) {
			if (matchedCols)
				break
			if (val <> 9)
				newString := 1
			idx++
			if (idx = rotCt%id%)
				idx = 0
			if (val = 10)
				RotSetStart%id% := idx
			outputdebug eos: val=%val%, newstring=%newstring%,  next idx=%idx%
			continue
		}
		if (matchedCols = 0 and newString = 0) {
			idx++
			if (idx = rotCt%id%)
				idx = 0
			 outputdebug skipping. next idx=%idx%
			continue
		}
		newString := 0

		local toMatch := ctx(matchedCols + 1)
		matchedCols := (val = toMatch) ? matchedCols + 1 : 0
		idx++
		if (idx = rotCt%id%)
			idx = 0
		 outputdebug val=%val%, matchedcols=%matchedcols%, next idx=%idx%
	}
; Found Match
	; outputdebug last Character to replace by rotation: %toMatch%
	; outputdebug idx=%idx%, matchedcols=%matchedCols%,

	Back(matchedCols)
	if (val = 32 or val = 9)
		idx++
	else
		idx := RotSetStart%id%

	Loop
	{	val := numGet(rotList%id%, idx * 2, "UShort")  ; Get it from the non-reversed list
		outputdebug val = %val%
		if (val = 32 or val = 10 or val = 9)
			break
		SendChar(val, rotFlags%id%)
		LastRotChar := val
		idx++
	}
	LastRotBack := rotBack%id%
	LastRotId := id
	if (rotStyle%id% & 16)
		DoPreviewRota(id)
	return 2  ; sucessfully handled
}

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
	UTip(pbuf, rotaPeriod)
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
		return numGet(ctxStack, x * 4)
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
		return numGet(flagStack, x * 4)
	return 0
}

; Backspace was pressed.  Undo last keystroke/action.
OnUndoLast() {
	Gui 2:Hide

	Back() ; TODO: Actually, this needs to revert based on history

	if (LastRot) {	; If last keystroke was a rotation, pressing BkSp should restore the rotation key's own character.
		SendChar(LastRot)
		LastRot =
	}
}

OnBack(ct) {
	Gui 2:Hide
	Back(ct)
}

; Back up a specified number of characters
Back(ct=1) {
	global

	;outputdebug Back: %ct%
	SendBkSpc(ct)

	if (ct > stackIdx)
		ct = stackIdx	; prevent overflow

	stackIdx -= ct
	if stackIdx < 0
		stackIdx = 0
	showstack()	; //DEBUG
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
	global
	;SetFormat integer, d
	v := ch + 0
	outputdebug SendChar: %ch% (%v%), %uFlags%
	if (ch>1) {
		SendCh(ch)
		outputdebug sendch(%ch%)
	}
	push(ch, uFlags)
	LastRotBack =
	showstack()	; //DEBUG
}

OnDeleteChar(numCharsToDel, endingPos) {
	Gui 2:Hide
	return DeleteChar(numCharsToDel, endingPos)
}

; DeleteChar(1,1) is virtually equivalent to a backspace.
; DeleteChar(2, 3) when context is "abXXcd" will delete the 2 X'es that end 3 characters back.
DeleteChar(numCharsToDel=1, endingPos=1) {
	global
	;outputdebug DeleteChar(%numCharsToDel%, %endingPos%)
	local toBack := numCharsToDel + endingPos - 1
	if (stackIdx < toBack) {
		outputdebug Not enough on the stack to back up %toBack% chars
		SoundPlay *-1
		return 1
	}
	SendBkSpc(toBack)
	; Add back chars that were to the right of endingPos
	Loop % endingPos - 1  ; %
	{
		local cc := endingPos - A_Index
		local v := ctx(cc)
		local f := flags(cc)
		SendCh(v)
		local p := stackIdx - cc - numCharsToDel  ; BUG: Check we're not going back too far
		numPut(v, ctxStack, 4*p)
		numPut(f, flagStack, 4*p)
	}
	stackIdx -= numCharsToDel
	if stackIdx < 0
		stackIdx = 0
	showstack()	; //DEBUG
	return 0
}

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
	SendBkSpc(toBack)
	SendCh(u)
	NumPut(u, ctxStack, 4*(stackIdx - (numCharsToRep + endingPos - 1)))
	NumPut(uFlags, flagStack, 4*(stackIdx - (numCharsToRep + endingPos - 1)))
	; Add back chars that were to the right of endingPos
	Loop % endingPos - 1  ; %
	{
		local cc := endingPos - A_Index
		local v := ctx(cc)
		local f := flags(cc)
		SendCh(v)
		local p := stackIdx - cc - (numCharsToRep - 1)  ; BUG: Check we're not going back too far
		numPut(v, ctxStack, 4*p)
		numPut(f, flagStack, 4*p)
	}
	stackIdx -= (numCharsToRep - 1)
	if stackIdx < 0
		stackIdx = 0
	showstack()	; //DEBUG
	return 0
}


; Insert a character (whose code is u) immediately prior to the most recent character.
		; TO DO: Implement an optional parameter pos=1 so that the function will
		; insert a character (whose code is u) at pos number of characters back in the context.
		; e.g. InsertChar(42, 1) would insert character 42 immediately prior to the most recent character.
InsertChar(u, uFlags=0) {
	Gui 2:Hide
	;outputdebug InsertChar(%u%)
	v := ctx()
	f := flags()
	ReplaceChar(u, 1, 1, uFlags)
	SendChar(v, f)
	showstack()	; //DEBUG
}

; Temporary way to toggle our Back() behavior.
; This may need to be a user preference for certain apps/windows that eat more than one char
; when you press Backspace.
$^+Backspace::
thisAppDoesGreedyBackspace := NOT thisAppDoesGreedyBackspace
gb := thisAppDoesGreedyBackspace ? %OnString% : %OffString%
TempString:=GetLang(61) ; Handling of greedy backspace is
TrayTipQ(%TempString% . " " . %gb%)
return

; The equivalent of sending ct number of Backspace characters, except that a mode is supported
; to handle apps that delete entire character sequences with a single backspace.
; Does not use or affect the context stack, so keyboards should never call this directly,
; but should call Back() instead.
SendBkSpc(ct=1) {
	global
	outputdebug SendBkSpc: [%ct%]
	if (ct > 6 or ct="") {  ; Can cause program to crash otherwise.  May happen if user got parameters switched on ReplaceChar etc.
		outputdebug Maximum simultaneous backspaces is 6
		return
	}
	local toBack := ct
	if (thisAppDoesGreedyBackspace) {
				; TO DO: Preserve clipboard state while we do this
		Loop {
			clipboard =
			Send +{Left}^x			; Send Shift+Left to select, and then Ctrl+X to cut
			ClipWait 10				; Wait for clipboard
			Transform x, Unicode	; Get clipboard text as Unicode
			numDeleted := DecodeUTF8String(buf,x)  ; See how many chars were deleted
			toBack -= numDeleted 	; See how many we still need to back up over (or need to add back, if negative)
			;>>DEBUG
			Outputdebug toBack = %toBack%, numDeleted = %numDeleted%
			showbuf()
			;<<DEBUG
			if toBack <= 0
				break
		}
		toback *= -1
		Loop %toBack% 					; Add them back
		{
			SendCh(numGet(buf, (A_Index-1)*4))
			;>>DEBUG
			local qq := numGet(buf, (A_Index-1)*4)
			outputdebug Added back %qq%
			;<<DEBUG
		}
	} else {
		Send {BS %ct%}  ; Assumes that each BS will eat only one character
	}
	buf =
	return 0
}

; Decode a UTF8 string, copying the resultant character values into an array of
; 32-bit values.  This array is NOT null-terminated.
; The return value indicates the number of valid elements in the array.
DecodeUTF8String(ByRef buf, ByRef u8) {
	sl := strlen(u8)
	if sl = 0
		return 0
	ct = 0
	varSetCapacity(buf, sl * 4, 0)
	i = 1
	Loop
	{
		b1 := asc(substr(u8,i,1))
		if b1 < 128
		{	; Lower ANSI character "encoded" in a single byte
			v := b1
			i += 1
		} else {
			b2 := asc(substr(u8,i+1,1))
			if b1 & 0xE0 = 0xC0
			{ ; two byte encoding
				v := ((b1 & 0x1f) << 6) | (b2 & 0x3f)
				i += 2
			} else {
				b3 := asc(substr(u8,i+2,1))
				if b1 & 0xf0 = 0xe0
				{ ; three-byte encoding
					v := ((b1 & 0x0f) << 12) + ((b2 & 0x3f) << 6) + (b3 & 0x3f)
					i += 3
				} else {
				 ; four-byte encoding
					b4 := asc(substr(u8,i+3,1))
					v := ((b1 & 0x7) << 18) | ((b2 & 0x3f) << 6) | ((b3 & 0x3f) << 6) | (b4 & 0x3f)
					i += 4
				}
			}
		}
		numPut(v, buf, 4*ct++)
		if (i >= sl)
			break
	}
	return ct
}

; ================================

; Currently the context stack works like this:  When the stack gets full, the bottom half of the stack is
; discarded, and the top half is shifted down to the bottom.

; It should be rewritten like this: The stack is circular.  We keep track of pointers to the first and last
; valid items as startIdx and endIdx.  If it grows past the end of the array, we wrap around to overwrite
; the beginning, pushing the startIdx up.  When startIdx is higher than endIdx, it means we have previously
; wrapped around.

; Numbers on the stack are of type UINT. (32 bits)

; --------------------------------
; Push an item onto the stack
push(n, uFlags=0)
{
	global
	if stackIdx = %maxstack%	; If the stack is full, drop the %stackshift% oldest items, and shift everything down.
	{
		local so := maxstack - stackshift
		Loop %so%
		{
			numput(numGet(ctxStack,4*(A_Index - 1 + stackshift)), ctxStack, 4*(A_Index - 1))
			numput(numGet(flagStack,4*(A_Index - 1 + stackshift)), flagStack, 4*(A_Index - 1))
		}
		stackIdx -= stackshift
	}
	numPut(n, ctxStack, 4*stackIdx)
	numPut(uFlags, flagStack, 4*stackIdx)
	stackIdx++
}



; DEBUG>>

;A debug routine to show the stack
showstack()
{
	global
	local v
	local s =
	Loop %stackIdx%
	{
		v := numGet(ctxStack,4*(A_Index - 1))
		s = %s%|%v%
	}
	outputdebug ctxStack: %s%   [idx = %stackIdx%]
	showflags()
}
;A debug routine to show the flags
showflags()
{
	global
	local v
	local s =
	Loop %stackIdx%
	{
		v := numGet(flagStack,4*(A_Index - 1))
		s = %s%|%v%
	}
	outputdebug flagStack: %s%   [idx = %stackIdx%]
}


; A debug routine to show the values cut to the clipboard by the Back() function.
showbuf()
{
	global
	local v
	local s =
	setformat integer, HEX
	Loop %numCopied%
	{
		v := numGet(buf,4*(A_Index - 1))
		s = %s%|%v%
	}
	setformat integer, d
	outputdebug buf contains [%s%]
}
; <<DEBUG

; Pop an item off the stack
/*  Unused
pop()
{
	global
	if stackIdx = 0
		return ""
	return numGet(ctxStack,--stackIdx * 4)
}
*/

/*
dumpvar()
{
	global
	local v
	local s =
	;Loop % stackIdx * 4
	Loop % stackIdx * 4
	{
		v := numGet(ctxStack,(A_Index - 1), "UChar")
		s = %s%|%v%
	}
	outputdebug ctxStack: %s%   [idx = %stackIdx%]
}
*/
