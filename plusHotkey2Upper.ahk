;a := RegExReplace(clipboard, "=\+([a-z])", "=$U1")
a := RegExReplace(clipboard, "\+([a-z])", "$U1")
msgbox %a%
clipboard := a