altkeys =
(Join: LTrim
AppsKey : LWin : RWin : LControl : LShift : RShift : LAlt : RAlt
PrintScreen : CtrlBreak : Pause : Break
Space : Tab : Enter : Escape : Delete : Insert : Home : End : PgUp : PgDn : Up : Down : Left : Right
ScrollLock : CapsLock : NumLock
Numpad0 : Numpad1 : Numpad2 : Numpad3 : Numpad4 : Numpad5 : Numpad6 : Numpad7 : Numpad8 : Numpad9
NumpadDown : NumpadLeft : NumpadRight : NumpadUp
NumpadIns : NumpadEnd : NumpadPgDn : NumpadClear : NumpadHome : NumpadPgUp
NumpadDot : NumpadDel : NumpadDiv : NumpadMult : NumpadAdd : NumpadSub : NumpadEnter
F1 : F2 : F3 : F4 : F5 : F6 : F7 : F8 : F9 : F10 : F11 : F12 : F13 : F14 : F15 : F16 : F17 : F18 : F19 : F20 : F21 : F22 : F23 : F24
Browser_Back : Browser_Forward : Browser_Refresh : Browser_Stop : Browser_Search : Browser_Favorites : Browser_Home
Volume_Mute : Volume_Down : Volume_Up
Media_Next : Media_Prev : Media_Stop : Media_Play_Pause
Launch_Mail : Launch_Media : Launch_App1 : Launch_App2
mbutton : rbutton : lbutton
)

Loop, Parse, altkeys, `,, %A_Space%
    Hotkey, % "~" A_LoopField, EndCharIsTyped, ON
EndCharIsTyped:
    A_Hotstring := "" ; remove any saved Global HotStrings