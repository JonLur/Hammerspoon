-- Battery
--------------------------------------------------
-- Handler directly called by the "low-level" watcher API.
--------------------------------------------------
pct_prev = nil
function batt_watch_low()
  pct = hs.battery.percentage()
  minutes = hs.battery.timeRemaining()
  if pct ~= pct_prev and not hs.battery.isCharging() and pct < 10 and minutes > 0 then
      hs.alert.show(string.format("Plug-in the power NOW! %02d minutes left!", minutes))
  end
  pct_prev = pct
end
--------------------------------------------------

hs.battery.watcher.new(batt_watch_low):start()
