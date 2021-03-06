
#SingleInstance force

; Save the following script as "Sender.ahk" then launch it.  After that, press the Win+Space hotkey.
TargetScriptTitle = inkey.ahk ahk_class AutoHotkey
wParam := 17
return

#space::  ; Win+Space hotkey. Press it to show an InputBox for entry of a message string.
InputBox, StringToSend, Send text via WM_COPYDATA, Enter some text to Send:
if ErrorLevel  ; User pressed the Cancel button.
	return
result := Send_WM_COPYDATA(StringToSend, TargetScriptTitle)
if result = FAIL
	MsgBox SendMessage failed. Does the following WinTitle exist?:`n%TargetScriptTitle%
else if result = 0
	MsgBox Message sent but the target window responded with 0, which may mean it ignored it.
return

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)  ; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
{
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
	; First set the structure's cbData member to the size of the string, including its zero terminator:
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(0x9007, CopyDataStruct, 0)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	wParam := StrLen(StringToSend)
	SendMessage, 0x4a, wParam, &CopyDataStruct,, %TargetScriptTitle%  ; 0x4a is WM_COPYDATA. Must use Send not Post.
	DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
	SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
	wParam := wParam + 2
	OutputDebug wParam = %wParam%, tst = %TargetScriptTitle%
	return ErrorLevel  ; Return SendMessage's reply back to our caller.
}