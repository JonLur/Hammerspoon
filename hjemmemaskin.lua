-------------------------
-- Hammerspoon config
-- File: hjemmemaskin.lua
-- Author: Jon Lurås
-- Date: 2023.11.12
-- Version: 2.0
------------------------

require('artsnavn')

-- Run Mail, OmniFocus, Chrome, Skype, Teams, RDP
function StandardOpening ( AppNames )
  return function()
    local skjermer = hs.screen.allScreens()

    for i, v in ipairs(AppNames) do
      hs.application.launchOrFocus(v)
    end

    if #skjermer == 2 then
      if not (string.find(skjermer[2]:name(), "C34J79x") == nil) then
        application = hs.application.open("Google Chrome")
        win = application:focusedWindow()
        win:moveToScreen(skjermer[2], true)
        win = nil
        application = hs.application.open("OmniFocus")
        win = application:focusedWindow()
        win:moveToScreen(skjermer[1], true)
        win = nil
      end
    end
  end
end

-- Run Chrome and open new tab for searching
function InternetSearch ( AppName )
  return function()
    hs.application.launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({"cmd"}, "T")
  end
end

function CopyPasteboard ( Command )
  return function()
    if Command == "Paste" then
      hs.eventtap.keyStrokes(hs.pasteboard.getContents())
    end
  end
end

--- Applications
StandardStart = {"Google Chrome", "OmniFocus"}
MyHotKeys = {}
MyHotKeys[1] = {KeyCtrlAlt("C"), HelpText("Chrome"), ApplicationFocus("Google Chrome")}
MyHotKeys[2] = {KeyCtrlAlt("D"), HelpText("Darktable"), ApplicationFocus("darktable")}
MyHotKeys[3] = {KeyCtrlAlt("W"), HelpText("iA Writer"), ApplicationFocus("iA Writer")}
MyHotKeys[4] = {KeyCtrlAlt("Z"), HelpText("zoom.u"), ApplicationFocus("zoom.u")}
MyHotKeys[5] = {KeyCtrlAlt("M"), HelpText("Messenger"), ApplicationFocus("Messenger")}
MyHotKeys[6] = {KeyCtrlAlt("T"), HelpText("SimpleMind"), ApplicationFocus("SimpleMind Pro")}
MyHotKeys[7] = {KeyCtrlAlt("K"), HelpText("GitKraken"), ApplicationFocus("GitKraken")}
MyHotKeys[8] = {KeyCtrlAlt("S"), HelpText("Internet search"), InternetSearch("Google Chrome")}
MyHotKeys[9] = {KeyCtrlAlt("V"), HelpText("Copy pasteboard"), CopyPasteboard("Paste")}
MyHotKeys[10] = {KeyCtrlAlt("A"), HelpText("Standard åpninger"), StandardOpening(StandardStart)}

for i, v in ipairs(MyHotKeys) do
  HotKey = v
  array = {}
  for j, w in ipairs(HotKey) do
    array[j] = w
  end
  hs.hotkey.bind({"ctrl", "alt"}, array[1], array[2], array[3])
end