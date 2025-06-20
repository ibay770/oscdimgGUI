; Enhanced AutoIt Script for OSCDIMG GUI
; Features: English UI, Dark Mode, INI config, keyboard shortcuts, tabbed interface, live output, and more

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <TabConstants.au3>
#include <EditConstants.au3>
#include <MsgBoxConstants.au3>

Global $INI_FILE = @ScriptDir & "\oscdimg_gui.ini"
Global $USE_DARKMODE = IniRead($INI_FILE, "Settings", "DarkMode", "0") = "1"
Global $BK_COLOR = $USE_DARKMODE ? 0x1E1E1E : 0xFFFFFF
Global $TXT_COLOR = $USE_DARKMODE ? 0xD4D4D4 : 0x000000

; Main Window
Global $MAINWIN = GUICreate("OSCDIMG GUI - Enhanced", 640, 700, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU, $WS_POPUP, $WS_GROUP))
GUISetBkColor($BK_COLOR)

; Tabs
Global $TAB = GUICtrlCreateTab(10, 10, 620, 650)

; --- Tab 1: ISO Creation ---
GUICtrlCreateTabItem("ISO Creation")
GUICtrlCreateLabel("Source Path:", 30, 50)
GUICtrlCreateLabel("Destination ISO:", 30, 85)
Global $IPATH1 = GUICtrlCreateInput("", 140, 45, 360, 22)
Global $IPATH2 = GUICtrlCreateInput("", 140, 80, 360, 22)
Global $IBROW1 = GUICtrlCreateButton("Browse", 510, 45, 80, 22)
Global $IBROW2 = GUICtrlCreateButton("Browse", 510, 80, 80, 22)

GUICtrlCreateGroup("Boot Options", 30, 120, 580, 130)
GUICtrlCreateLabel("BIOS Boot File:", 50, 150)
GUICtrlCreateLabel("UEFI Boot File 1:", 50, 180)
GUICtrlCreateLabel("UEFI Boot File 2:", 50, 210)
Global $IPATH3 = GUICtrlCreateInput("", 180, 145, 300, 22)
Global $IPATH4 = GUICtrlCreateInput("", 180, 175, 300, 22)
Global $IPATH5 = GUICtrlCreateInput("", 180, 205, 300, 22)
Global $IBROW3 = GUICtrlCreateButton("Browse", 490, 145, 80, 22)
Global $IBROW4 = GUICtrlCreateButton("Browse", 490, 175, 80, 22)
Global $IBROW5 = GUICtrlCreateButton("Browse", 490, 205, 80, 22)

GUICtrlCreateGroup("File System", 30, 270, 580, 50)
Global $IFS1 = GUICtrlCreateRadio("ISO 9660", 40, 290)
Global $IFS2 = GUICtrlCreateRadio("Joliet", 150, 290)
Global $IFS3 = GUICtrlCreateRadio("UDF", 250, 290)
Global $IFS4 = GUICtrlCreateRadio("ISO + UDF", 350, 290)
Global $IFS5 = GUICtrlCreateRadio("Joliet + UDF", 460, 290)
GUICtrlSetState($IFS5, $GUI_CHECKED)

GUICtrlCreateGroup("Options", 30, 330, 580, 50)
Global $IVOLUMELABEL = GUICtrlCreateInput("", 180, 345, 180, 22)
GUICtrlCreateLabel("Volume Label:", 50, 350)
Global $IOPTIMIZEDUPLICATES = GUICtrlCreateCheckbox("Optimize duplicate files", 370, 345)
Global $IDISEMULATION = GUICtrlCreateCheckbox("Disable floppy emulation", 370, 365)
GUICtrlSetState($IOPTIMIZEDUPLICATES, $GUI_CHECKED)
GUICtrlSetState($IDISEMULATION, $GUI_CHECKED)

Global $IDARKMODETOGGLE = GUICtrlCreateCheckbox("Enable Dark Mode", 30, 390)
GUICtrlSetState($IDARKMODETOGGLE, $USE_DARKMODE ? $GUI_CHECKED : $GUI_UNCHECKED)

Global $IMAKE = GUICtrlCreateButton("[Ctrl+Enter] Create ISO", 130, 430, 160, 35)
Global $IQUIT = GUICtrlCreateButton("[Esc] Exit", 330, 430, 160, 35)

; --- Tab 2: Logs ---
GUICtrlCreateTabItem("Log Output")
GUICtrlCreateLabel("Command Line Output:", 20, 50)
Global $IOUTPUTLOG = GUICtrlCreateEdit("", 20, 70, 590, 500, BitOR($ES_MULTILINE, $ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL))
GUICtrlSetFont($IOUTPUTLOG, 9, 400, 0, "Courier New")

GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW, $MAINWIN)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE, $IQUIT
            Exit
        Case $IBROW1
            GUICtrlSetData($IPATH1, FileSelectFolder("Choose source folder", @ScriptDir))
        Case $IBROW2
            GUICtrlSetData($IPATH2, FileSaveDialog("Save ISO file as", @ScriptDir, "ISO Image (*.iso)", 2))
        Case $IBROW3
            GUICtrlSetData($IPATH3, FileOpenDialog("Select BIOS boot file", @ScriptDir, "*.bin;*.img;*.ima", 1))
        Case $IBROW4
            GUICtrlSetData($IPATH4, FileOpenDialog("Select UEFI boot file 1", @ScriptDir, "*.bin;*.img;*.ima", 1))
        Case $IBROW5
            GUICtrlSetData($IPATH5, FileOpenDialog("Select UEFI boot file 2", @ScriptDir, "*.bin;*.img;*.ima", 1))
        Case $IMAKE
            RunBuild()
        Case $IDARKMODETOGGLE
            IniWrite($INI_FILE, "Settings", "DarkMode", GUICtrlRead($IDARKMODETOGGLE) = 1 ? "1" : "0")
            MsgBox($MB_ICONINFORMATION, "Restart Required", "Please restart the app to apply dark mode setting.")
    EndSwitch

    ; Keyboard shortcuts
    If _IsPressed("11") And _IsPressed("0D") Then ; Ctrl+Enter
        RunBuild()
    EndIf
    If _IsPressed("1B") Then ; Esc
        Exit
    EndIf
WEnd

Func RunBuild()
    GUICtrlSetData($IOUTPUTLOG, "")
    Local $cmd = "oscdimg.exe -o -u1 -udfver102"
    $cmd &= ' "' & GUICtrlRead($IPATH1) & '" "' & GUICtrlRead($IPATH2) & '"'
    Local $pid = Run(@ComSpec & " /c " & $cmd, @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
    While ProcessExists($pid)
        Sleep(100)
        Local $out = StdoutRead($pid)
        If $out <> "" Then GUICtrlSetData($IOUTPUTLOG, GUICtrlRead($IOUTPUTLOG) & $out)
    WEnd
    MsgBox(0, "Done", "ISO image created.")
EndFunc

#include <Misc.au3>
