; Section of code relating to the Internationalisation of the Interface

GetLang(number) {
	ReturnString:=""
	IniRead ReturnString, Lang.ini, %number%, Vernacular
	if (ReturnString = "") {
		IniRead ReturnString, Lang.ini, %number%, Original
	}
	return ReturnString
}