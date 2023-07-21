-- Battery
--------------------------------------------------
-- Handler directly called by the "low-level" watcher API.
--------------------------------------------------
pct_prev = nil
function batt_watch_low()
  pct = hs.battery.percentage()
  minutes = hs.battery.timeRemaining()
  if hs.battery.isCharging() then
    hs.alert.show(string.format("PMachine is charging."))
  else
    if pct < 8 then
      hs.alert.show(string.format("Plug-in the power NOW!  %02d minutes left!", minutes))
    end
  end
  pct_prev = pct
end
--------------------------------------------------

hs.battery.watcher.new(batt_watch_low):start()