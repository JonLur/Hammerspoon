-------------------------
-- Hammerspoon config
-- File: funksjoner.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2024.10.19
-- Version: 3.0.4
------------------------

applicationFocusControl = false

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
  local currentapp, currentwindow

  if applicationFocusControl then
    -- logApplicationWatcher(appName, eventType)
    if eventType == hs.application.watcher.activated then
      currentwindow = hs.window.focusedWindow()
      currentapp = currentwindow:application()
      if appName == currentapp:name() then
        centerMouseActiveWindow(currentwindow)
        spoon.MouseCircle:show()
      end
    end
    watcher:stop()
    applicationFocusControl = false
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
  return string.match( string.match(s, "^%s*(.*)"), "(.-)%s*$")
end


function left_trim(s)
  return string.match(s, "^%s*(.*)")
end


function right_trim(s)
  return string.match(s,"(.-)%s*$")
end


function time_diff_in_minutes(time2)
  return function(time1)
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


function MondayInWeekInSeconds(year)
  return function(week)
      local FirstMondayInYearInSeconds = FirstMondayInSeconds(year)
      local SecondsToWeek = ((week - 1) * 7) * 60 * 60 * 24

      return FirstMondayInYearInSeconds + SecondsToWeek
  end
end


function MondayInWeekYYYYMMDDHHMMSS(year)
  return function(week)
      local seconds = MondayInWeekInSeconds(year)(week)
      return os.date("%Y%m%d000000", seconds)
  end
end


function MondayInWeekTable(year)
  return function(week)
      local seconds = MondayInWeekInSeconds(year)(week)
      return os.date("*t", seconds)
  end
end


function FirstMondayInSeconds( year )
  local JanuaryFirst = os.time{year = year, month = 1, day = 1}
  local JanuaryFirstDayOfWeek = tonumber(os.date("%w", JanuaryFirst))
  if (JanuaryFirstDayOfWeek == 0) then
    DayOfWeek = 7
  else
    DayOfWeek = JanuaryFirstDayOfWeek
  end
  if (DayOfWeek == 1) then
    DaysToFirstMonday = 0
  elseif ((DayOfWeek > 1) and (DayOfWeek <= 4)) then
    DaysToFirstMonday = (DayOfWeek - 1) * (-1)
  else
    DaysToFirstMonday = 8 - DayOfWeek
  end
  return JanuaryFirst + (DaysToFirstMonday * 60 * 60 * 24)
end


function FirstMondayYYYYMMDDHHMMSS( year )
  return os.date("%Y%m%d000000", FirstMondayInSeconds( year ))
end


function FirstMondayTable( year )
  return os.date("*t",FirstMondayInSeconds( year ))
end


function FirstDayOfWeekInSeconds( ostime )
  -- Just handle norwegian calendar. Monday is first day of week
  local DayOfWeek = tonumber(os.date("%w", ostime))
  if DayOfWeek == 0 then
    DayOfWeek = 7
  end

  local secondsUntilFirstDay = (DayOfWeek - 1) * 60 * 60 * 24
  local firstDayTimestamp = ostime - secondsUntilFirstDay
  local FirstDayOfWeek = os.date("*t", firstDayTimestamp)
  FirstDayOfWeek["hour"] = 0
  FirstDayOfWeek["min"] = 0
  FirstDayOfWeek["sec"] = 0
  return os.time(FirstDayOfWeek)
end


function FirstDayOfWeekDayOfYear( ostime )
  return os.date("%j", FirstDayOfWeekInSeconds(ostime))
end


function FirstDayOfWeekYYYYMMDDHHMMSS( ostime )
  return os.date("%Y%m%d000000", FirstDayOfWeekInSeconds(ostime))
end


function FirstDayOfWeekTable( ostime )
  return os.date("*t", FirstDayOfWeekInSeconds(ostime))
end


function HelpText( AppName )
  return AppName
end


function KeyHotKey( HotKey )
  return HotKey
end


function KeyModifier( Modifier )
  if Modifier == "CtrlAlt" then
    return {"ctrl", "alt"}
  elseif Modifier == "CtrlAltCmd" then
    return {"ctrl", "alt", "cmd"}
  else
    return nil
  end
end


function ApplicationFocus( AppName )
  return function ()
    watcher:start()
    applicationFocusControl = true
    if not hs.application.launchOrFocus( AppName ) then
      hs.application.launchOrFocusByBundleID( AppName )
    end
  end
end


function InternetSearch( AppName )
  -- Run Chrome and open new tab for searching
  return function()
    hs.application.launchOrFocus( AppName )
    hs.eventtap.keyStroke({"cmd"}, "T")
  end
end


function CopyPasteboard()
  return function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  end
end


function CopyPasteboardWork()
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


function InOmniFocus( Command )
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


function LockScreen()
  return function()
    -- Lock screen
    hs.caffeinate.startScreensaver()
  end
end


function InsertDate()
  return function()
    hs.eventtap.keyStrokes(os.date("%d.%m.%y %H:%M"))
  end
end


function WindowHints()
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


function StandardOpening( AppNamesMonitor )
  return function()
    if (#AppNamesMonitor > 0) then
      local skjermer = hs.screen.allScreens()

      for i, v in ipairs(AppNamesMonitor) do
        App = v
        array = {}
        for j, w in ipairs(App) do
          array[j] = w
        end
        if not hs.application.launchOrFocus(array[1]) then
          
        end
      end

      if #skjermer == 2 then
        -- "C34J79x", "BenQ BL2400", "BenQ G2420HD", "PHL 272S4L" "(un-named screen)"
        -- if not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
        -- if not (string.find(skjermer[2]:name(), "BenQ BL2400") == nil) then
          for i, v in ipairs(AppNamesMonitor) do
            app = v[1]
            skjerm = v[2]
            application = hs.application.open(app)
            print(app)
            win = application:focusedWindow()
            if not (win == nil) then
              -- When Lastpass needs login it returns "nil"
              win:moveToScreen(skjermer[skjerm], true)
            end
          end
        -- end
      end
    end
  end
end


function UpperAllText(TextArray)
  local words = {}
  local index = 1

  local function ToUpper(a)
    if a[index] ~= nil then
      table.insert(words, string.upper(a[index]))
      index = index + 1
      return ToUpper(a)
    else
      return words
    end
  end
  return ToUpper(TextArray)
end