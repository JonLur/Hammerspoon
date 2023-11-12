-------------------------
-- Hammerspoon config
-- File: jobbmaskin.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Version: 2.0
------------------------

hs.loadSpoon("DeepLTranslate")
spoon.DeepLTranslate:bindHotkeys({translate={{"ctrl", "alt", "cmd" }, "O" }})


local hints = require "hs.hints"
watcher = nil

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

-- Run Edge
hs.hotkey.bind({"ctrl", "alt"}, "E", "Edge", function()
    hs.application.launchOrFocus("Microsoft Edge")
    watcher:start()
end)

-- Run Chrome and open new tab for searching
-- hs.hotkey.bind({"ctrl", "alt"}, "F", "Internet search", function()
--     hs.application.launchOrFocus("Microsoft Edge")
--     hs.eventtap.keyStroke({"cmd"}, "T")
-- end)


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


-- Run Microsoft Remote Desktop
hs.hotkey.bind({"ctrl", "alt"}, "R", "Remote Desktop", function()
    -- menuAction = {"Window","View Connection Center"}
    hs.application.launchOrFocus("Microsoft Remote Desktop")
    -- mrdp = hs.appfinder.appFromName("Microsoft Remote Desktop")
    -- mrdp:selectMenuItem(menuAction)
    watcher:start()
end)

-- Run Microsoft Teams (work preview)
hs.hotkey.bind({"ctrl", "alt"}, "T", "Microsoft Teams", function()
    hs.application.launchOrFocus("Microsoft Teams (work preview)")
    watcher:start()
end)

-- Keyboard Option Helper
hs.hotkey.bind({"ctrl","alt","cmd"}, "H", "Keyboard helper", imgKeyboardOption)

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