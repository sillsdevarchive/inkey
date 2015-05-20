base := "c:\inkeyhg\inkeylive"
; siteKbds := "C:\Users\Dan\Documents\InKey\site\keyboard"
files := "C:\Users\Dan\Documents\InKey\site\files"

excludeFromPkg := "InKey.ini|readme.md"

SetWorkingDir %base%

updates := 0
updatedPkgs := ""
Loop Files, *.*, D
{
	if (InStr(A_LoopFileName, "."))
		continue    ; skip folders that contain a dot

	generateInKeyPkg(A_LoopFileName)
}
msgbox %updates% keyboard package(s) updated:`r`n%updatedPkgs%
exitApp



generateInKeyPkg(kbdFolder) {
	global

	; IfNotExist %siteKbds%\%kbdFolder%
	; {
		; outputdebug WARNING: %kbdFolder% does not yet exist in %siteKbds%. Skipping.
		; return
	; }
	; files := siteKbds "\" kbdFolder "\files"


	; First find the latest existing package
	latestZipTime := 0
	latestZipFile := ""
	Loop Files, %files%\%kbdFolder%_*.inkey, F
	{
		FileGetTime thisTime
		if (thisTime > latestZipTime) {
			latestZipTime := thisTime
			latestZipFile := A_LoopFileName
		}
	}

	; Now find the most recent file that would go in the package
	latestKbdTime := 0
	latestKbdFile := ""
	foundTinker := 0
	kbdFiles := object()
	Loop Files, %kbdFolder%\*.*, F
	{
		if (InStr(excludeFromPkg, A_LoopFileName))
			continue
		if (A_LoopFileExt = "tinker")
			foundTinker := 1
		kbdFiles.Insert(A_LoopFileName)
		FileGetTime thisTime
		if (thisTime > latestKbdTime) {
			latestKbdTime := thisTime
			latestKbdFile := A_LoopFileName
		}
		; outputdebug %A_LoopFileName% %thisTime%
	}
	if (not foundTinker) {
		outputdebug %kbdFolder% is not a tinker keyboard. Skipping.
		return
	}

	if (latestKbdTime > latestZipTime) {
		; We need to build a package
		FileCreateDir %files%

		FormatTime, pkgName, %latestKbdTime%, yyyy-MM-dd
		pkgName := files "\" kbdFolder "_" pkgName ".inkey"
		outputdebug creating %pkgName%
		tempKbdDir := A_Temp "\inkeybuild\" kbdFolder
		ifExist %tempKbdDir%
			FileRemoveDir %tempKbdDir%, 1
		FileCreateDir %tempKbdDir%
		for index, thisFile in kbdFiles
		{
			FileCopy %kbdFolder%\%thisFile%, %tempKbdDir%, 1
		}

		RunWait 7za.exe a -tzip %pkgName% %tempKbdDir% -mx9,,hide
		; FileRemoveDir %tempKbdDir%, 1
		updates += 1
		updatedPkgs .= chr(9) kbdFolder chr(13) chr(10)

	} else {
		outputdebug %latestZipFile% is up-to-date
	}

}