#Warn All, OutputDebug
t := "𝄞"
;~ t := "*"
SetFormat integerfast, H
MsgBox % ord(t)
return

Ord(str) {
; Use this instead of AHK's Asc() function if you need to handle SMP characters too.
	if (str = "")
		return 0
	o := Asc(Substr(str,1,1))
	if (o & 0xd800 = 0xd800) {  ; if SMP
		o2 := Asc(Substr(str, 2, 1))
		return (((o & 0x3ff) << 10) | (o2 & 0x3ff)) + 0x10000
	}
	return Asc(str)
}


dumpStr(byref str, byref txt, len=-1, max=0)
{
	if (len=-1)
		len := strlen(str)
	start := 0
	s := "  ["
	if (max>0 and len>max) {
		start := len - max
		s := "..."
	}

	setformat integerfast, H

	Loop % len - start
	{
		v := numGet(str,2*(A_Index - 1 + start), "UShort")
		if (v<32 or v>254)
			s .= "<" substr(v,3) ">"
		else
			s .= chr(v)
	}
	s .= "]"
	setformat integerfast, D
	OutputDebug %txt% %s%
}
