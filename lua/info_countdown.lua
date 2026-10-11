-- Countdown to a date: days, then hours, minutes and seconds. Change the
-- target below (local time). At zero: it celebrates.
local target = { year = 2027, month = 1, day = 1, hour = 0, min = 0 }
local label = "NEW YEAR"
local mx, my = getMatrix()
local floor = math.floor
-- no time yet (power just came back): the app gives it when it connects
local function no_time(mx, my)
  clearDisplay()
  setTextSize(1)
  setTextColor(255, 120, 0)
  setCursor(math.max(0, (mx - 48) // 2), my // 2 - 9)
  printText("NO TIME")
  setTextColor(110, 110, 110)
  setCursor(math.max(0, (mx - 48) // 2), my // 2 + 1)
  printText("open app")
  updateDisplay()
  delay(500)
end
-- days since 1970-01-01 (Howard Hinnant's algorithm), small integers only
local function days(y, m, d)
  if m <= 2 then y = y - 1 end
  local era = y // 400
  local yoe = y - era * 400
  local doy = (153 * (m + (m > 2 and -3 or 9)) + 2) // 5 + d - 1
  local doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
  return era * 146097 + doe - 719468
end
while true do
  local h, m, s, day, month, year = getTime()
  if not h then
    no_time(mx, my)
  else
    local d_left = days(target.year, target.month, target.day) - days(year, month, day)
    local s_left = d_left * 86400 + (target.hour * 3600 + target.min * 60) - (h * 3600 + m * 60 + s)
    clearDisplay()
    setTextWrap(false)
    setTextSize(1)
    if s_left <= 0 then -- it's time
      local r, g, b = colorWheel(floor(millis() / 8) % 256)
      setTextColor(r, g, b)
      setCursor((mx - #label * 6) // 2 + 1, my // 2 - 4)
      printText(label)
      if (millis() // 300) % 2 == 0 then fillRect(0, 0, mx, 1, 255, 255, 255); fillRect(0, my - 1, mx, 1, 255, 255, 255) end
    else
      local dd, rest = s_left // 86400, s_left % 86400
      setTextColor(150, 150, 150)
      setCursor((mx - #label * 6) // 2 + 1, 1)
      printText(label)
      local r, g, b = colorWheel(floor(dd * 7) % 256)
      setTextColor(r, g, b)
      local line = dd > 0 and (dd .. (dd == 1 and " day" or " days")) or "today!"
      setCursor((mx - #line * 6) // 2 + 1, 12)
      printText(line)
      setTextColor(255, 255, 255)
      local hms = string.format("%02d:%02d:%02d", rest // 3600, rest % 3600 // 60, rest % 60)
      setCursor((mx - #hms * 6) // 2 + 1, 23)
      printText(hms)
    end
    updateDisplay()
    delay(100)
  end
end
