-- Helper for network change
function ssidChangedCallback(...)
    local arg={...}
    local homeSSID=false
    newSSID = hs.wifi.currentNetwork()
    if (arg[2] == "SSIDChange") then
      if (homeSSID1 == newSSID) or (homeSSID2 == newSSID) then
        homeSSID=true
      end
      if (homeSSID) then
          if not ((homeSSID1 == lastSSID) or (homeSSID2 == lastSSID)) then
            hs.application.launchOrFocus("Sonos")
          end
      else
        if (hs.application.find("Sonos") ~= nil) then
          hs.application.launchOrFocus("Sonos")
          hs.eventtap.keyStroke({"cmd"}, "Q")
        end
      end
    end

    lastSSID = newSSID
end


--- Wifi - home - open Sonos.
-- Lag homeSSID til array og generisk
wifiWatcher = nil
homeSSID1 = "4G-Gateway-4526"
homeSSID2 = "4G-Gateway-4526-5G"
lastSSID = hs.wifi.currentNetwork()
wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
