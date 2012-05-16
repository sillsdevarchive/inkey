/*	InKey script to provide a keyboard layout for Greek NT Unicode

	Keyboard:	Greek NT Unicode
	Version:    1.0 BETA
	Author:     Ben Chenoweth
	Official Distribution: http://inkeysoftware.com

*/

;________________________________________________________________________________________________________________
; This section is required at the top of every InKey keyboard script:

K_MinimumInKeyLibVersion = 0.092
	  ; The version number of the InKeyLib.ahki file that the keyboard developer used while writing this script.
	  ; It can be found near the top of the InKeyLib.ahki file.
	  ; It may be lower than the InKey version number.
	  ; If a user has an older version of InKeyLib.ahki, he will need to update it in order to use this keyboard script.
	  ; This protects your script from crashing from attempting to use functionality not present in older versions of InKeyLib.ahki.

K_UseContext = 1  ; Causes uncaptured character keys to be included in the context too.

#include InKeyLib.ahki
;________________________________________________________________________________________________________________


OnLoadScript:

RegisterRota(1, "σ ς", 0x3C3, 0, 0, 8)  ;| σ ς

; set up arrays for VOWEL ALTERNATION
InChars=0x03b5,0x1f10,0x1f11,0x1f72,0x1f73,0x1f12,0x1f13,0x1f14,0x1f15,0x395,0x1f18,0x1f19,0x1fc8,0x1fc9,0x1f1a,0x1f1b,0x1f1c,0x1f1d,0x3bf,0x1f40,0x1f41,0x1f78,0x1f79,0x1f42,0x1f43,0x1f44,0x1f45,0x39f,0x1f48,0x1f49,0x1ff8,0x1ff9,0x1f4a,0x1f4b,0x1f4c,0x1f4d,0x03b7,0x1f20,0x1f21,0x1f74,0x1f75,0x1f22,0x1f23,0x1f24,0x1f25,0x397,0x1f28,0x1f29,0x1fca,0x1fcb,0x1f2a,0x1f2b,0x1f2c,0x1f2d,0x3c9,0x1f60,0x1f61,0x1f7c,0x1f7d,0x1f62,0x1f63,0x1f64,0x1f65,0x3a9,0x1f68,0x1f69,0x1ffa,0x1ffb,0x1f6a,0x1f6b,0x1f6c,0x1f6d ; εἐἑὲέἒἓἔἕΕἘἙῈΈἚἛἜἝοὀὁὸόὂὃὄὅΟὈὉῸΌὊὋὌὍηἠἡὴήἢἣἤἥΗἨἩῊΉἪἫἬἭωὠὡὼώὢὣὤὥΩὨὩῺΏὪὫὬὭ
StringSplit, InVowelAlternation, InChars, `,
OutChars=0x03B7,0x1F20,0x1F21,0x1F74,0x1F75,0x1F22,0x1F23,0x1F24,0x1F25,0x397,0x1F28,0x1F29,0x1FCA,0x1FCB,0x1F2A,0x1F2B,0x1F2C,0x1F2D,0x3C9,0x1F60,0x1F61,0x1F7C,0x1F7D,0x1F62,0x1F63,0x1F64,0x1F65,0x3A9,0x1F68,0x1F69,0x1FFA,0x1FFB,0x1F6A,0x1F6B,0x1F6C,0x1F6D,0x03B5,0x1F10,0x1F11,0x1F72,0x1F73,0x1F12,0x1F13,0x1F14,0x1F15,0x395,0x1F18,0x1F19,0x1FC8,0x1FC9,0x1F1A,0x1F1B,0x1F1C,0x1F1D,0x3BF,0x1F40,0x1F41,0x1F78,0x1F79,0x1F42,0x1F43,0x1F44,0x1F45,0x39F,0x1F48,0x1F49,0x1FF8,0x1FF9,0x1F4A,0x1F4B,0x1F4C,0x1F4D ; ηἠἡὴήἢἣἤἥΗἨἩῊΉἪἫἬἭωὠὡὼώὢὣὤὥΩὨὩῺΏὪὫὬὭεἐἑὲέἒἓἔἕΕἘἙῈΈἚἛἜἝοὀὁὸόὂὃὄὅΟὈὉῸΌὊὋὌὍ
StringSplit, OutVowelAlternation, OutChars, `,

; set up arrays for adding SMOOTH BREATHING
InChars=0x3b1,0x1f70,0x1f71,0x1fb6,0x1fb2,0x1fb4,0x1fb7,0x391,0x1fba,0x1fbb,0x3b5,0x1f72,0x1f73,0x395,0x1fc8,0x1fc9,0x3b7,0x1f74,0x1f75,0x1fc6,0x1fc2,0x1fc4,0x1fc7,0x397,0x1fca,0x1fcb,0x3b9,0x1f76,0x1f77,0x1fd6,0x399,0x1fda,0x1fdb,0x3bf,0x1f78,0x1f79,0x39f,0x1ff8,0x1ff9,0x3c5,0x1f7a,0x1f7b,0x1fe6,0x3c9,0x1f7c,0x1f7d,0x1ff6,0x1ff2,0x1ff4,0x1ff7,0x3a9,0x1ffa,0x1ffb,0x3c1 ; αὰάᾶᾲᾴᾷΑᾺΆεὲέΕῈΈηὴήῆῂῄῇΗῊΉιὶίῖΙῚΊοὸόΟῸΌυὺύῦωὼώῶῲῴῷΩῺΏρ
StringSplit, InSmoothBreathing, InChars, `,
OutChars=0x1F00,0x1F02,0x1F04,0x1F06,0x1F82,0x1F84,0x1F86,0x1F08,0x1F0A,0x1F0C,0x1F10,0x1F12,0x1F14,0x1F18,0x1F1A,0x1F1C,0x1F20,0x1F22,0x1F24,0x1F26,0x1F92,0x1F94,0x1F96,0x1F28,0x1F2A,0x1F2C,0x1F30,0x1F32,0x1F34,0x1F36,0x1F38,0x1F3A,0x1F3C,0x1F40,0x1F42,0x1F44,0x1F48,0x1F4A,0x1F4C,0x1F50,0x1F52,0x1F54,0x1F56,0x1F60,0x1F62,0x1F64,0x1F66,0x1FA2,0x1FA4,0x1FA6,0x1F68,0x1F6A,0x1F6C,0x1FE4 ; ἀἂἄἆᾂᾄᾆἈἊἌἐἒἔἘἚἜἠἢἤἦᾒᾔᾖἨἪἬἰἲἴἶἸἺἼὀὂὄὈὊὌὐὒὔὖὠὢὤὦᾢᾤᾦὨὪὬῤ
StringSplit, OutSmoothBreathing, OutChars, `,

; set up arrays for adding ROUGH BREATHING
InChars=0x3b1,0x1f70,0x1f71,0x1fb6,0x1fb2,0x1fb4,0x1fb7,0x391,0x1fba,0x1fbb,0x3b5,0x1f72,0x1f73,0x395,0x1fc8,0x1fc9,0x3b7,0x1f74,0x1f75,0x1fc6,0x1fc2,0x1fc4,0x1fc7,0x397,0x1fca,0x1fcb,0x3b9,0x1f76,0x1f77,0x1fd6,0x399,0x1fda,0x1fdb,0x3bf,0x1f78,0x1f79,0x39f,0x1ff8,0x1ff9,0x3c5,0x1f7a,0x1f7b,0x1fe6,0x3a5,0x1fea,0x1feb,0x3c9,0x1f7c,0x1f7d,0x1ff6,0x1ff2,0x1ff4,0x1ff7,0x3a9,0x1ffa,0x1ffb,0x3c1,0x3a1 ; αὰάᾶᾲᾴᾷΑᾺΆεὲέΕῈΈηὴήῆῂῄῇΗῊΉιὶίῖΙῚΊοὸόΟῸΌυὺύῦΥῪΎωὼώῶῲῴῷΩῺΏρΡ
StringSplit, InRoughBreathing, InChars, `,
OutChars=0x1F01,0x1F03,0x1F05,0x1F07,0x1F83,0x1F85,0x1F87,0x1F09,0x1F0B,0x1F0D,0x1F11,0x1F13,0x1F15,0x1F19,0x1F1B,0x1F1D,0x1F21,0x1F23,0x1F25,0x1F27,0x1F93,0x1F95,0x1F97,0x1F29,0x1F2B,0x1F2D,0x1F31,0x1F33,0x1F35,0x1F37,0x1F39,0x1F3B,0x1F3D,0x1F41,0x1F43,0x1F45,0x1F49,0x1F4B,0x1F4D,0x1F51,0x1F53,0x1F55,0x1F57,0x1F59,0x1F5B,0x1F5D,0x1F61,0x1F63,0x1F65,0x1F67,0x1FA3,0x1FA5,0x1FA7,0x1F69,0x1F6B,0x1F6D,0x1FE5,0x1FEC ; ἁἃἅἇᾃᾅᾇἉἋἍἑἓἕἙἛἝἡἣἥἧᾓᾕᾗἩἫἭἱἳἵἷἹἻἽὁὃὅὉὋὍὑὓὕὗὙὛὝὡὣὥὧᾣᾥᾧὩὫὭῥῬ
StringSplit, OutRoughBreathing, OutChars, `,

; set up arrays for adding YPOGEGRAMMENI
InChars=0x3b1,0x1fb6,0x1f70,0x1f71,0x391,0x1f00,0x1f01,0x1f02,0x1f03,0x1f04,0x1f05,0x1f06,0x1f07,0x1f08,0x1f09,0x1f0a,0x1f0b,0x1f0c,0x1f0d,0x1f0e,0x1f0f,0x3b7,0x1fc6,0x1f74,0x1f75,0x397,0x1f20,0x1f21,0x1f22,0x1f23,0x1f24,0x1f25,0x1f26,0x1f27,0x1f28,0x1f29,0x1f2a,0x1f2b,0x1f2c,0x1f2d,0x1f2e,0x1f2f,0x3c9,0x1ff6,0x1f7c,0x1f7d,0x3a9,0x1f60,0x1f61,0x1f62,0x1f63,0x1f64,0x1f65,0x1f66,0x1f67,0x1f68,0x1f69,0x1f6a,0x1f6b,0x1f6c,0x1f6d,0x1f6e,0x1f6f ; αᾶὰάΑἀἁἂἃἄἅἆἇἈἉἊἋἌἍἎἏηῆὴήΗἠἡἢἣἤἥἦἧἨἩἪἫἬἭἮἯωῶὼώΩὠὡὢὣὤὥὦὧὨὩὪὫὬὭὮὯ
StringSplit, InYpogegrammeni, InChars, `,
OutChars=0x1FB3,0x1FB7,0x1FB2,0x1FB4,0x1FBC,0x1F80,0x1F81,0x1F82,0x1F83,0x1F84,0x1F85,0x1F86,0x1F87,0x1F88,0x1F89,0x1F8A,0x1F8B,0x1F8C,0x1F8D,0x1F8E,0x1F8F,0x1FC3,0x1FC7,0x1FC2,0x1FC4,0x1FCC,0x1F90,0x1F91,0x1F92,0x1F93,0x1F94,0x1F95,0x1F96,0x1F97,0x1F98,0x1F99,0x1F9A,0x1F9B,0x1F9C,0x1F9D,0x1F9E,0x1F9F,0x1FF3,0x1FF7,0x1FF2,0x1FF4,0x1FFC,0x1FA0,0x1FA1,0x1FA2,0x1FA3,0x1FA4,0x1FA5,0x1FA6,0x1FA7,0x1FA8,0x1FA9,0x1FAA,0x1FAB,0x1FAC,0x1FAD,0x1FAE,0x1FAF ; ᾳᾷᾲᾴᾼᾀᾁᾂᾃᾄᾅᾆᾇᾈᾉᾊᾋᾌᾍᾎᾏῃῇῂῄῌᾐᾑᾒᾓᾔᾕᾖᾗᾘᾙᾚᾛᾜᾝᾞᾟῳῷῲῴῼᾠᾡᾢᾣᾤᾥᾦᾧᾨᾩᾪᾫᾬᾭᾮᾯ
StringSplit, OutYpogegrammeni, OutChars, `,

; set up arrays for adding VARIA
InChars=0x3b1,0x3b5,0x3b7,0x3b9,0x3bf,0x3c5,0x3c9,0x391,0x395,0x397,0x399,0x39f,0x3a5,0x3a9,0x1f00,0x1f01,0x1f10,0x1f11,0x1f20,0x1f21,0x1f30,0x1f31,0x1f40,0x1f41,0x1f50,0x1f51,0x1f60,0x1f61,0x1f08,0x1f09,0x1f18,0x1f19,0x1f28,0x1f29,0x1f38,0x1f39,0x1f48,0x1f49,0x1f59,0x1f68,0x1f69,0x1fb3,0x1fc3,0x1ff3,0x1f80,0x1f81,0x1f90,0x1f91,0x1fa0,0x1fa1,0x1f88,0x1f89,0x1f98,0x1f99,0x1fa8,0x1fa9,0x3ca,0x3cb ; αεηιουωΑΕΗΙΟΥΩἀἁἐἑἠἡἰἱὀὁὐὑὠὡἈἉἘἙἨἩἸἹὈὉὙὨὩᾳῃῳᾀᾁᾐᾑᾠᾡᾈᾉᾘᾙᾨᾩϊϋ
StringSplit, InVaria, InChars, `,
OutChars=0x1F70,0x1F72,0x1F74,0x1F76,0x1F78,0x1F7A,0x1F7C,0x1FBA,0x1FC8,0x1FCA,0x1FDA,0x1FF8,0x1FEA,0x1FFA,0x1F02,0x1F03,0x1F12,0x1F13,0x1F22,0x1F23,0x1F32,0x1F33,0x1F42,0x1F43,0x1F52,0x1F53,0x1F62,0x1F63,0x1F0A,0x1F0B,0x1F1A,0x1F1B,0x1F2A,0x1F2B,0x1F3A,0x1F3B,0x1F4A,0x1F4B,0x1F5B,0x1F6A,0x1F6B,0x1FB2,0x1FC2,0x1FF2,0x1F82,0x1F83,0x1F92,0x1F93,0x1FA2,0x1FA3,0x1F8A,0x1F8B,0x1F9A,0x1F9B,0x1FAA,0x1FAB,0x1FD2,0x1FE2 ; ὰὲὴὶὸὺὼᾺῈῊῚῸῪῺἂἃἒἓἢἣἲἳὂὃὒὓὢὣἊἋἚἛἪἫἺἻὊὋὛὪὫᾲῂῲᾂᾃᾒᾓᾢᾣᾊᾋᾚᾛᾪᾫῒῢ
StringSplit, OutVaria, OutChars, `,

; set up arrays for adding PERISPOMENI
InChars=0x03b1,0x1fb3,0x3b7,0x1fc3,0x3b9,0x3ca,0x3c5,0x3cb,0x3c9,0x1ff3,0x1f00,0x1f01,0x1f20,0x1f21,0x1f30,0x1f31,0x1f50,0x1f51,0x1f60,0x1f61,0x1f80,0x1f81,0x1f90,0x1f91,0x1fa0,0x1fa1,0x1f08,0x1f09,0x1f28,0x1f29,0x1f38,0x1f39,0x1f59,0x1f68,0x1f69,0x1f88,0x1f89,0x1f98,0x1f99,0x1fa8,0x1fa9 ; αᾳηῃιϊυϋωῳἀἁἠἡἰἱὐὑὠὡᾀᾁᾐᾑᾠᾡἈἉἨἩἸἹὙὨὩᾈᾉᾘᾙᾨᾩ
StringSplit, InPerispomeni, InChars, `,
OutChars=0x1FB6,0x1FB7,0x1FC6,0x1FC7,0x1FD6,0x1FD7,0x1FE6,0x1FE7,0x1FF6,0x1FF7,0x1F06,0x1F07,0x1F26,0x1F27,0x1F36,0x1F37,0x1F56,0x1F57,0x1F66,0x1F67,0x1F86,0x1F87,0x1F96,0x1F97,0x1FA6,0x1FA7,0x1F0E,0x1F0F,0x1F2E,0x1F2F,0x1F3E,0x1F3F,0x1F5F,0x1F6E,0x1F6F,0x1F8E,0x1F8F,0x1F9E,0x1F9F,0x1FAE,0x1FAF ; ᾶᾷῆῇῖῗῦῧῶῷἆἇἦἧἶἷὖὗὦὧᾆᾇᾖᾗᾦᾧἎἏἮἯἾἿὟὮὯᾎᾏᾞᾟᾮᾯ
StringSplit, OutPerispomeni, OutChars, `,

; set up arrays for adding OXIA
InChars=0x3b1,0x3b5,0x3b7,0x3b9,0x3bf,0x3c5,0x3c9,0x391,0x395,0x397,0x399,0x39f,0x3a5,0x3a9,0x1f00,0x1f01,0x1f10,0x1f11,0x1f20,0x1f21,0x1f30,0x1f31,0x1f40,0x1f41,0x1f50,0x1f51,0x1f60,0x1f61,0x1f08,0x1f09,0x1f18,0x1f19,0x1f28,0x1f29,0x1f38,0x1f39,0x1f48,0x1f49,0x1f59,0x1f68,0x1f69,0x1fb3,0x1fc3,0x1ff3,0x1f80,0x1f81,0x1f90,0x1f91,0x1fa0,0x1fa1,0x1f88,0x1f89,0x1f98,0x1f99,0x1fa8,0x1fa9,0x3ca,0x3cb ; αεηιουωΑΕΗΙΟΥΩἀἁἐἑἠἡἰἱὀὁὐὑὠὡἈἉἘἙἨἩἸἹὈὉὙὨὩᾳῃῳᾀᾁᾐᾑᾠᾡᾈᾉᾘᾙᾨᾩϊϋ
StringSplit, InOxia, InChars, `,
OutChars=0x1F71,0x1F73,0x1F75,0x1F77,0x1F79,0x1F7B,0x1F7D,0x1FBB,0x1FC9,0x1FCB,0x1FDB,0x1FF9,0x1FEB,0x1FFB,0x1F04,0x1F05,0x1F14,0x1F15,0x1F24,0x1F25,0x1F34,0x1F35,0x1F44,0x1F45,0x1F54,0x1F55,0x1F64,0x1F65,0x1F0C,0x1F0D,0x1F1C,0x1F1D,0x1F2C,0x1F2D,0x1F3C,0x1F3D,0x1F4C,0x1F4D,0x1F5D,0x1F6C,0x1F6D,0x1FB4,0x1FC4,0x1FF4,0x1F84,0x1F85,0x1F94,0x1F95,0x1FA4,0x1FA5,0x1F8C,0x1F8D,0x1F9C,0x1F9D,0x1FAC,0x1FAD,0x1FD3,0x1FE3 ; άέήίόύώΆΈΉΊΌΎΏἄἅἔἕἤἥἴἵὄὅὔὕὤὥἌἍἜἝἬἭἼἽὌὍὝὬὭᾴῄῴᾄᾅᾔᾕᾤᾥᾌᾍᾜᾝᾬᾭΐΰ
StringSplit, OutOxia, OutChars, `,

; set up arrays for removing OXIA
InChars=0x1f71,0x1f73,0x1f75,0x1f77,0x1f79,0x1f7b,0x1f7d,0x1fbb,0x1fc9,0x1fcb,0x1fdb,0x1ff9,0x1feb,0x1ffb,0x1f04,0x1f05,0x1f14,0x1f15,0x1f24,0x1f25,0x1f34,0x1f35,0x1f44,0x1f45,0x1f54,0x1f55,0x1f64,0x1f65,0x1f0c,0x1f0d,0x1f1c,0x1f1d,0x1f2c,0x1f2d,0x1f3c,0x1f3d,0x1f4c,0x1f4d,0x1f5d,0x1f6c,0x1f6d,0x1fb4,0x1fc4,0x1ff4,0x1f84,0x1f85,0x1f94,0x1f95,0x1fa4,0x1fa5,0x1f8c,0x1f8d,0x1f9c,0x1f9d,0x1fac,0x1fad,0x1fd3,0x1fe3 ; άέήίόύώΆΈΉΊΌΎΏἄἅἔἕἤἥἴἵὄὅὔὕὤὥἌἍἜἝἬἭἼἽὌὍὝὬὭᾴῄῴᾄᾅᾔᾕᾤᾥᾌᾍᾜᾝᾬᾭΐΰ
StringSplit, InRemoveOxia, InChars, `,
OutChars=0x3B1,0x3B5,0x3B7,0x3B9,0x3BF,0x3C5,0x3C9,0x391,0x395,0x397,0x399,0x39F,0x3A5,0x3A9,0x1F00,0x1F01,0x1F10,0x1F11,0x1F20,0x1F21,0x1F30,0x1F31,0x1F40,0x1F41,0x1F50,0x1F51,0x1F60,0x1F61,0x1F08,0x1F09,0x1F18,0x1F19,0x1F28,0x1F29,0x1F38,0x1F39,0x1F48,0x1F49,0x1F59,0x1F68,0x1F69,0x1FB3,0x1FC3,0x1FF3,0x1F80,0x1F81,0x1F90,0x1F91,0x1FA0,0x1FA1,0x1F88,0x1F89,0x1F98,0x1F99,0x1FA8,0x1FA9,0x3CA,0x3CB ; αεηιουωΑΕΗΙΟΥΩἀἁἐἑἠἡἰἱὀὁὐὑὠὡἈἉἘἙἨἩἸἹὈὉὙὨὩᾳῃῳᾀᾁᾐᾑᾠᾡᾈᾉᾘᾙᾨᾩϊϋ
StringSplit, OutRemoveOxia, OutChars, `,
return
;________________________________________________________________________________________________________________

$=::
DoVowelAlternation()
return

$~::
AddPerispomeni()
return

$^::
AddPerispomeni()
return

$@::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x40)
return

$!::
if (ctx() = 0x40)	;| @
	ReplaceChar(0x21)	;| !
else
	AddYpogegrammeni()
return

$`::
AddVaria()
return

$|::
AddYpogegrammeni()
return

$_::
AddYpogegrammeni()
return

$(::
if (ctx() = 0x40)	;| @
	ReplaceChar(0xAB)	;| «
else
	SendChar(0x28)	;| (
return

$)::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
}
if (ctx() = 0x40)	;| @
	{
		if (ctx(2) = 0x3C3)	;| σ
		{
			Back()
			ReplaceChar(0x3C2)	;| ς
		}
		SendChar(0xBB)	;| »
	}
else
	{
		if (ctx() = 0x3C3)	;| σ
		{
			ReplaceChar(0x3C2)	;| ς
		}
		SendChar(0x29)	;| )
	}
return

$*::
if (ctx() = 0x40)	;| @
	ReplaceChar(0x2A)	;| *
else
	Back()
return

$+::
if (ctx() = 0x40)	;| @
	ReplaceChar(0x2B)	;| +
else
	AddYpogegrammeni()
return

$-::
if (ctx() = 0x40)	;| @
	ReplaceChar(0x2013)	;| –
else
	SendChar(0x2D)	;| -
return

$\::
if (ctx() = 0x40)	;| @
{
	SendChar(0x5C)	;| \
}
else
{
	AddVaria()
}
return

$/::
AddOxia()
return

$%:: SendChar(0x5C)  ;| \

$+`;::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
}
if (ctx() = 0x40)	;| @
	{
		if (ctx(2) = 0x3C3)	;| σ
		{
			Back()
			ReplaceChar(0x3C2)	;| ς
		}
		SendChar(0x3A)	;| :
	}
else
	{
		if (ctx() = 0x3C3)	;| σ
		{
			ReplaceChar(0x3C2)	;| ς
		}
		SendChar(0xB7)  ;| ·
	}
return

$>::
if (ctx() = 0x40)	;| @
	SendChar(0x3E)	;| >
else
	AddSmoothBreathingMark()	;| ᾿
return

$<::
if (ctx() = 0x40)	;| @
	SendChar(0x3C)	;| <
else
	AddRoughBreathingMark()	;| ῾
return

$'::
if possibledoublepress = true
{
	UndoOxia()
	SendChar(0x1FBF)	;| ᾿
	possibledoublepress = false
}
else
{
	possibledoublepress = true
	AddOxia()
}
return

$"::
cc := ctx()
if cc = 0x3B9
	ReplaceChar(0x3CA)	;| ϊ
else if cc = 0x1F76
	ReplaceChar(0x1FD2)	;| ῒ
else if cc = 0x1F77
	ReplaceChar(0x1FD3)	;| ΐ
else if cc = 0x1FD6
	ReplaceChar(0x1FD7)	;| ῗ
else if cc = 0x3C5
	ReplaceChar(0x3CB)	;| ϋ
else if cc = 0x1F7A
	ReplaceChar(0x1FE2)	;| ῢ
else if cc = 0x1F7B
	ReplaceChar(0x1FE3)	;| ΰ
else if cc = 0x1FE6
	ReplaceChar(0x1FE7)	;| ῧ
else if cc = 0x399
	ReplaceChar(0x3AA)	;| Ϊ
else if cc = 0x3A5
	ReplaceChar(0x3AB)	;| Ϋ
return

$?::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
}
SendChar(0x3B)  ;| ;
return

$.::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
}
SendChar(0x2E)  ;| .
return

$,::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
}
SendChar(0x2C)  ;| ,
return

$q::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3B8)  ;| θ
possibledoublepress = false
return

$w::
AutoAddSmoothBreathingIfNeeded()
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F61)	;| ὡ
	roughbreathingflag = false
}
else
{
	SendChar(0x3C9)  ;| ω
}
return

$e::
AutoAddSmoothBreathingIfNeeded()
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F11)	;| ἑ
	roughbreathingflag = false
}
else
{
	SendChar(0x3B5)	;| ε
}
return

$r::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3C1)	;| ρ
possibledoublepress = false
return

$t::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3C4)  ;| τ
possibledoublepress = false
return

$y::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3C8)  ;| ψ
possibledoublepress = false
return

$u::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F51)	;| ὑ
	roughbreathingflag = false
}
else
{
	SendChar(0x3C5)  ;| υ
}
return

$i::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F31)	;| ἱ
	roughbreathingflag = false
}
else
{
	SendChar(0x3B9)  ;| ι
}
return

$o::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F41)	;| ὁ
	roughbreathingflag = false
}
else
{
	SendChar(0x3BF)
}
return

$p::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3C0)  ;| π
possibledoublepress = false
return

$a::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F01)	;| ἁ
	roughbreathingflag = false
}
else
{
	SendChar(0x3B1)	;| α
}
return

$s::
AutoAddSmoothBreathingIfNeeded()
if (ctx() = 0x3C0)  ;| π
	ReplaceChar(0x3C8)  ;| ψ
else
	DoRota(1)
possibledoublepress = false
return

$d::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3B4)  ;| δ
possibledoublepress = false
return

$f::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3C6)  ;| φ
possibledoublepress = false
return

$g::
AutoAddSmoothBreathingIfNeeded()
if ((ctx() = 0x3B3) and (ctx(2) = 0x3BD))	;| νγ
{
	Back(2)
	SendChar(0x3B3)
	SendChar(0x3B3)	;| γγ
}
else
	SendChar(0x3B3)  ;| γ
possibledoublepress = false
return

$h::
AutoAddSmoothBreathingIfNeeded()
cc := ctx()
if (cc = 0x3C4)		;| τ
	ReplaceChar(0x3B8)	;| θ
;else if (cc = (0x3C7)	;| χ
;	ReplaceChar(0x3C7)	;| χ
else if (cc = 0x3BA)  ;| κ
	ReplaceChar(0x3C7)	;| χ
else
	SendChar(0x68)	;| h
possibledoublepress = false
return

$j::
AutoAddSmoothBreathingIfNeeded()
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F21)	;| ἡ
	roughbreathingflag = false
}
else
{
	SendChar(0x3B7)  ;| η
}
return

$k::
AutoAddSmoothBreathingIfNeeded()
if (ctx() = 0x3BD)  ;| ν
{
	ReplaceChar(0x3B3)  ;| γ
	SendChar(0x3BA)  ;| κ
}
else
	SendChar(0x3BA)  ;| κ
possibledoublepress = false
return

$l::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3BB)  ;| λ
possibledoublepress = false
return

$z::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3B6)  ;| ζ
possibledoublepress = false
return

$x::
AutoAddSmoothBreathingIfNeeded()
if (ctx() = 0x3BD)  ;| ν
{
	ReplaceChar(0x3B3)  ;| γ
	SendChar(0x3BE)  ;| ξ
}
else
	SendChar(0x3BE)  ;| ξ
possibledoublepress = false
return

$c::
AutoAddSmoothBreathingIfNeeded()
if (ctx() = 0x3BD)  ;| ν
{
	ReplaceChar(0x3B3)  ;| γ
	SendChar(0x3C7)  ;| χ
}
else
	SendChar(0x3C7)  ;| χ
possibledoublepress = false
return

$b::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3B2)  ;| β
possibledoublepress = false
return

$n::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3BD)  ;| ν
possibledoublepress = false
return

$m::
AutoAddSmoothBreathingIfNeeded()
SendChar(0x3BC)  ;| μ
possibledoublepress = false
return

$+q:: SendChar(0x398)  ;| Θ

$+w::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F69)	;| Ὡ
	roughbreathingflag = false
}
else
{
	SendChar(0x3A9)  ;| Ω
}
return

$+e::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F19)	;| Ἑ
	roughbreathingflag = false
}
else
{
	SendChar(0x395)	;| Ε
}
return

$+r:: SendChar(0x3A1)  ;| Ρ

$+t:: SendChar(0x3A4)  ;| Τ

$+y:: SendChar(0x3A8)  ;| Ψ

$+u::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F59)	;| Ὑ
	roughbreathingflag = false
}
else
{
	SendChar(0x3A5)  ;| Υ
}
return

$+i::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F39)	;| Ἱ
	roughbreathingflag = false
}
else
{
	SendChar(0x399)  ;| Ι
}
return

$+o::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F49)	;| Ὁ
	roughbreathingflag = false
}
else
{
	SendChar(0x39F)
}
return

$+p:: SendChar(0x3A0)  ;| Π

$+a::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F09)	;| Ἁ
	roughbreathingflag = false
}
else
{
	SendChar(0x391)	;| Α
}
return

$+s::
if (ctx() = 0x3A0)  ;| Π
	ReplaceChar(0x3A8)	;| Ψ
else
	SendChar(0x3A3)  ;| Σ
return

$+d:: SendChar(0x394)  ;| Δ

$+f:: SendChar(0x3A6)  ;| Φ

$+g::
if ((ctx() = 0x393) and (ctx(2) = 0x39D))	;| ΝΓ
{
	Back(2)
	SendChar(0x393)
	SendChar(0x393)	;| ΓΓ
}
else
	SendChar(0x393)  ;| Γ
return

$+h::
cc := ctx()
if (cc = 0x3A4)  ;| Τ
	ReplaceChar(0x3B8)	;| θ
;else if (cc = (0x3A7)  ;| Χ
;	ReplaceChar(0x3A7)  ;| Χ
else if (cc = 0x39A)  ;| Κ
	ReplaceChar(0x3A7)  ;| Χ
else
	SendChar(0x48) ;| H
return

$+j::
AutoAddRoughBreathingIfNeeded()
CheckForPrecedingH()
if roughbreathingflag = true
{
	ReplaceChar(0x1F29)	;| Ἡ
	roughbreathingflag = false
}
else
{
	SendChar(0x397)  ;| Η
}
return

$+k::
if (ctx() = 0x39D)  ;| Ν
{
	ReplaceChar(0x393)  ;| Γ
	SendChar(0x39A)  ;| Κ
}
else
	SendChar(0x39A)  ;| Κ
return

$+l:: SendChar(0x39B)  ;| Λ

$+z:: SendChar(0x396)  ;| Ζ

$+x::
if (ctx() = 0x39D)  ;| Ν
{
	ReplaceChar(0x393)  ;| Γ
	SendChar(0x39E)  ;| Ξ
}
else
	SendChar(0x39E)  ;| Ξ
return

$+c::
if (ctx() = 0x39D)  ;| Ν
{
	ReplaceChar(0x393)  ;| Γ
	SendChar(0x3A7)  ;| Χ
}
else
	SendChar(0x3A7)  ;| Χ
return

$+b:: SendChar(0x392)  ;| Β

$+n:: SendChar(0x39D)  ;| Ν

$+m:: SendChar(0x39C)  ;| Μ

$Space::
if (ctx() = 0x3C3)	;| σ
{
	ReplaceChar(0x3C2)	;| ς
	DoSpace()
}
else
{
	possibledoublepress = false
	DoSpace()
}
return

DoVowelAlternation() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InVowelAlternation0%
	{
		if (cc = InVowelAlternation%a_index%)
			{
				ReplaceChar(OutVowelAlternation%a_index%)
				return
			}
	}
	return
}

AddSmoothBreathingMark() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InSmoothBreathing0%
	{
		if (cc = InSmoothBreathing%a_index%)
			{
				ReplaceChar(OutSmoothBreathing%a_index%)
				return
			}
		else
			tempvar := a_index
	}
	return
}

AddRoughBreathingMark() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InRoughBreathing0%
	{
		if (cc = InRoughBreathing%a_index%)
			{
				ReplaceChar(OutRoughBreathing%a_index%)
				return
			}
	}
	return
}

AutoAddSmoothBreathingIfNeeded() {
	global
	; scan backwards through context if vowels (or vowels with diacritics) encountered until space (or carraigereturn or startoftext) is found
	scanbackwardspos=0
	possiblerotacharacter = false
	loop {
		scanbackwardspos := scanbackwardspos + 1
		cc := ctx(scanbackwardspos)
		if ((cc = 0x20) or (cc = 0xA) or (cc = 0xB) or (cc = 0xD) or (cc = "")) ; space, line feed, line tabulation, carriage return, or start of file
		{
			break ; start of word encountered, so auto add smooth breathing required
		}
		else if ((cc = 0x3B1) or (cc = 0x3B5) or (cc = 0x3B7) or (cc = 0x3B9) or (cc = 0x3BF) or (cc = 0x3C5) or (cc = 0x3C9) or (cc = x1F70) or (cc = x1F71) or (cc = x1FB2) or (cc = x1FB3) or (cc = x1FB4) or (cc = x1FB6) or (cc = x1FB7) or (cc = x1F72) or (cc = x1F73) or (cc = x1F74) or (cc = x1F75) or (cc = x1FC2) or (cc = x1FC3) or (cc = x1FC4) or (cc = x1FC6) or (cc = x1FC7) or (cc = x1F76) or (cc = x1F77) or (cc = x03CA) or (cc = x1FD2) or (cc = x1FD3) or (cc = x1FD6) or (cc = x1FD7) or (cc = x1F78) or (cc = x1F79) or (cc = x1F7A) or (cc = x1F7B) or (cc = x03CB) or (cc = x1FE2) or (cc = x1FE3) or (cc = x1FE6) or (cc = x1FE7) or (cc = x1F7C) or (cc = x1F7D) or (cc = x1FF2) or (cc = x1FF3) or (cc = x1FF4) or (cc = x1FF6) or (cc = x1FF7)) ; αεηιουωὰάᾲᾳᾴᾶᾷὲέὴήῂῃῄῆῇὶίϊῒΐῖῗὸόὺύϋῢΰῦῧὼώῲῳῴῶῷ
		{
			continue ; vowel encountered, so keep going backwards
		}
		else if ((scanbackwardspos = 1) and (cc = 0x399)) ; Ι
		{
			continue ; capital I (possibly in front of a vowel)
		}
		else if ((scanbackwardspos >= 2) and ((cc = 0x391) or (cc = 0x395)  or (cc = 0x399) or (cc = 0x39F))) ; ΑΕΙΟ
		{
			continue ; capital vowel preceding a lowercase vowel, so keep going backwards
		}
		else
		{
			return ; something else encountered, so no auto smooth breathing needed
		}
	}

	; check for leading iota
	cc := ctx(scanbackwardspos - 1)
	if cc = 0x3B9
	{
		ReplaceChar(0x1F30, 1, scanbackwardspos - 1)	;| ἰ
		return
	}
	else if cc = 0x399
	{
		ReplaceChar(0x1F38, 1, scanbackwardspos - 1)	;| Ἰ
		return
	}

	; if here, then replace last character in context with vowel with smooth breathing
	AddSmoothBreathingMark()
	return
}

AutoAddRoughBreathingIfNeeded() {
	global
	; if last two characters typed were rho preceded by space (or carraigereturn or startoftext), then replace rho with rho with rough breathing
	cc := ctx()
	dd := ctx(2)

	; lowercase
	if ((cc = 0x3C1) and ((dd = 0x20) or (dd = 0xA) or (dd = 0xB) or (dd = 0xD) or (dd = "")))
	{
		ReplaceChar(0x1FE5)	;| ῥ
	}

	; uppercase
	if ((cc = 0x3A1) and ((dd = 0x20) or (dd = 0xA) or (dd = 0xB) or (dd = 0xD) or (dd = "")))
	{
		ReplaceChar(0x1FEC)	;| Ῥ
	}
	return
}

CheckForPrecedingH() {
	global
	cc := ctx()
	if cc = 0x68
	{
		roughbreathingflag = true
	}
	else if cc = 0x48
	{
		roughbreathingflag = true
	}
	else
	{
		roughbreathingflag = false
	}
	return
}

AddYpogegrammeni() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InYpogegrammeni0%
	{
		if (cc = InYpogegrammeni%a_index%)
			{
				ReplaceChar(OutYpogegrammeni%a_index%)
				return
			}
	}
	SendChar(0x37A)	;| ͺ

	return
}

AddVaria() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InVaria0%
	{
		if (cc = InVaria%a_index%)
			{
				ReplaceChar(OutVaria%a_index%)
				return
			}
	}

	SendChar(0x1FEF)	;| `
	return
}

AddOxia() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InOxia0%
	{
		if (cc = InOxia%a_index%)
			{
				ReplaceChar(OutOxia%a_index%)
				return
			}
	}

	SendChar(0x1FFD)	;| ´
	possibledoublepress = false
	return
}

UndoOxia() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InRemoveOxia0%
	{
		if (cc = InRemoveOxia%a_index%)
			{
				ReplaceChar(OutRemoveOxia%a_index%)
				possibledoublepress = false
				return
			}
	}
	return
}

AddPerispomeni() {
	global

	cc := ctx()
	SetFormat, integer, hex
	cc += 0
	SetFormat, integer, d

	loop, %InPerispomeni0%
	{
		if (cc = InPerispomeni%a_index%)
			{
				ReplaceChar(OutPerispomeni%a_index%)
				return
			}
	}

	; if no match, then send the character on its own
	SendChar(0x1fc0)

	; combining character
	;SendChar(0x342)
	return
}
