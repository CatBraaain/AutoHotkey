#NoEnv
SetBatchLines, -1
ListLines, Off
#Persistent
#SingleInstance, Force

#InstallKeybdHook
#InstallMouseHook
#UseHook
#HotkeyInterval, 2000
#MaxHotkeysPerInterval, 200

; SendMode, Input1
Process, Priority,, Realtime
DetectHiddenWindows, On
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, RegEx
SetNumLockState AlwaysOn
SetCapsLockState AlwaysOff

SetMenuTray()
PrepareForClickCoordHotkey()
StartClipboardHistory()
UpdatePluginList()

tenkeytoggle:= false
games := "diep.io - Google Chrome|Robocraft|Minecraft|HalfDead2|STUG|Krunker|Counter-Strike|CrowFPS|MilkChoco|PortalWars|Monster Hunter|Unrailed!"
IniRead, GeneralPW, C:\Users\PRO\Documents\MyAhk.ini, IDPW, GeneralPW

Exit ;Exit Auto-Execute

#Include, %A_ScriptDir%\MyFunctions.ahk
#Include, %A_ScriptDir%\PluginList.ahk