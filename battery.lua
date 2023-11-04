-- Battery
--------------------------------------------------
-- Handler directly called by the "low-level" watcher API.
--------------------------------------------------
function batt_watch_low()
  pct = hs.battery.percentage()
  minutes = hs.battery.timeRemaining()
  if ( not( hs.battery.isCharging() )) then
    if pct < 8 then
      hs.alert.show(string.format("Plug-in the power NOW!  %02d minutes left!", minutes))
    end
  end
end
--------------------------------------------------

hs.battery.watcher.new(batt_watch_low):start()
