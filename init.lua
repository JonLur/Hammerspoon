hs = _ENV.hs
spoon = _ENV.spoon
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
--  url = "https://github.com/skrypka/Spoons",
--  desc = "Skrypka's spoon repository",
--}
--spoon.SpoonInstall.use_syncinstall = true
--spoon.SpoonInstall:andUse("PushToTalk", {
--  start = true,
--  config = {
--    app_switcher = { ['zoom.us'] = 'push-to-talk' }
--  }
--})
-- spoon.PushToTalk.app_switcher = { ['zoom.us'] = 'push-to-talk' }

--- hs.loadSpoon("ToggleSkypeMute")
--- spoon.ToggleSkypeMute.bindHotkeys({{"ctrl", "alt"}, "Z"})
--- hs.hotkey.bind({"ctrl", "alt"}, "Z", "Skype mute", function()
---    spoon.ToggleSkypeMute.toggle("Skype for Business")
--- end)

hs.loadSpoon("DeepLTranslate")
spoon.DeepLTranslate:bindHotkeys({translate={{"ctrl", "alt", "cmd" }, "O" }})


--- require('jumpcut')
--- require('position')
require('cheatsheets')
--- require('hotkeys')
--- require('artsnavn')
require('evoluent')
require('battery')
require('dagliglogg')
--require('pomodoro')
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

function imgKeyboardOption()
    if not imgkeyboard then
      mousepoint = hs.mouse.getAbsolutePosition()
      imgkeyboard = hs.drawing.image(hs.geometry.rect(mousepoint.x,mousepoint.y,500,193), "Images/keyboard-with-option.png" )
      imgkeyboard:show()
      -- Set a timer to delete the circle after 3 seconds
      -- hs.timer.doAfter(5, function() img:delete() end)
    else
      imgkeyboard:delete()
      imgkeyboard = nil
    end
end


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

-- Run Mail, OmniFocus, Edge, Skype, Teams, RDP
hs.hotkey.bind({"ctrl", "alt"}, "A", "Standard åpninger", function()
    local skjermer = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    local sted = "hjemme"

    if not (skjermer[1] == nil) then print(skjermer[1]) end
    if not (skjermer[2] == nil) then print(skjermer[2]) end
    if not (skjermer[3] == nil) then print(skjermer[3]) end

    hs.application.launchOrFocus("Microsoft Outlook")
    hs.application.launchOrFocus("OmniFocus")
    hs.application.launchOrFocus("Microsoft Edge")
    hs.application.launchOrFocus("Microsoft Remote Desktop")
--  hs.application.launchOrFocus("Microsoft Teams")
    hs.application.launchOrFocus("Microsoft Teams (work preview)")
    hs.application.launchOrFocus("Microsoft OneNote")
    hs.application.launchOrFocus("Lastpass")
--     hs.application.launchOrFocus("Safari")

    os.execute("sleep " .. tonumber(5))

    if #skjermer == 3 then
-- Sannsynligvis i Brumunddal
--       if not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
      if not (string.find(skjermer[2]:name(), "PHL 272S4L") == nil) then
        sted = "Brumunddal"
      end
    elseif #skjermer == 2 then
      if not (string.find(skjermer[2]:name(), "(un-named screen)") == nil) then
        sted = "iPad"
--      elseif not (string.find(skjermer[2]:name(), "BenQ G2420HD") == nil) then
--      elseif not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
      elseif not (string.find(skjermer[2]:name(), "BenQ BL2400") == nil) then
        sted = "Halmhuset"
      elseif not (string.find(skjermer[2]:name(), "PHL 272S4L") == nil) then
        sted = "Brumunddal"
      end
    end
    print("Sted: " .. sted)

    if sted == "Brumunddal" then
-- hs.application.launchOrFocus("Microsoft Outlook")
-- hs.application.launchOrFocus("OmniFocus")
     hs.application.launchOrFocus("Microsoft Edge")

   os.execute("sleep " .. tonumber(1))
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     hs.application.launchOrFocus("Microsoft Remote Desktop")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
--     hs.application.launchOrFocus("Microsoft Teams")
--     win = hs.window.focusedWindow()
--     win:moveToScreen(skjermer[2], true)
--     win = nil
     hs.application.launchOrFocus("Microsoft OneNote")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
     hs.application.launchOrFocus("Lastpass")
-- If Lastpass needs login it returns "nil"
     win = hs.window.focusedWindow()
     if not (win == nil) then
       win:moveToScreen(skjermer[3], true)
       win = nil
     end
   elseif sted == "iPad" then
   elseif sted == "Halmhuset" then
     hs.application.launchOrFocus("Microsoft Edge")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
     hs.application.launchOrFocus("Microsoft Remote Desktop")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
--     hs.application.launchOrFocus("Microsoft Teams")
--     win = hs.window.focusedWindow()
--     win:moveToScreen(skjermer[1], true)
--     win = nil
     hs.application.launchOrFocus("Microsoft OneNote")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
     hs.application.launchOrFocus("Microsoft Outlook")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[1], true)
     win = nil
     hs.application.launchOrFocus("OmniFocus")
     win = hs.window.focusedWindow()
     win:moveToScreen(skjermer[2], true)
     win = nil
     hs.application.launchOrFocus("Lastpass")
-- If Lastpass needs login it returns "nil"
     win = hs.window.focusedWindow()
     if not (win == nil) then
       win:moveToScreen(skjermer[2], true)
       win = nil
     end
   end
end)

--- Applications
-- Add note to OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "C", "Copy to last modified task OmniFocus", function()
    hs.osascript.applescriptFromFile("omnifocus-note.applescript")
end)

-- Run Edge
hs.hotkey.bind({"ctrl", "alt"}, "E", "Edge", function()
    hs.application.launchOrFocus("Microsoft Edge")
    watcher:start()
end)

-- Search remaining in OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "F", "Remaining in OmniFocus", function()
  local app
  app = hs.application.get("OmniFocus")
  app:activate()
  app:selectMenuItem("Search Remaining")
end)

-- Run Chrome and open new tab for searching
-- hs.hotkey.bind({"ctrl", "alt"}, "F", "Internet search", function()
--     hs.application.launchOrFocus("Microsoft Edge")
--     hs.eventtap.keyStroke({"cmd"}, "T")
-- end)

-- Add highlited to OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "H", "Copy selected to OmniFocus", function()
    hs.eventtap.keyStroke({"cmd"}, "C")
    hs.eventtap.keyStroke({"ctrl", "alt"}, "space")
    delayedPasteWithoutReturn()
end)

-- Run Finder
-- hs.hotkey.bind({"ctrl", "alt"}, "I", "Finder", function()
--     hs.application.launchOrFocus("Finder")
--     watcher:start()
-- end)

-- Add logg note with duration to OmniFocus
-- hs.hotkey.bind({"ctrl", "alt"}, "J", "Dagliglogg to OmniFocus", function()
--     hs.osascript.applescriptFromFile("dagliglogg-to-omnifocus.applescript")
-- end)
-- Add logg note with duration to SqLite3
hs.hotkey.bind({"ctrl", "alt"}, "D", "Dagliglogg to Sqlite3", function()
  dagliglogg_ny()
end)

-- Run LastPass
hs.hotkey.bind({"ctrl", "alt"}, "L", "LastPass", function()
    hs.application.launchOrFocus("LastPass")
    watcher:start()
end)

-- Run Mail
hs.hotkey.bind({"ctrl", "alt"}, "M", "Outlook", function()
    hs.application.launchOrFocus("Microsoft Outlook")
    watcher:start()
end)

-- Run Microsoft OneNote
hs.hotkey.bind({"ctrl", "alt"}, "N", "OneNote", function()
    hs.application.launchOrFocus("Microsoft OneNote")
    watcher:start()
end)

-- Run OmniFocus
hs.hotkey.bind({"ctrl", "alt"}, "O", "OmniFocus", function()
    hs.application.launchOrFocus("OmniFocus")
    watcher:start()
end)

-- Run Microsoft Remote Desktop
hs.hotkey.bind({"ctrl", "alt"}, "R", "Remote Desktop", function()
    -- menuAction = {"Window","View Connection Center"}
    hs.application.launchOrFocus("Microsoft Remote Desktop")
    -- mrdp = hs.appfinder.appFromName("Microsoft Remote Desktop")
    -- mrdp:selectMenuItem(menuAction)
    watcher:start()
end)

-- Run Stickies
hs.hotkey.bind({"ctrl", "alt"}, "S", "Stickies", function()
    hs.application.launchOrFocus("Stickies")
    watcher:start()
end)

-- Run Safari
-- hs.hotkey.bind({"ctrl", "alt"}, "S", "Safari", function()
--     hs.application.launchOrFocus("Safari")
--     watcher:start()
-- end)

-- Run Microsoft Teams
--hs.hotkey.bind({"ctrl", "alt"}, "T", "Microsoft Teams", function()
--    hs.application.launchOrFocus("Microsoft Teams")
--    watcher:start()
--end)

-- Run Microsoft Teams (work preview)
hs.hotkey.bind({"ctrl", "alt"}, "T", "Microsoft Teams", function()
    hs.application.launchOrFocus("Microsoft Teams (work preview)")
    watcher:start()
end)

-- Run Skype for Business
--hs.hotkey.bind({"ctrl", "alt"}, "Y", "Skype", function()
--    hs.application.launchOrFocus("Skype for Business")
--    watcher:start()
--end)

-- Save URL and title from Chrome/Safari to OmniFocus
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", "URL to OmniFocus", function()
    hs.osascript.applescriptFromFile("url-to-omnifocus.applescript")
end)

-- Save scpt as applescript to OmniFocus
--hs.hotkey.bind({"ctrl", "alt", "cmd"}, "A", "Save also as applescript", function()
--    hs.osascript.applescriptFromFile("save-applescript-as-text.applescript")
--end)

-- Keyboard Option Helper
hs.hotkey.bind({"ctrl","alt","cmd"}, "H", "Keyboard helper", imgKeyboardOption)

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

-- Tea notifications
hs.hotkey.bind({"ctrl", "alt"}, "K", "Kaffi 5 minutter", function()
  hs.alert.show(" kaffi om 5 minutter", 1.0)
  hs.timer.doAfter(300, function()
--    hs.notify.new({title="Zen",
--      informativeText="~~~ kaffi er klar ~~~",
--      autoWithdraw=false}):send()
      hs.alert.show("~~~ kaffi er klar ~~~",30)
    end)
end)


-- Kopier
hs.hotkey.bind({"ctrl", "alt"}, "V", "Copy pasteboard", function()
  local activeWindow, activeApplication
-- Set keyboard to UniCode - needed for Microsoft Remote Desktop
  hs.eventtap.keyStroke({"ctrl", "cmd"}, "U")
  activeWindow=hs.window.focusedWindow()
  activeApplication=activeWindow:application()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents(),activeApplication)
  -- hs.eventtap.keyStroke({}, "return")
  -- Set keyboard to ScanCode - needed for Microsoft Remote Desktop
  hs.eventtap.keyStroke({"ctrl", "cmd"}, "K")
end)

-- Tastetrykk for å hoppe til åpne applikasjoner og plassere
--  musepeker midt i det valgte vinduet.
function centerMouseActiveWindow(window)
  local frame, nypos
  frame=window:frame()
  nypos={x=frame.x + frame.w / 2, y=frame.y + frame.h / 2 }
  hs.mouse.absolutePosition(nypos)
end

function all_trim(s)
  return s:match"^%s*(.*)":match"(.-)%s*$"
end

function time_diff_in_minutes(time1, time2)
-- time1 and time2 needs to be in format YYYYMMDDHHMMSS
-- Define two timestamps as tables with year, month, day, hour, min, sec fields
  local t1 = time_from_string(time1)
  local t2 = time_from_string(time2)

-- Convert the tables to numbers using os.time
  local n1 = os.time(t1)
  local n2 = os.time(t2)

-- Calculate the difference in seconds using os.difftime
  local seconds = os.difftime(n2, n1)

  local minutes = seconds // 60
  local x1 = seconds % 60
  if (x1 >= 30) then 
    minutes = minutes + 1
  end

  return minutes
end

function time_from_string(time)
-- t1 needs to be in format YYYYMMDDHHMMSS
  t1 = {}
  t1["year"] = tonumber(string.sub(time,1,4))
  t1["month"] = tonumber(string.sub(time,5,6))
  t1["day"] = tonumber(string.sub(time,7,8))
  t1["hour"] = tonumber(string.sub(time,9,10))
  t1["min"] = tonumber(string.sub(time,11,12))
  t1["sec"] = tonumber(string.sub(time,13,14))

  return t1
end


hints.style="vimperator"
hints.showTitleThresh=10
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "W", "Vinduer", function() hints.windowHints(nil, centerMouseActiveWindow) end)

-- Show hotkeys place at midle of screen.
-- hs.hotkey.showHotkeys({"cmd", "ctrl", "alt"}, "S")
hs.hotkey.alertDuration = 0

--detectMouseDown = hs.eventtap.new({
--  hs.eventtap.event.types.otherMouseDown,
--  hs.eventtap.event.types.leftMouseDown,
--  hs.eventtap.event.types.rightMouseDown
--}, function(e)
--  local button = e:getProperty(
--      hs.eventtap.event.properties['mouseEventButtonNumber']
--  )
--  window = hs.window.focusedWindow()
--  windowtitle = window:title()
--  print(windowtitle)
--  if ((string.match(windowtitle, "Microsoft Edge")) or (string.match(windowtitle, "Google Chrome"))) then
--    if (button == 3) then
--      print(string.format("Clicked Mouse Button: %i", button))
--      hs.keycodes.setLayout("U.S.")
--      hs.eventtap.keyStroke({"cmd"}, ";")
--      hs.keycodes.setLayout("Norwegian")
--    end
--  end
--end)

--detectMouseDown:start()


-- Config reloading

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
