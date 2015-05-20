; These two lines need to be customized for each keyboard
#define KbdName "mlym-Mozhi"
#define customIni FileExists("InKeyLive\mlym-Mozhi\InKey.ini")

#define InKeyVer GetFileVersion("InKeyLive\InKey.exe")

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{4D237339-E37B-4606-9E9D-68478AD8C943}
AppName=InKey
AppVerName=InKey version {#InKeyVer}
VersionInfoVersion={#InKeyVer}
AppPublisher=InKey Software
AppPublisherURL=http://www.inkeysoftware.com/
AppSupportURL=http://www.inkeysoftware.com/
AppUpdatesURL=http://www.inkeysoftware.com/
OutputDir=site\keyboard\{#KbdName}\files
DefaultDirName={pf}\InKey
DefaultGroupName=InKey
UninstallDisplayIcon={app}\InKey.exe
AllowNoIcons=yes
LicenseFile=InKeyLive\InKey License.txt
OutputBaseFilename=SetupInKey-{#InKeyVer}-({#KbdName})
Compression=lzma
SolidCompression=yes
ChangesAssociations=yes
;UsePreviousAppDir=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "InKeyLive\7za.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\7-zip License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\AutoHotKey License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\AutoHotkey.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\InKey License.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\InKey.chm"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\InKey.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\InKeyKeyboardInstaller.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\InKeyLib.ahki"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\StoreUserSettingsInAppData.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\UnregisterKbds.ahk"; DestDir: "{app}"; Flags: ignoreversion
Source: "InKeyLive\.Langs\*.ini"; DestDir: "{app}\.Langs"; Flags: ignoreversion
Source: "InKeyLive\{#KbdName}\*"; Excludes: "inkey.ini,.git,.git*,*.md"; DestDir: "{app}\{#KbdName}"; Flags: ignoreversion
#if customIni
Source: "InKeyLive\{#KbdName}\InKey.ini"; DestDir: "{app}"; Flags: ignoreversion
#else
Source: "InKeyLive\InKey.ini"; DestDir: "{app}"; Flags: ignoreversion
#endif


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
