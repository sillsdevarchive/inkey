#SingleInstance force

#space::
IniRead LicenseStmt, RegistrationKey2.txt, InKey, LicenseStmt, %A_Space%
ToolTip iniread read the following string:`n%LicenseStmt%
