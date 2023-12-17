-------------------------
-- Hammerspoon config
-- File: init.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Version: 2.0
------------------------

hs = _ENV.hs
spoon = _ENV.spoon

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

hints = require "hs.hints"
watcher = nil

watcher = hs.application.watcher.new(applicationWatcher)


--- Applications
MyHotKeys = {}
MyHotKeys[1] = {KeyCtrlAlt("O"), HelpText("OmniFocus"), ApplicationFocus("OmniFocus")}
MyHotKeys[2] = {KeyCtrlAlt("L"), HelpText("LastPass"), ApplicationFocus("LastPass")}
MyHotKeys[3] = {KeyCtrlAlt("I"), HelpText("iTerm2"), ApplicationFocus("iTerm")}
MyHotKeys[4] = {KeyCtrlAlt("P"), HelpText("PreView"), ApplicationFocus("PreView")}
--MyHotKeys[5] = {KeyCtrlAlt("M"), HelpText("Messenger"), ApplicationFocus("Messenger")}
--MyHotKeys[6] = {KeyCtrlAlt("T"), HelpText("SimpleMind"), ApplicationFocus("SimpleMind Pro")}
--MyHotKeys[7] = {KeyCtrlAlt("K"), HelpText("GitKraken"), ApplicationFocus("GitKraken")}
--MyHotKeys[8] = {KeyCtrlAlt("S"), HelpText("Internet search"), InternetSearch("Google Chrome")}
--MyHotKeys[9] = {KeyCtrlAlt("V"), HelpText("Copy pasteboard"), CopyPasteboard("Paste")}



hs.hotkey.bind({"ctrl", "alt"}, "F", "Search remaining in OmniFocus", function()
  app = hs.application.get("OmniFocus")
  app:activate()
  app:selectMenuItem("Search Remaining")
end)

-- Add highlited to OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "H", "Copy selected to OmniFocus", function()
  hs.eventtap.keyStroke({"cmd"}, "C")
  hs.eventtap.keyStroke({"ctrl", "alt"}, "space")
  delayedPasteWithoutReturn()
end)

-- Add note to OmniFocus
hs.hotkey.bind({"ctrl", "alt","cmd"}, "U", "Note to last modified task OmniFocus", function()
  hs.osascript.applescriptFromFile("omnifocus-note.applescript")
end)

-- Save URL and title from Chrome/Safari to OmniFocus
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", "URL to OmniFocus", function()
hs.osascript.applescriptFromFile("url-to-omnifocus.applescript")
end)

-- Add logg note with duration to sqlite3 database
hs.hotkey.bind({"ctrl", "alt"}, "J", "Dagliglogg to Sqlite3", function()
  dagliglogg_ny()
end)

-- Save scpt as applescript to OmniFocus
-- hs.hotkey.bind({"ctrl", "alt", "cmd"}, "A", "Save also as applescript", function()
--    hs.osascript.applescriptFromFile("save-applescript-as-text.applescript")
-- end)

-- Keyboard space replace
hs.hotkey.bind(nil, "¨","Space", function() hs.eventtap.keyStroke({},"space") end)

-- Lock screen
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "L", "Lock Screen", function()
-- hs.caffeinate.lockScreen()
  hs.caffeinate.startScreensaver()
end)

-- Insert date
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "T", "Insert date", function()
  hs.eventtap.keyStrokes(os.date("%d.%m.%y %H:%M"))
end)

hints.style="vimperator"
hints.showTitleThresh=10
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "W", "Vinduer", function() hints.windowHints(nil, centerMouseActiveWindow) end)

-- Show hotkeys place at midle of screen.
-- hs.hotkey.showHotkeys({"cmd", "ctrl", "alt"}, "S")
hs.hotkey.alertDuration = 0


-- Config reloading

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")