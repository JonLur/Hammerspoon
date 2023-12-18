-------------------------
-- Hammerspoon config
-- File: funksjoner.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.12.18
-- Version: 3.0.0
------------------------

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

function getFirstDateOfWeek(year, week)

  daysToTargetWeek = (week - 1) * 7

  januaryFirst = os.time{year = year, month = 1, day = 1}
  DateOfWeek = tonumber(os.date("%w", januaryFirst))
  if ((DateOfWeek >= 1) and (DateOfWeek <= 4)) then
    daysToFirstMonday = (DateOfWeek - 1) * (-1)
    firstDateOfWeek = januaryFirst + ((daysToFirstMonday + daysToTargetWeek) * 24 * 60 * 60)
  else
    daysToFirstMonday = (8 - DateOfWeek) % 7
    firstDateOfWeek = januaryFirst + ((daysToFirstMonday + daysToTargetWeek) * 24 * 60 * 60)
  end

  return firstDateOfWeek
  
end

function HelpText ( AppName )
  return AppName
end

function KeyHotKey ( HotKey )
  return HotKey
end

function KeyModifier ( Modifier )
  if Modifier == "CtrlAlt" then
    return {"ctrl", "alt"}
  elseif Modifier == "CtrlAltCmd" then
    return {"ctrl", "alt", "cmd"}
  else
    return nil
  end
end

function ApplicationFocus ( AppName )
  return function ()
    hs.application.launchOrFocus( AppName)
    watcher:start()
  end
end

-- Run Chrome and open new tab for searching
function InternetSearch ( AppName )
  return function()
    hs.application.launchOrFocus( AppName )
    hs.eventtap.keyStroke({"cmd"}, "T")
  end
end

function CopyPasteboard ()
  return function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  end
end

function CopyPasteboardWork ()
  return function()
    local activeWindow, activeApplication
    -- Set keyboard to UniCode - needed for Microsoft Remote Desktop
    hs.eventtap.keyStroke({"ctrl", "cmd"}, "U")
    activeWindow=hs.window.focusedWindow()
    activeApplication=activeWindow:application()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents(),activeApplication)
    -- hs.eventtap.keyStroke({}, "return")
    -- Set keyboard to ScanCode - needed for Microsoft Remote Desktop
    hs.eventtap.keyStroke({"ctrl", "cmd"}, "K")
  end
end

function InOmniFocus ( Command )
  return function()
    if Command == "FindIn" then
    -- Search remaining in OmniFocus
      app = hs.application.get("OmniFocus")
      app:activate()
      app:selectMenuItem("Search Remaining")
    elseif Command == "CopyTo" then
      -- Add highlited to OmniFocus
      hs.eventtap.keyStroke({"cmd"}, "C")
      hs.eventtap.keyStroke({"ctrl", "alt"}, "space")
      delayedPasteWithoutReturn()
    elseif Command == "NoteTo" then
      -- Add to last modified
      hs.osascript.applescriptFromFile("omnifocus-note.applescript")
    elseif Command == "URLTo" then
      -- Save URL and title from Chrome/Safari to OmniFocus
      hs.osascript.applescriptFromFile("url-to-omnifocus.applescript")
    end
  end
end

function ToDagliglogg ( Command )
  return function()
    if Command == "SendTo" then
      -- Add logg note with duration to sqlite3 database
      dagliglogg_ny()
    end
  end
end

function LockScreen ()
  return function()
    -- Lock screen
    hs.caffeinate.startScreensaver()
  end
end

function InsertDate ()
  return function()
    hs.eventtap.keyStrokes(os.date("%d.%m.%y %H:%M"))
  end
end

function WindowHints ()
  return function()
    hints.style="vimperator"
    hints.showTitleThresh=10
    hints.windowHints(nil, centerMouseActiveWindow)
  end
end

function imgKeyboardOption()
  return function()
    if not imgkeyboard then
      mousepoint = hs.mouse.getAbsolutePosition()
      imgkeyboard = hs.drawing.image(hs.geometry.rect(mousepoint.x,mousepoint.y,500,193), "Images/keyboard-with-option.png" )
      imgkeyboard:show()
    else
      imgkeyboard:delete()
      imgkeyboard = nil
    end
  end
end


function StandardOpening ( AppNamesMonitor )
  return function()
    if not (AppNames[1] == nil) then
      local skjermer = hs.screen.allScreens()

      for i, v in ipairs(AppNames) do
        hs.application.launchOrFocus(v)
      end

      if #skjermer == 2 then
        -- "C34J79x", "BenQ BL2400", "BenQ G2420HD", "PHL 272S4L" "(un-named screen)"
        if not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
          for i, v in ipairs(AppNamesMonitor) do
            App = v
            array = {}
            for j, w in ipairs(App) do
              array[j] = w
            end
            if array[1] == "Lastpass" then
              -- If Lastpass needs login it returns "nil"
              application = hs.application.open(array[1])
              win = application:focusedWindow()
              if not (win == nil) then
                win:moveToScreen(skjermer[array[2]], true)
              end
            else
              application = hs.application.open(array[1])
              win = application:focusedWindow()
              win:moveToScreen(skjermer[array[2]], true)
            end
          end
        end
      end
    end
  end
end