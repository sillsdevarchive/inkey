@srcfiles = ('inkey.ahk', 'Comm.ahk', 'Validate.ahk', 'Config.ahk', 'iSendU.ahk', 'KeyboardConfigure.ahk', 'Lang.ahk', 'cohelper.ahk', 'InKey/Inkeylib.ahki');
foreach $file (@srcfiles) {
	open IN, $file or die;
	open OUT, ">Release/$file" or die;
	while (<IN>) {
		if (/^\s*(outputdebug|showstack|showflags|showbuf)\b/i || /\/\/\s*DEBUG/) {
			print OUT ";$_";
		} else {
			s/\; DEBUG>>/\/*/;
			s/\; <<DEBUG/*\//;
			print OUT;
		}
	}
}