; Section of code relating to the Internationalisation of the Interface

GetLang(number) {
	global GUILang
	ReturnString:=""
	IniRead ReturnString, .Langs\%GUILang%.ini, %number%, Vernacular
	if (ReturnString = "") {
		IniRead ReturnString, .Langs\en.ini, %number%, Original
	}
	return ReturnString
}