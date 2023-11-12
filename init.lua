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

-- hs.loadSpoon("SendToOmniFocus")
-- spoon.SendToOmniFocus.notifications = false
-- spoon.SendToOmniFocus:bindHotkeys({send_to_omnifocus={{"ctrl", "alt"}, "G"}})

-- hs.loadSpoon("SpoonInstall")
-- spoon.SpoonInstall.repos.skrypka = {
--   url = "https://github.com/skrypka/Spoons",
--   desc = "Skrypka's spoon repository",
-- }
-- spoon.SpoonInstall.use_syncinstall = true
-- spoon.SpoonInstall:andUse("PushToTalk", {
--  start = true,
--  config = {
--    app_switcher = { ['zoom.us'] = 'push-to-talk' }
--  }
-- })

-- hs.loadSpoon("DeepLTranslate")
-- spoon.DeepLTranslate:bindHotkeys({translate={{"ctrl", "alt"}, "E"}} )

-- hs.hotkey.bind({"ctrl", "alt"}, "E", "DeepLTranslate", function()
--   spoon.DeepLTranslate:translateSelectionPopup()
-- end)
-- spoon.PushToTalk.app_switcher = { ['zoom.us'] = 'push-to-talk' }

--- hs.loadSpoon("ToggleSkypeMute")
--- spoon.ToggleSkypeMute.bindHotkeys({{"ctrl", "alt"}, "Z"})
--- hs.hotkey.bind({"ctrl", "alt"}, "Z", "Skype mute", function()
---    spoon.ToggleSkypeMute.toggle("Skype for Business")
--- end)

-- Get and print the serial number
result, serial_number = hs.osascript.applescript("set serialNumber to do shell script \"system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'\"")
if not result then
  print("Error retrieving serialnumber")
  serial_number = nil
end

require('funksjoner')
require('cheatsheets')
require('evoluent')
require('battery')
require('dagliglogg')
--- require('jumpcut')
--- require('position')
--- require('hotkeys')
--- require('pomodoro')
--- require('simplemind')

if (serial_number == "C02DW1QNQ6L5" ) then
  require('hjemmemaskin')
elseif (serial_number == "C02G945EQ6LR") then
  require('jobbmaskin')
end

hints = require "hs.hints"
watcher = nil

watcher = hs.application.watcher.new(applicationWatcher)


--- Applications
-- Run OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "O", "OmniFocus", function()
    hs.application.launchOrFocus("OmniFocus")
    watcher:start()
end)

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
hs.hotkey.bind({"ctrl", "alt"}, "N", "Note to last modified task OmniFocus", function()
  hs.osascript.applescriptFromFile("omnifocus-note.applescript")
end)

-- Save URL and title from Chrome/Safari to OmniFocus
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", "URL to OmniFocus", function()
hs.osascript.applescriptFromFile("url-to-omnifocus.applescript")
end)

-- Run LastPass
hs.hotkey.bind({"ctrl", "alt"}, "L", "LastPass", function()
    hs.application.launchOrFocus("LastPass")
    watcher:start()
end)

-- Run iTerm
hs.hotkey.bind({"ctrl", "alt"}, "I", "iTerm2", function()
    hs.application.launchOrFocus("iTerm")
    watcher:start()
end)


-- Run PreView
hs.hotkey.bind({"ctrl", "alt"}, "P", "PreView", function()
    hs.application.launchOrFocus("Preview")
    watcher:start()
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
