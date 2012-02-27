installorupdatefromzip(ZipPathFile) {
	errorcheck = 0
	updatingkeyboard = false
	; delete temporary folder (if it exists)
	SetWorkingDir, %A_Temp%
	IfExist, Unzip
		FileRemoveDir, Unzip, 1

	; set temporary unzip folder
	ExtractDir := A_Temp . "\Unzip"

	SetWorkingDir, %A_ScriptDir%

	ExternalZipPathFile := Chr(34) . ZipPathFile . Chr(34)
	ExternalExtractDir := Chr(34) . ExtractDir . Chr(34)

	IfNotExist, 7za.exe
	{
		TempString:=GetLang(101)
		MsgBox, %TempString%  ; File missing in InKey folder. Please reinstall InKey.
		errorcheck = 1
		return errorcheck
	}

	RunWait, 7za.exe x -y -o%ExternalExtractDir% %ExternalZipPathFile%,,hide

	StringReplace, ZipPathFile, ZipPathFile, `",, All ; remove "s
	StringReplace, ZipPathFile, ZipPathFile, .zip ; remove .zip at end
	StringReplace, ZipPathFile, ZipPathFile, .inkey ; remove .inkey at end
	StringGetPos, pos, ZipPathFile, \, R ; find position of last \
	length := StrLen(ZipPathFile)
	StringRight, NewFolder, ZipPathFile, % length-pos-1 ; get foldername%

	IfExist, %NewFolder%
	{
		; keyboard already installed, so need to check whether there are custom user settings
		; load all settings from existing .kbd.ini file(s)
		updatingkeyboard = true
		inichanges = false

		Loop, %NewFolder%\*.kbd.ini
		{
			; store enabled settings of current keyboards
			IniRead, KeyboardEnabled%A_Index%, %NewFolder%\%A_LoopFileName%, Keyboard, Enabled

			IniRead, ExistingLayoutName, %NewFolder%\%A_LoopFileName%, Keyboard, LayoutName
			IniRead, NewLayoutName, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, LayoutName
			If ((ExistingLayoutName != NewLayoutName) and (NewLayoutName != "ERROR") and (ExistingLayoutName != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingLayoutName=%ExistingLayoutName%, NewLayoutName=%NewLayoutName%, %inichanges%

			IniRead, ExistingMenuText, %NewFolder%\%A_LoopFileName%, Keyboard, MenuText
			IniRead, NewMenuText, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, MenuText
			If ((ExistingMenuText != NewMenuText) and (NewMenuText != "ERROR") and (ExistingMenuText != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingMenuText=%ExistingMenuText%, NewMenuText=%NewMenuText%, %inichanges%

			IniRead, ExistingHotkey, %NewFolder%\%A_LoopFileName%, Keyboard, Hotkey
			IniRead, NewHotkey, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Hotkey
			If ((ExistingHotkey != NewHotkey) and (NewHotKey != "ERROR") and (ExistingHotkey != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingHotkey=%ExistingHotkey%, NewHotkey=%NewHotkey%, %inichanges%

			IniRead, ExistingLang, %NewFolder%\%A_LoopFileName%, Keyboard, Lang
			IniRead, NewLang, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Lang
			If ((ExistingLang != NewLang) and (NewLang != "ERROR") and (ExistingLang != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingLang=%ExistingLang%, NewLang=%NewLang%, %inichanges%

			IniRead, ExistingAltLang, %NewFolder%\%A_LoopFileName%, Keyboard, AltLang
			IniRead, NewAltLang, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, AltLang
			If ((ExistingAltLang != NewAltLang) and (NewAltLang != "ERROR") and (ExistingAltLang != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingAltLang=%ExistingAltLang%, NewAltLang=%NewAltLang%, %inichanges%

			IniRead, ExistingIcon, %NewFolder%\%A_LoopFileName%, Keyboard, Icon
			IniRead, NewIcon, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Icon
			If ((ExistingIcon != NewIcon) and (NewIcon != "ERROR") and (ExistingIcon != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingIcon=%ExistingIcon%, NewIcon=%NewIcon%, %inichanges%

			IniRead, ExistingParams, %NewFolder%\%A_LoopFileName%, Keyboard, Params
			IniRead, NewParams, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Params
			If ((ExistingParams != NewParams) and (NewParams != "ERROR") and (ExistingParams != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingParams=%ExistingParams%, NewParams=%NewParams%, %inichanges%

			IniRead, ExistingConfigureGUI, %NewFolder%\%A_LoopFileName%, Keyboard, ConfigureGUI
			IniRead, NewConfigureGUI, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, ConfigureGUI
			If ((ExistingConfigureGUI != NewConfigureGUI) and (ExistingConfigureGUI != "ERROR") and (NewConfigureGUI != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingConfigureGUI=%ExistingConfigureGUI%, NewConfigureGUI=%NewConfigureGUI%, %inichanges%

			IniRead, ExistingDisplayCmd, %NewFolder%\%A_LoopFileName%, Keyboard, DisplayCmd
			IniRead, NewDisplayCmd, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, DisplayCmd
			If ((ExistingDisplayCmd != NewDisplayCmd) and (ExistingDisplayCmd != "ERROR") and (NewDisplayCmd != "ERROR"))
			{
				inichanges = true
			}
			outputdebug ExistingDisplayCmd=%ExistingDisplayCmd%, NewDisplayCmd=%NewDisplayCmd%, %inichanges%
		}

		if inichanges = true
		{
			TempString:=GetLang(102) . "`n`n" . GetLang(103) ; A keyboard with that name already exists, and there are differences between the existing keyboard settings and the settings of the keyboard you are attempting to update.`n`nDo you want to keep your custom keyboard settings?
			MsgBox, 8244, InKey, %TempString%  ; 4+48+8192
			IfMsgBox Yes
				{
					; overwrite settings in .kbd.ini files in Unzip directory
					Loop, %NewFolder%\*.kbd.ini
					{
						IniRead, ExistingLayoutName, %NewFolder%\%A_LoopFileName%, Keyboard, LayoutName
						If ((ExistingLayoutName != "") and (ExistingLayoutName != "ERROR"))
							IniWrite, %ExistingLayoutName%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, LayoutName

						IniRead, ExistingMenuText, %NewFolder%\%A_LoopFileName%, Keyboard, MenuText
						If ((ExistingMenuText != "") and (ExistingMenuText != "ERROR"))
							IniWrite, %ExistingMenuText%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, MenuText

						IniRead, ExistingHotkey, %NewFolder%\%A_LoopFileName%, Keyboard, Hotkey
						If ((ExistingHotkey != "") and (ExistingHotkey != "ERROR"))
							IniWrite, %ExistingHotkey%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Hotkey

						IniRead, ExistingLang, %NewFolder%\%A_LoopFileName%, Keyboard, Lang
						If ((ExistingLang != "") and (ExistingLang != "ERROR"))
							IniWrite, %ExistingLang%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Lang

						IniRead, ExistingAltLang, %NewFolder%\%A_LoopFileName%, Keyboard, AltLang
						If ((ExistingAltLang != "") and (ExistingAltLang != "ERROR"))
							IniWrite, %ExistingAltLang%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, AltLang

						IniRead, ExistingIcon, %NewFolder%\%A_LoopFileName%, Keyboard, Icon
						If ((ExistingIcon != "") and (ExistingIcon != "ERROR"))
							IniWrite, %ExistingIcon%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Icon

						IniRead, ExistingParams, %NewFolder%\%A_LoopFileName%, Keyboard, Params
						IniRead, NewParams, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Params
						; it is possible that new parameters have been added to the keyboard.
						; therefore, need to go through and identify new parameters and add them to the existing ones.
						Loop, Parse, NewParams, %A_Space%
						{
							StringSplit, TempParam, A_LoopField, =
							IfNotInString, ExistingParams, %TempParam1%
								ExistingParams := ExistingParams . " " . A_LoopField
						}
						If ((ExistingParams != "") and (ExistingParams != "ERROR"))
							IniWrite, %ExistingParams%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, Params

						IniRead, ExistingConfigureGUI, %NewFolder%\%A_LoopFileName%, Keyboard, ConfigureGUI
						If ((ExistingConfigureGUI != "") and (ExistingConfigureGUI != "ERROR"))
							IniWrite, %ExistingConfigureGUI%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, ConfigureGUI

						IniRead, ExistingDisplayCmd, %NewFolder%\%A_LoopFileName%, Keyboard, DisplayCmd
						If ((ExistingDisplayCmd != "") and (ExistingDisplayCmd != "ERROR"))
							IniWrite, %ExistingDisplayCmd%, %ExtractDir%\%NewFolder%\%A_LoopFileName%, Keyboard, DisplayCmd
					}

					; now copy all files into existing keyboard folder
					KeyboardDir := A_Temp . "\Unzip\" . NewFolder
					DestinationDir := A_ScriptDir . "\" . NewFolder
					FileCopy, %KeyboardDir%\*.*, %DestinationDir%, 1
					If ErrorLevel
					{
						TempString:=GetLang(104)
						MsgBox %TempString% ; There was a problem with copying files to the InKey folder!
						; delete temp folder
						SetWorkingDir, %A_Temp%
						FileRemoveDir, Unzip, 1
						SetWorkingDir, %A_ScriptDir%
						errorcheck = 2
						return errorcheck
					}
				}
			else
				{
					; just copy everything to keyboard folder
					KeyboardDir := A_Temp . "\Unzip\" . NewFolder
					DestinationDir := A_ScriptDir . "\" . NewFolder
					FileCopy, %KeyboardDir%\*.*, %DestinationDir%, 1
					If ErrorLevel
					{
						TempString:=GetLang(104)
						MsgBox %TempString% ; There was a problem with copying files to the InKey folder!
						; delete temp folder
						SetWorkingDir, %A_Temp%
						FileRemoveDir, Unzip, 1
						SetWorkingDir, %A_ScriptDir%
						errorcheck = 3
						return errorcheck
					}
				}
		}
		else
		{
			; just copy everything to keyboard folder
			KeyboardDir := A_Temp . "\Unzip\" . NewFolder
			DestinationDir := A_ScriptDir . "\" . NewFolder
			FileCopy, %KeyboardDir%\*.*, %DestinationDir%, 1
			If ErrorLevel
			{
				TempString:=GetLang(104)
				MsgBox %TempString% ; There was a problem with copying files to the InKey folder!
				; delete temp folder
				SetWorkingDir, %A_Temp%
				FileRemoveDir, Unzip, 1
				SetWorkingDir, %A_ScriptDir%
				errorcheck = 4
				return errorcheck
			}
		}
	}
	else
	{
		; copy new folder from temp to InKey folder
		KeyboardDir := A_Temp . "\Unzip\" . NewFolder
		DestinationDir := A_ScriptDir . "\" . NewFolder
		FileCopyDir, %KeyboardDir%, %DestinationDir%, 1
		If ErrorLevel
		{
			TempString:=GetLang(104)
			MsgBox %TempString% ; There was a problem with copying files to the InKey folder!
			; delete temp folder
			SetWorkingDir, %A_Temp%
			FileRemoveDir, Unzip, 1
			SetWorkingDir, %A_ScriptDir%
			errorcheck = 5
			return errorcheck
		}
	}

	; delete temp folder
	SetWorkingDir, %A_Temp%
	FileRemoveDir, Unzip, 1
	SetWorkingDir, %A_ScriptDir%

	if updatingkeyboard = false
	{
		; enable newly installed keyboard
		Loop, %NewFolder%\*.kbd.ini
		{
			IniWrite, 1, %NewFolder%\%A_LoopFileName%, Keyboard, Enabled ; enable all keyboards
		}
	}
	else
	{
		; reapply previous enabled settings to keyboards - NOTE this will not work if the number of keyboards contained in the keyboard folder has been changed!
		Loop, %NewFolder%\*.kbd.ini
		{
			oldsetting := KeyboardEnabled%A_Index%
			IniWrite, %oldsetting%, %NewFolder%\%A_LoopFileName%, Keyboard, Enabled
		}
	}
	return errorcheck
}