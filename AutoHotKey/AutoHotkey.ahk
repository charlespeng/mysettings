; IMPORTANT INFO ABOUT GETTING STARTED: Lines that start with a
; semicolon, such as this one, are comments.  They are not executed.

; # - Win ke:
; ^ - Ctrl key
; ! - Alt key
; + - Shift key

#SingleInstance, force

; ---------------------
; WINDOWS KEY BINDINGS
; ---------------------


CAPSLOCK::Escape

; Match window names by part of the title
SetTitleMatchMode, RegEx
SetTitleMatchMode, Slow

; Set Lock keys permanently
SetNumlockState, AlwaysOn
SetCapsLockState, AlwaysOff
SetScrollLockState, AlwaysOff

DetectHiddenText, On
DetectHiddenWindows, On
return

DropBoxDir := "C:\Dropbox"
ToolsDir := DropBoxDir . "\Tools"

#LButton::
#+q::
#WheelDown::
sendevent {LWin down}{LCtrl down}{Left down}
Sleep 100
SendEvent {Left up}{LCtrl up}{Lwin up}      ; switch to next virtual desktop
Sleep 1000
return

#+w::
#RButton::
#WheelUp::
sendevent {LWin down}{LCtrl down}{Right down}
Sleep 100
SendEvent {Right up}{LCtrl up}{Lwin up}      ; switch to next virtual desktop
Sleep 1000
return


#+h::Send #+{Left}
#+l::Send #+{Right}
#+j::Send #{Left}
#+k::Send #{Right}
#+u::Send #{Up}


+!c::

INPUT, command, T2 L2

if ("f" = command){
    FlushAll()
} else if ("a" = command){

}
return

+!f::
INPUT, command, T2 L2

if ("ia" = command)
    gvim("C:\Windows\System32\inetsrv\Config\applicationHost.config")
else if ("hh" = command)
    gvim("C:\Windows\System32\drivers\etc\hosts")
else if ("co" = command){
    gvim(Clipboard)
}
return

+!v::

INPUT, command, T2 L1

if ("e" = command){
    INPUT, command, T2 L1
    LastNLetters := SubStr(Clipboard, -1 * command)
    Send, %LastNLetters%
}
else if ("s" = command){
    INPUT, command, T2 L1
    FirstNLetters := SubStr(Clipboard, 1, command)
    Send, %FirstNLetters%
}

return

+!g::
INPUT, command, T2 L1

if ("g" = command){
    Clipboard := CreateGUID()
}
else if ("u" = command){
    Clipboard := CreateUUID()
}
else if ("l" = command){
    GenerateLoremIpsum()
}

return


+!i::

    INPUT, command, T2 L1
    Url:=CopyBrowserUrl()
    if ("f" = command){
        firefox(Url)
    }
    else if ("e" = command){
        Edge(Url)
    }
    else if ("i" = command){
        IE(Url)
    }

return

#Include <Hotkeys>

#Include %A_ScriptDir%\Windows\Sound.ahk
#Include %A_ScriptDir%\Common\Common.ahk
#Include %A_ScriptDir%\Common\Common.Text.ahk
#Include %A_ScriptDir%\Common\Common.Web.ahk
#Include %A_ScriptDir%\Common\Common.Files.ahk
#Include %A_ScriptDir%\slugify.ahk
#Include %A_ScriptDir%\ParseUrl.ahk
#Include %A_ScriptDir%\Common\Common.Guids.ahk
#Include %A_ScriptDir%\Common\LoremIpsum.ahk

#Include %A_ScriptDir%\KeyBindings\Applications.ahk
#Include %A_ScriptDir%\KeyBindings\SinglePress.ahk

; The FileName parameter may optionally be preceded by *i and a single space,
;   which causes the program to ignore any failure to load the included file.
; For example: #Include *i SpecialOptions.ahk.
; This option should be used only when the included file's contents are not essential to the main script's operation.
#Include *i C:\_Merck\Merck.ahk



; -----------------------
; FUNCTIONS
; -----------------------

GetDirFromWindowTitle(){
    ID := WinExist("A")
    WinGetTitle, Title, ahk_ID %ID%
    if(FileExist(Title))
        return  Title
    return
}

!+q::
Send, ^c
Sleep 50
Run, http://www.google.com/search?q=%clipboard%
Return


; #IfWinActive, ahk_exe  TOTALCMD64.EXE
; {
;     !d::
;     Send {Home}
;     Send {Shift Down}
;     Sleep 10
;     Send {F6 Down}
;     Sleep 10
;     Send {F6 Up}{Shift Up}
;     return
; }
; #IfWinActive

; #IfWinActive, ahk_exe  chrome.exe
; {
;     !+g::
;     oldClipboard:=Clipboard
;     url:= CopyBrowserUrl()
;     Clipboard := RegExReplace(url, "www\.youtube", "www.genyoutube")
;     Send ^t
;     sleep 10
;     Send ^v
;     Sleep 10
;     Send {Enter}
;     sleep 10
;     Clipboard:=oldClipboard
;     return
; }
; #IfWinActive
