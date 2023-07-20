function doubleClick(e)
  local pos=hs.mouse.getAbsolutePosition()
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos):setProperty(hs.eventtap.event.properties.mouseEventClickState, 2):post()
  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos):post()
end

function mouseTrapper(event)
--driveren fra Evoluent er ikke god - så den er nå avinstallert og jeg har laget min egen logikk.
  if (event:getType() == hs.eventtap.event.types.otherMouseDown) then
    local mouseEvent = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    if (mouseEvent == 2) then
      --hs.eventtap.leftClick(hs.mouse.getAbsolutePosition())
      --local pos=hs.mouse.getAbsolutePosition()
      --hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos):setProperty(hs.eventtap.event.properties.mouseEventClickState, 2):post()
      --socket.sleep(1)
      --hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos):post()
      --print(os.time())
      --socket.sleep(1)
      --print(os.time())
      --hs.eventtap.leftClick(hs.mouse.getAbsolutePosition())
      doubleClick()
    elseif (mouseEvent == 3) then
      hs.eventtap.keyStroke({"cmd","alt"}, "8")
    elseif (mouseEvent == 5) then
      hs.eventtap.keyStroke({"cmd","alt"}, "9")
    end
  end
  return true
end

aMouseTrapper = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown, hs.eventtap.event.types.otherMouseUp}, mouseTrapper):start()

usbMouseWatcher = nil

function usbDeviceCallback(data)
  if (data["productName"] == "Evoluent VerticalMouse 4") then
    if (data["eventType"] == "added") then
      aMouseTrapper:start()
    elseif (data["eventType"] == "removed") then
      aMouseTrapper:stop()
    end
  end
end

usbMouseWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbMouseWatcher:start()
