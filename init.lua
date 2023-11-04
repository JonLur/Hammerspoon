--- Spoons
hs.loadSpoon("SendToOmniFocus")
spoon.SendToOmniFocus.notifications = false
spoon.SendToOmniFocus:bindHotkeys({send_to_omnifocus={{"ctrl", "alt"}, "G"}})
hs.loadSpoon("WindowScreenLeftAndRight")
spoon.WindowScreenLeftAndRight:bindHotkeys(spoon.WindowScreenLeftAndRight.defaultHotkeys)
hs.loadSpoon("MouseCircle")
spoon.MouseCircle:bindHotkeys({show={{"ctrl", "alt", "cmd"}, "M"}} )

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
-- Run LastPass
-- hs.hotkey.bind({"ctrl", "alt"}, "E", "DeepLTranslate", function()
--   spoon.DeepLTranslate:translateSelectionPopup()
-- end)
-- spoon.PushToTalk.app_switcher = { ['zoom.us'] = 'push-to-talk' }

--- hs.loadSpoon("ToggleSkypeMute")
--- spoon.ToggleSkypeMute.bindHotkeys({{"ctrl", "alt"}, "Z"})
--- hs.hotkey.bind({"ctrl", "alt"}, "Z", "Skype mute", function()
---    spoon.ToggleSkypeMute.toggle("Skype for Business")
--- end)

--- require('jumpcut')
--- require('position')
require('cheatsheets')
--- require('hotkeys')
require('artsnavn')
require('evoluent')
require('battery')
--require('pomodoro')
--require('simplemind')
local hints = require "hs.hints"
watcher = nil

--- socket = require('socket')

--- Support functions
-- Helper for pasting
function delayedPaste()
  hs.timer.doAfter(0.2, function()
                     hs.eventtap.keyStroke({"cmd"}, "V")
                     hs.eventtap.keyStroke({}, "return")
  end)
end

function delayedPasteWithoutReturn()
  hs.timer.doAfter(0.2, function()
                     hs.eventtap.keyStroke({"cmd"}, "V")
  end)
end

--- Just a comment
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

--function imgKeyboardOption()
--    if not imgkeyboard then
--      mousepoint = hs.mouse.getAbsolutePosition()
--      imgkeyboard = hs.drawing.image(hs.geometry.rect(mousepoint.x,mousepoint.y,500,193), "Images/keyboard-with-option.png" )
--      imgkeyboard:show()
--      Set a timer to delete the circle after 3 seconds
--      hs.timer.doAfter(5, function() img:delete() end)
--    else
--      imgkeyboard:delete()
--      imgkeyboard = nil
--    end
--end


function applicationWatcher(appName, eventType, app)
  -- logApplicationWatcher(appName, eventType)
  if eventType == hs.application.watcher.activated
  or eventType == hs.application.watcher.launched	then
    window = hs.window.focusedWindow()
    if window then
      centerMouseActiveWindow(window)
      watcher:stop()
    end
  end
end

watcher = hs.application.watcher.new(applicationWatcher)

function logApplicationWatcher(appName, eventType)
  if eventType == hs.application.watcher.activated then
    hs.printf(appName .. " activated")
  end
  if eventType == hs.application.watcher.deactivated then
    hs.printf(appName .. " deactivated")
  end
  if eventType == hs.application.watcher.hidden then
    hs.printf(appName .. " hidden")
  end
  if eventType == hs.application.watcher.launched then
    hs.printf(appName .. " launched")
  end
  if eventType == hs.application.watcher.launching then
    hs.printf(appName .. " launching")
  end
  if eventType == hs.application.watcher.terminated then
    hs.printf(appName .. " terminated")
  end
  if eventType == hs.application.watcher.unhidden then
    hs.printf(appName .. " unhidden")
  end
end

--- Keyboard, more later
-- hs.alert.show(hs.keycodes.currentLayout())

-- Run Mail, OmniFocus, Chrome, Skype, Teams, RDP
hs.hotkey.bind({"ctrl", "alt"}, "A", "Standard åpninger", function()
    local skjermer = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    local sted = "hjemme"

    print(skjermer[1])
    print(skjermer[2])
    print(skjermer[3])

    hs.application.launchOrFocus("OmniFocus")
    hs.application.launchOrFocus("Google Chrome")

    os.execute("sleep " .. tonumber(5))

    if #skjermer == 1 then
      sted = "MacbookAir"
    elseif #skjermer == 2 then
      if not (string.find(skjermer[2]:name(), "(un-named screen)") == nil) then
        sted = "iPad"
      elseif not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
        sted = "Halmhuset"
      end
    end
    print("Sted: " .. sted)

   if sted == "iPad" then
   elseif sted == "Halmhuset" then
     hs.application.launchOrFocus("Google Chrome")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
     hs.application.launchOrFocus("OmniFocus")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[1], true)
     win = nil
   elseif sted == "MacbookAir" then
     hs.application.launchOrFocus("Google Chrome")
     hs.application.launchOrFocus("OmniFocus")
   end
end)

--- Applications
-- Run OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "O", "OmniFocus", function()
    hs.application.launchOrFocus("OmniFocus")
    watcher:start()
end)

-- Run Chrome
hs.hotkey.bind({"ctrl", "alt"}, "C", "Chrome", function()
    hs.application.launchOrFocus("Google Chrome")
    watcher:start()
end)

-- Run Chrome and open new tab for searching
hs.hotkey.bind({"ctrl", "alt"}, "S", "Internet search", function()
    hs.application.launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({"cmd"}, "T")
end)

-- Run Darktable
hs.hotkey.bind({"ctrl", "alt"}, "D", "Darktable", function()
    hs.application.launchOrFocus("darktable")
    watcher:start()
end)

-- Run iA Writer
hs.hotkey.bind({"ctrl", "alt"}, "W", "iA Writer", function()
    hs.application.launchOrFocus("iA Writer")
    watcher:start()
end)

-- Run Zoom
hs.hotkey.bind({"ctrl", "alt"}, "Z", "zoom.us", function()
    hs.application.launchOrFocus("zoom.us")
    watcher:start()
end)

-- Run Messenger
hs.hotkey.bind({"ctrl", "alt"}, "M", "Messenger", function()
    hs.application.launchOrFocus("Messenger")
    watcher:start()
end)

-- Run Stickies
hs.hotkey.bind({"ctrl", "alt"}, "T", "SimpleMind", function()
    hs.application.launchOrFocus("SimpleMind Pro")
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

-- Run GitKraken
hs.hotkey.bind({"ctrl", "alt"}, "K", "GitKraken", function()
    hs.application.launchOrFocus("GitKraken")
    watcher:start()
end)

-- Run PreView
hs.hotkey.bind({"ctrl", "alt"}, "P", "PreView", function()
    hs.application.launchOrFocus("Preview")
    watcher:start()
end)

-- Run iA Writer
-- hs.hotkey.bind({"ctrl", "alt"}, "I", "iA Writer", function()
--     hs.application.launchOrFocus("iA Writer")
--     watcher:start()
-- end)

-- Run Final Cut Pro
--hs.hotkey.bind({"ctrl", "alt"}, "F", "Final Cut Pro", function()
--    hs.application.launchOrFocus("Final Cut Pro")
--    watcher:start()
--end)
-- Search remaing in OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "F", "Search remaining in OmniFocus", function()
    app = hs.application.get("OmniFocus")
    app:activate()
    app:selectMenuItem("Search Remaining")
end)

--hs.hotkey.bind({"ctrl", "alt"}, "P", "Atom to SimpleMind", atomtilsimplemind)

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

-- Add logg note with duration to OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "J", "Dagliglogg to OmniFocus", function()
    hs.osascript.applescriptFromFile("dagliglogg-to-omnifocus.applescript")
end)

-- Save URL and title from Chrome/Safari to OmniFocus
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", "URL to OmniFocus", function()
    hs.osascript.applescriptFromFile("url-to-omnifocus.applescript")
end)

-- Save scpt as applescript to OmniFocus
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "A", "Save also as applescript", function()
    hs.osascript.applescriptFromFile("save-applescript-as-text.applescript")
end)

-- Keyboard Option Helper
-- hs.hotkey.bind({"ctrl","alt","cmd"}, "H", "Keyboard helper", imgKeyboardOption)

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

-- Temp copy URL to Google cheatsheets
-- hs.hotkey.bind({"ctrl", "alt"}, "J", "URL til Sheet", function()
--     hs.eventtap.keyStroke({"cmd"}, "L")
--     hs.eventtap.keyStroke({"cmd"}, "C")
--     hs.eventtap.keyStroke({"ctrl", "shift"}, "tab")
--     hs.eventtap.keyStroke({"cmd"}, "K")
--     delayedPaste()
--     hs.timer.doAfter(1.0, function()
--                        hs.eventtap.keyStroke({}, "return")
--     end)
--     hs.timer.doAfter(3.0, function()
--                        hs.eventtap.keyStroke({"ctrl"}, "tab")
--     end)
--     hs.timer.doAfter(3.0, function()
--                       hs.eventtap.keyStroke({"cmd"}, "[")
--     end)
--  end)

-- Tea notifications
--hs.hotkey.bind({"ctrl", "alt"}, "K", "Kaffi 5 minutter", function()
--    hs.alert.show(" kaffi", 1.0)
--    hs.timer.doAfter(300,
--                     function()
--                       hs.notify.new({title="Zen",
--                                      informativeText="~~~ kaffi er klar ~~~",
--                                      autoWithdraw=false}):send()
--    end)
--end)

-- Kopier
hs.hotkey.bind({"ctrl", "alt"}, "V", "Copy pasteboard", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Tastetrykk for å hoppe til åpne applikasjoner og plassere
--  musepeker midt i det valgte vinduet.
function centerMouseActiveWindow(window)
  frame=window:frame()
  nypos={x=frame.x + frame.w / 2, y=frame.y + frame.h / 2 }
  hs.mouse.setRelativePosition(nypos)
end

hints.style="vimperator"
hints.showTitleThresh=10
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "W", "Vinduer", function() hints.windowHints(nil, centerMouseActiveWindow) end)

-- Show hotkeys place at midle of screen.
-- hs.hotkey.showHotkeys({"cmd", "ctrl", "alt"}, "S")
hs.hotkey.alertDuration = 0


-- Config reloading

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
