﻿UpdatePluginList() {
	Loop, %A_ScriptDir%\Plugins\*.ahk {
		new_include_list .= "#Include *i " . A_ScriptDir . "\Plugins\" . A_LoopFileName . "`n"
	}

	file := FileOpen(A_ScriptDir . "\PluginList.ahk", "r", "utf-8")
	old_include_list := file.Read(file.Length)
	
	If (old_include_list != new_include_list) {
		file := FileOpen(A_ScriptDir . "\PluginList.ahk", "w", "utf-8")
		file.Write(new_include_list)
		file.Close
		Reload
	}
}

RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	Tooltip
	return

ToolTip(str,delay=0) {
	ToolTip, %str%,  A_ScreenWidth//2, A_ScreenHeight//2
	if delay
		SetTimer, RemoveToolTip, %delay%
}

BthDvc(deviceName,toggleOn){
	DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
	toggle := toggleOn
	VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
	NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
	NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint")   ; fReturnAuthenticated
	VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
	NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")

	ToolTip("Finding Device")
	loop {
		If(A_Index = 1){
			foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO)
			if !foundedDevice{
				msgbox no bluetooth devices
				return
			}
		}else{
			if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO){
				msgbox no found
				return
			}
		}
		if (Instr(StrGet(&BLUETOOTH_DEVICE_INFO+64), deviceName)){
			ToolTip(toggleOn ? "Connecting" : "Disconnecting")
			VarSetCapacity(Handsfree, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree)   ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
			VarSetCapacity(AudioSink, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)
			
			; loop{
			; 	hr := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", toggle)   ; voice
			; 	if (hr = 0){
			; 		if (toggle = toggleOn)
			; 			break
			; 		toggle := !toggle
			; 	}
			; 	if (hr = 87)
			; 		toggle := !toggle
			; }

			loop{
				hr := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", toggle)   ; music
				if (hr = 0){
					if (toggle = toggleOn)
						break 2
					toggle := !toggle
				}
				if (hr = 87)
					toggle := !toggle
			}
		}
	}
	DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
	ToolTip("done",500)
	return
}

Click(ClickX,ClickY){
	MouseGetPos MouseX, MouseY
	BlockInput, MouseMove
	MouseMove ClickX, ClickY, 0	
	Click
	MouseMove MouseX, MouseY, 0
	BlockInput, MouseMoveOff
}

ClickImage(ImagePath){
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, %ImagePath%
	Click(FoundX, FoundY)
}

CloseSaveDialog(){
	if(A_PriorHotkey==A_ThisHotkey){
		WinGetClass, ClassStr, A
		WinGetTitle, TitleStr, A

		If(ClassStr == "#32770"){
			Send {n}
		}
		If(Instr(TitleStr,"このサイトを") OR Instr(TitleStr,"場所が利用できません")){
			Send {Enter}
		}
	}
	return
}

DeleteRow(){
	SendEvent {End}+{Home}+{Home}+{Left}{BS}{Right}
}

DuplicateRow(){
	SendEvent {End}+{Home} ;+{Home}{Left}
	OldClipboard := CopySelection()
	Send {Right}{Enter}^v
	PasteWait(OldClipboard)
	return
}

ExtractZip(){ ;clipboard追加
	curdir := GetActiveExplorerPath()
	Loop, %curdir%\*.zip
		ZipDir := A_LoopFileFullPath
		SplitPath, ZipDir,,,, name_no_ext
		NewDir := curdir . "\" . name_no_ext
		FileCreateDir, %NewDir%
		psh  := ComObjCreate("Shell.Application")
		psh.Namespace(NewDir).CopyHere( psh.Namespace(ZipDir).items, 4|16 )
		FileDelete % ZipDir
		return
	return
}

GetActiveExplorerPath(){
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd){
		for window in ComObjCreate("Shell.Application").Windows{
			if (window.hwnd==explorerHwnd){
				curdir := window.Document.Folder.Self.Path
			}
		}
	}
	return curdir
}

MsgWinTitle(){
	WinGetTitle, Title, A
	WinGet, ExStyle, ExStyle, A
	WinGetText, Body, A
	MsgBox % Title . "`n" . ExStyle . "`n" . Body
	return
}

MsgWinTitle2(){
	WinGet windows, List
	Loop %windows%
	{
		id := windows%A_Index%
		WinGetTitle wt, ahk_id %id%
		r .= wt . "`n"
		WinGet, ExStyle, ExStyle, ahk_id %id%
		If(ExStyle=="0x08200000"){
			msgbox %id%
			msgbox %wt%
		}
	}
	msgbox %r%
}

CopySelection(){
	OnClipboardChange("UpdateClipArray",0)
	OldClipboard := Clipboard
	Clipboard := ""
	SendEvent ^c
	ClipWait
	return %OldClipboard%
}

PasteWait(OldClipboard){
	while DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep 20
		tooltip waiting
	Sleep 20
	tooltip
	Clipboard := ""
	Clipboard := OldClipboard
	OnClipboardChange("UpdateClipArray",1)
	return
}

PasteStr(Str){
	OnClipboardChange("UpdateClipArray",0)
	OldClipboard := ClipboardAll
	Clipboard := ""
	Clipboard := Str
	ClipWait
	SendEvent ^v
	PasteWait(OldClipboard)
	return
}

SendJs(JsStr){
	SendEvent ^l
	Sleep 200
	PasteStr("javascript")
	PasteStr(": " . JsStr)
	SendEvent {Enter}
	return
}

SendTo(keystroke,target){
    WinActivate, %target%
    WinWaitActive, %target%
    Send %keystroke%
    return
}

ShowApp(exe_path, selector){
	IfWinExist %selector%
		WinActivate %selectors%
	Else
		Run %exe_path%
	return
}

ShowImg(ImgPath){
	Gui, +LastFound -Caption +E0x20
	Gui,Color,888888
	WinSet,Transcolor, 888888 126
	Gui,Margin,0,0
	Gui, Add, Picture, w1200 h800 BackGroundTrans, %ImgPath%
	Gui, Show,, Window

	KeyWait % SubStr(A_ThisHotkey,StrLen(A_ThisHotkey))

	Gui, Show, Hide, Window
	return
}