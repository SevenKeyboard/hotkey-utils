#Requires AutoHotkey v1.1.37+
;==============================================================
; HotkeyUtils — Parses, compares, validates, and formats hotkey strings
;
; GitHub: https://github.com/SevenKeyboard/hotkey-utils
; Author: SevenKeyboard Ltd. (2026)
; License: MIT License
;
; Documentation / References:
;   https://www.autohotkey.com/docs/v1/KeyList.htm
;==============================================================

/*
Example Usage:
    ;  #Include %A_ScriptDir%
    ;  #Include .\lib\ObjectDumpUtils.ahk
    ;  msgbox % dumpArray(hotkeySplit("^+!a up"))
    ;  msgbox % dumpArray(hotkeySplit("~a & b up"))
    msgbox % hotkeyEqual("^+c","+^c")
    msgbox % hotkeyEqual("^+c","+!^c")
    msgbox % formatKeyTitleCase("mbutton")
    msgbox % formatKeyTitleCase("vkFF")
    msgbox % formatKeyTitleCase("sc000")
*/

class VersionManager_HotkeyUtils
{
    static _ := VersionManager_HotkeyUtils._init()
    _init()    {
        global
        HOTKEYUTILS_VERSION := "1.1.2"
    }
}
hotkeySplit(hotkeyName)    {
    out:={Type:"Unknown"}
    if (!regExMatch(hotkeyName
        ,"iDO)("
        . "(*MARK:Normal)"
        . "^(?P<MainSymbols>[\Q#!^+<>*~$\E]*)"
        . "(?P<MainKey>[^\dA-Za-z]{1}|[\dA-Za-z]+)"
        . "(?P<IsMainUp>\h+Up)?$"
        . "|(*MARK:Custom)"
        . "^(?P<PrefixSymbols>~?)"
        . "(?P<PrefixKey>[^\h]+)" . "\h+&\h+" 
        . "(?P<SuffixSymbols>~?)"
        . "(?P<SuffixKey>[^\h]+)"
        . "(?P<IsSuffixUp>\h+Up)?$"
        . ")", m))
        return out
    switch (out.Type:=m.mark())
    {
        case "Normal":      propNames:=["MainSymbols","MainKey","IsMainUp"]
        case "Custom":      propNames:=["PrefixSymbols","PrefixKey","SuffixSymbols","SuffixKey","IsSuffixUp"]
    }
    for _,n in propNames
        out[n]:=(subStr(n,-1)=="Up"?(m.value(n)!==""):m.value(n))
    return out
}
hotkeyEqual(hotkeyA, hotkeyB, ignoreTildeAndDollarSign:=true)    {
    outA:=hotkeySplit(hotkeyA), outB:=hotkeySplit(hotkeyB)
    if (outA.Type=="Unknown" || outB.Type=="Unknown")
        return false
    for kA,vA in outA    {
        vB:=(outB.hasKey(kA)?outB[kA]:"")
        if (kA~="D)Symbols$")    {
            vA0:=vA, vA:=""
            vB0:=vB, vB:=""
            if (ignoreTildeAndDollarSign)
                vA0:=regExReplace(vA0,"[\$~]+"), vB0:=regExReplace(vB0,"[\$~]+")
            for _,modk in ["*","~","$","<#",">#","#","<^",">^","^","<!",">!","!","<+",">+","+"]    {
                if (inStr(vA0,modk))
                    vA0:=strReplace(vA0,modk), vA.=modk
                if (inStr(vB0,modk))
                    vB0:=strReplace(vB0,modk), vB.=modk
            }
        }
        switch
        {
            case (kA~="D)Key$"):
                if (regExMatch(vA, "iDO)^(vk|sc)([[:xdigit:]]+)$", mA))    {
                    modeA := format("{:L}", mA[1])
                    vA := format("{:L}", mA[1]) . format("{:0" (modeA == "sc" ? 3 : 2) "X}", "0x" mA[2])
                    if (regExMatch(vB, "iDO)^" modeA "\K[[:xdigit:]]+$", mB))    {
                        vB := modeA . format("{:0" (modeA == "sc" ? 3 : 2) "X}", "0x" mB[0])
                        if (vA!==vB)
                            return false
                    }  else  {
                        return false
                    }
                }  else if (format("{:L}",vA)!==(format("{:L}",vB)))    {
                    return false
                }
            default:
                if (vA!==vB)
                    return false
        }
    }
    return true
}
hotkeyGetValidation(hotkeyName)    {
    static fn := func("hotkeyValidationStub_B5962F5B")
    prevIC := A_IsCritical
    critical % "On"
    if (hotkeyName == "")    {
        b := false
    }  else  {
        prevErrorLevel := errorLevel
        hotkey If, % fn
        hotkey % hotkeyName, % fn, % "UseErrorLevel Off"
        b := !errorLevel, errorLevel := prevErrorLevel
        hotkey If
    }
    critical % prevIC
    return b
}
hotkeyValidationStub_B5962F5B(_*)    {
    return false
}
/*
 * Even from the perspective that assigning duplicate hotkeys is not possible, 
 * "Delete" and "Del" can be assigned simultaneously.
 */
formatKeyTitleCase(key)    {
    static list:=""
    if (list=="")
        list:=getListOfKeys_D27DF2D4()
    key:=format("{:L}",key)
    switch
    {
        default:                        return key
        case (list.hasKey(key)):        return list[key]
        case regExMatch(key,"iDO)^(sc|vk)([[:xdigit:]]+)$",m):
            return (codeType:=format("{:U}",m[1])) format(codeType=="SC"?"{:03X}":"{:02X}","0x" m[2])
    }
}
getListOfKeys_D27DF2D4()    { ;  https://www.autohotkey.com/docs/v1/KeyList.htm
    static list:=""
    if (list=="")    {
        list:=object("lbutton","LButton"
        ,"rbutton","RButton"
        ,"mbutton","MButton"
        ,"xbutton1","XButton1"
        ,"xbutton2","XButton2"
        ,"wheeldown","WheelDown"
        ,"wheelup","WheelUp"
        ,"wheelleft","WheelLeft"
        ,"wheelright","WheelRight"
        ,"capslock","CapsLock"
        ,"space","Space"
        ,"tab","Tab"
        ,"enter","Enter"
        ,"escape","Escape"
        ,"esc","Esc"
        ,"backspace","Backspace"
        ,"bs","BS"
        ,"scrolllock","ScrollLock"
        ,"delete","Delete"
        ,"del","Del"
        ,"insert","Insert"
        ,"ins","Ins"
        ,"home","Home"
        ,"end","End"
        ,"pgup","PgUp"
        ,"pgdn","PgDn"
        ,"up","Up"
        ,"down","Down"
        ,"left","Left"
        ,"right","Right"
        ,"numpad0","Numpad0"
        ,"numpadins","NumpadIns"
        ,"numpad1","Numpad1"
        ,"numpadend","NumpadEnd"
        ,"numpad2","Numpad2"
        ,"numpaddown","NumpadDown"
        ,"numpad3","Numpad3"
        ,"numpadpgdn","NumpadPgDn"
        ,"numpad4","Numpad4"
        ,"numpadleft","NumpadLeft"
        ,"numpad5","Numpad5"
        ,"numpadclear","NumpadClear"
        ,"numpad6","Numpad6"
        ,"numpadright","NumpadRight"
        ,"numpad7","Numpad7"
        ,"numpadhome","NumpadHome"
        ,"numpad8","Numpad8"
        ,"numpadup","NumpadUp"
        ,"numpad9","Numpad9"
        ,"numpadpgup","NumpadPgUp"
        ,"numpaddot","NumpadDot"
        ,"numpaddel","NumpadDel"
        ,"numlock","NumLock"
        ,"numpaddiv","NumpadDiv"
        ,"numpadmult","NumpadMult"
        ,"numpadadd","NumpadAdd"
        ,"numpadsub","NumpadSub"
        ,"numpadenter","NumpadEnter"
        ,"lwin","LWin"
        ,"rwin","RWin"
        ,"control","Control"
        ,"ctrl","Ctrl"
        ,"alt","Alt"
        ,"shift","Shift"
        ,"lcontrol","LControl"
        ,"lctrl","LControl"
        ,"rcontrol","RControl"
        ,"rctrl","RControl"
        ,"lshift","LShift"
        ,"rshift","RShift"
        ,"lalt","LAlt"
        ,"ralt","RAlt"
        ,"browser_back","Browser_Back"
        ,"browser_forward","Browser_Forward"
        ,"browser_refresh","Browser_Refresh"
        ,"browser_stop","Browser_Stop"
        ,"browser_search","Browser_Search"
        ,"browser_favorites","Browser_Favorites"
        ,"browser_home","Browser_Home"
        ,"volume_mute","Volume_Mute"
        ,"volume_down","Volume_Down"
        ,"volume_up","Volume_Up"
        ,"media_next","Media_Next"
        ,"media_prev","Media_Prev"
        ,"media_stop","Media_Stop"
        ,"media_play_pause","Media_Play_Pause"
        ,"launch_mail","Launch_Mail"
        ,"launch_media","Launch_Media"
        ,"launch_app1","Launch_App1"
        ,"launch_app2","Launch_App2"
        ,"appskey","AppsKey"
        ,"printscreen","PrintScreen"
        ,"ctrlbreak","CtrlBreak"
        ,"pause","Pause"
        ,"help","Help"
        ,"sleep","Sleep")
        loop 24    {
            i := format("{:d}",A_Index)
            list["f" i]:="F" i
        }
        loop 32    {
            i := format("{:d}",A_Index)
            list["joy" i]:="Joy" i
        }
    }
    return list
}