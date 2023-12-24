-------------------------
-- Hammerspoon config
-- File: funksjoner.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Endret: 2023.12.23
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
    hs.application.launchOrFocus( AppName)
    watcher:start()
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


function ToDagliglogg( Command )
  return function()
    if Command == "SendTo" then
      local active_application = hs.application.frontmostApplication()

      db = hs.sqlite3.open(db_dagliglogg_directory .. db_dagliglogg_file)
      dagliglogg_ny(db)
      db:close()

      if not active_application:activate() then
        error_message = "Fikk ikke aktivert siste aktive applikasjon"
        print("Error:", error_message)
      end
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
    if not (AppNamesMonitor[1] == nil) then
      local skjermer = hs.screen.allScreens()

      for i, v in ipairs(AppNamesMonitor) do
        App = v
        array = {}
        for j, w in ipairs(App) do
          array[j] = w
        end
        hs.application.launchOrFocus(array[1])
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
            application = hs.application.open(array[1])
            win = application:focusedWindow()
            if not (win == nil) then
              -- When Lastpass needs login it returns "nil"
              win:moveToScreen(skjermer[array[2]], true)
            end
          end
        end
      end
    end
  end
end


function splitCommandFromSentence(sentence)
  local words = {}
  local SplittFirstNWords = 2

  local function splitHelper(str, nWords)
      streng = left_trim(str)
      local spaceIndex = string.find(streng, " ")

      if spaceIndex then
          local word = string.sub(streng, 1, spaceIndex - 1)
          table.insert(words, word)
          if nWords ~= #words then
            splitHelper(string.sub(streng, spaceIndex + 1), nWords)
          end
      else
          table.insert(words, streng)
      end
  end

  setning = right_trim(sentence)

  splitHelper(setning, SplittFirstNWords)

  return words
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


function time_formated(seconds)
  if seconds == nil then
    seconds = os.time()
  end
  return os.date("%Y%m%d%H%M%S", seconds)
end


function rapport_innstillinger_dag(dag)
  local aInnstillinger = {}

  aInnstillinger["start"] = os.date("%Y%m%d000000", dag)
  aInnstillinger["stopp"] = os.date("%Y%m%d000000", dag + (60*60*24))
  aInnstillinger["summering"] = true
  aInnstillinger["filnavn"] = os.date("%Y%m%d.txt", dag)

  return aInnstillinger
end


function rapport_innstillinger_uke(uke)
  local aInnstillinger = {}

  local start = FirstDayOfWeekInSeconds(uke)
  local stopp = start + (60*60*24*7)

  aInnstillinger["start"] = os.date("%Y%m%d000000", start)
  aInnstillinger["stopp"] = os.date("%Y%m%d000000", stopp)
  aInnstillinger["summering"] = false
  aInnstillinger["filnavn"] = os.date("%Yuke%W.txt", uke)

  return aInnstillinger
end


function rapport_innstillinger_mnd(mnd)
  local aInnstillinger = {}

  local year_start = tonumber(os.date("%Y", mnd))
  local month_start = tonumber(os.date("%m", mnd))
  local start = os.time({year = year_start, month = month_start, day = 1})
  if (month == 12) then
      year_stopp = year_start + 1
      month_stopp = 1
  else
      year_stopp = year_start
      month_stopp = month_start + 1
  end
  local stopp = os.time({year = year_stopp, month = month_stopp, day = 1})

  aInnstillinger["start"] = os.date("%Y%m%d000000", start)
  aInnstillinger["stopp"] = os.date("%Y%m%d000000", stopp)
  aInnstillinger["summering"] = false
  aInnstillinger["filnavn"] = os.date("%Ymnd%m.txt", mnd)

  return aInnstillinger
end


function get_time(word)
  -- If last is m/M/t/T then tid will be nil
  local tid = tonumber(word)

  if tid == nil then
    -- If last char is number or different from m/t then timeindex = 1
    local length_word = string.len(word)
    local format = string.upper(string.sub(word,length_word,length_word))
    local index
    local tid

    if (format == 'M') then
        index = 1
        tid = tonumber(string.sub(word,1,length_word-1))
    elseif (format == 'T') then
        index = 60
        tid = tonumber(string.sub(word,1,length_word-1))
    else
        -- timeformat is unknown character - then we set time to 0
        index = 1
        tid = 0
    end

    return tid * index
  else
    return tid
  end
end