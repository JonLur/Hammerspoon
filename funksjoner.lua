-------------------------
-- Hammerspoon config
-- File: funksjoner.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.11.19
-- Version: 2.0.1
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