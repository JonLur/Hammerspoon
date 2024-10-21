-------------------------
-- Hammerspoon config
-- File: jobbmaskin.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2024.10.19
-- Version: 3.0.4
------------------------

hs.loadSpoon("DeepLTranslate")
spoon.DeepLTranslate:bindHotkeys({translate={{"ctrl", "alt", "cmd" }, "O" }})

table.insert(StandardStartMonitor, {"Microsoft Outlook", 1})
table.insert(StandardStartMonitor, {"OmniFocus", 2})
table.insert(StandardStartMonitor, {"Microsoft Edge", 2})
-- table.insert(StandardStartMonitor, {"Microsoft Remote Desktop", 2})
table.insert(StandardStartMonitor, {"Windows App", 2})
table.insert(StandardStartMonitor, {"Microsoft Teams", 1})
table.insert(StandardStartMonitor, {"Microsoft OneNote", 2})
table.insert(StandardStartMonitor, {"Lastpass", 1})

--- Applications
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("E"), HelpText("Edge"), ApplicationFocus("Microsoft Edge")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("M"), HelpText("Outlook"), ApplicationFocus("Microsoft Outlook")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("N"), HelpText("OneNote"), ApplicationFocus("Microsoft OneNote")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("R"), HelpText("Remote Desktop"), ApplicationFocus("Microsoft Remote Desktop")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("T"), HelpText("Microsoft Teams"), ApplicationFocus("com.microsoft.teams2")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("V"), HelpText("Copy pasteboard"), CopyPasteboardWork()})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("H"), HelpText("Keyboard helper"), imgKeyboardOption()})