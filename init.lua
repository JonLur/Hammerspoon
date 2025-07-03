-------------------------
-- Hammerspoon config
-- File: init.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2024.10.19
-- Version: 3.0.4
------------------------

hs = _ENV.hs
spoon = _ENV.spoon

MyHotKeys = {}
StandardStartMonitor = {}

hints = require "hs.hints"
watcher = nil

-- hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall:updateRepo('default')
-- spoon.SpoonInstall:installSpoonFromRepo("SpoonInstall")
-- spoon.SpoonInstall:installSpoonFromRepo("DeepLTranslate")
-- spoon.SpoonInstall:installSpoonFromRepo("MouseCircle")
-- spoon.SpoonInstall:installSpoonFromRepo("PushToTalk")
-- spoon.SpoonInstall:installSpoonFromRepo("SendToOmniFocus")
-- spoon.SpoonInstall:installSpoonFromRepo("WindowScreenLeftAndRight")

--- Spoons
hs.loadSpoon("WindowScreenLeftAndRight")
spoon.WindowScreenLeftAndRight:bindHotkeys(spoon.WindowScreenLeftAndRight.defaultHotkeys)

hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({show={{"ctrl", "alt", "cmd"}, "M"}} )

require('funksjoner')
require('cheatsheets')
require('evoluent')
require('battery')
require('dagliglogg')

-- Get and print the serial number
result, serial_number = hs.osascript.applescript("set serialNumber to do shell script \"system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'\"")
if not result then
  print("Error retrieving serialnumber")
  serial_number = nil
else
  if (serial_number == "C02DW1QNQ6L5" ) then
    print("Laster hjemmemaskin")
    require('hjemmemaskin')
  elseif (serial_number == "C02G945EQ6LR") then
    print("Laster jobbmaskin")
    require('jobbmaskin')
  end
end

watcher = hs.application.watcher.new(applicationWatcher)


--- Applications
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("O"), HelpText("OmniFocus"), ApplicationFocus("OmniFocus")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("L"), HelpText("LastPass"), ApplicationFocus("LastPass")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("I"), HelpText("iTerm2"), ApplicationFocus("iTerm")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("P"), HelpText("PreView"), ApplicationFocus("PreView")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("U"), HelpText("Final Cut Pro"), ApplicationFocus("Final Cut Pro")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("F"), HelpText("Search remaining in OmniFocus"), InOmniFocus("FindIn")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("H"), HelpText("Copy selected to OmniFocus"), InOmniFocus("CopyTo")})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("J"), HelpText("Dagliglogg to Sqlite3"), ToDagliglogg("SendTo")})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("U"), HelpText("Note to last modified task OmniFocus"), InOmniFocus("NoteTo")})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("S"), HelpText("URL to OmniFocus"), InOmniFocus("URLTo")})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("L"), HelpText("Lock Screen"), LockScreen()})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("T"), HelpText("Insert date"), InsertDate()})
table.insert(MyHotKeys, {KeyModifier("CtrlAltCmd"), KeyHotKey("W"), HelpText("Vinduer"), WindowHints()})
table.insert(MyHotKeys, {KeyModifier("CtrlAlt"), KeyHotKey("A"), HelpText("Standard åpninger"), StandardOpening(StandardStartMonitor)})

-- Bind hotkeys
for i, v in ipairs(MyHotKeys) do
  HotKey = v
  array = {}
  for j, w in ipairs(HotKey) do
    array[j] = w
  end
  hs.hotkey.bind(array[1], array[2], array[3], array[4])
end

-- Keyboard space replace
hs.hotkey.bind(nil, "¨","Space", function() hs.eventtap.keyStroke({},"space") end)

-- Show hotkeys place at midle of screen.
-- hs.hotkey.showHotkeys({"cmd", "ctrl", "alt"}, "S")
hs.hotkey.alertDuration = 0

-- Config reloading
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")