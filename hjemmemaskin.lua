-------------------------
-- Hammerspoon config
-- File: hjemmemaskin.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Version: 2.0
------------------------

require('artsnavn')

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

-- Run SimpleMind
hs.hotkey.bind({"ctrl", "alt"}, "T", "SimpleMind", function()
    hs.application.launchOrFocus("SimpleMind Pro")
end)

-- Run GitKraken
hs.hotkey.bind({"ctrl", "alt"}, "K", "GitKraken", function()
    hs.application.launchOrFocus("GitKraken")
    watcher:start()
end)

-- Run Final Cut Pro
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "F", "Final Cut Pro", function()
    hs.application.launchOrFocus("Final Cut Pro")
    watcher:start()
end)

-- Kopier
hs.hotkey.bind({"ctrl", "alt"}, "V", "Copy pasteboard", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)