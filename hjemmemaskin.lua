-------------------------
-- Hammerspoon config
-- File: hjemmemaskin.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.12.18
-- Version: 3.0.0
------------------------

require('artsnavn')

--- Applications
table.insert(StandardStartMonitor, {"Google Chrome", 2})
table.insert(StandardStartMonitor, {"OmniFocus", 1})

table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("C"), HelpText("Chrome"), ApplicationFocus("Google Chrome")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("D"), HelpText("Darktable"), ApplicationFocus("darktable")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("W"), HelpText("iA Writer"), ApplicationFocus("iA Writer")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("Z"), HelpText("zoom.u"), ApplicationFocus("zoom.u")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("M"), HelpText("Messenger"), ApplicationFocus("Messenger")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("T"), HelpText("SimpleMind"), ApplicationFocus("SimpleMind Pro")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("K"), HelpText("GitKraken"), ApplicationFocus("GitKraken")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("S"), HelpText("Internet search"), InternetSearch("Google Chrome")})
-- table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("V"), HelpText("Copy pasteboard"), CopyPasteboard()})