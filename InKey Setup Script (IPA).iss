; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4D237339-E37B-4606-9E9D-68478AD8C943}
AppName=InKey
AppVerName=InKey 1.9.53
VersionInfoVersion=1.9.53
AppPublisher=InKey Software
AppPublisherURL=http://www.inkeysoftware.com/
AppSupportURL=http://www.inkeysoftware.com/
AppUpdatesURL=http://www.inkeysoftware.com/

; Select destination directory depending on Windows version
DefaultDirName={reg:HKCU\Software\InKey,Path|{code:DirFromVersion}\InKey}

DefaultGroupName=InKey
UninstallDisplayIcon={app}\InKey.exe
AllowNoIcons=yes
LicenseFile=InKey\InKey License.txt
OutputBaseFilename=InKey Setup (IPA)
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes

[Code]
function DirFromVersion(dummy: String): String;
var
winver: TWindowsVersion;
major, minor, build: Cardinal;
begin
// Minimale Versionsnummer, auf die gepru"ft werden soll
major := 6;
minor := 0;
build := 6000;
GetWindowsVersionEx(winver);
if (winver.Major > major) or ((winver.Major = major) and (winver.Minor > minor))
or ((winver.Major = major) and (winver.Minor = minor) and (winver.Build >= build))
then
Result := ExpandConstant('{userappdata}')
else
Result := ExpandConstant('{pf}');
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "InKey\7za.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\7-zip License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\AutoHotKey License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\AutoHotkey.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\InKey License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\InKey.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\InKey.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\InKey.ini"; DestDir: "{app}"; Flags: ignoreversion confirmoverwrite
Source: "InKey\InKeyKeyboardInstaller.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\InKeyLib.ahki"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\Lang.ini"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\RegistrationKey.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\UnregisterKbds.ahk"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKey\Langs\*"; DestDir: "{app}\Langs"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "InKey\IPA\*"; DestDir: "{app}\IPA"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\InKey"; Filename: "{app}\InKey.exe"
Name: "{commondesktop}\InKey"; Filename: "{app}\InKey.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\InKey"; Filename: "{app}\InKey.exe"; Tasks: quicklaunchicon

[Registry]
Root: HKCU; Subkey: "Software\InKey"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\InKey"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCR; Subkey: ".inkey"; ValueType: string; ValueName: ""; ValueData: "InKeyKeyboardFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "InKeyKeyboardFile"; ValueType: string; ValueName: ""; ValueData: "InKey Keyboard File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "InKeyKeyboardFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\InKeyKeyboardInstaller.exe,0"
Root: HKCR; Subkey: "InKeyKeyboardFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\InKeyKeyboardInstaller.exe"" ""%1"""

[Run]
Filename: "{app}\InKey.exe"; Description: "{cm:LaunchProgram,InKey}"; Flags: nowait postinstall skipifsilent
