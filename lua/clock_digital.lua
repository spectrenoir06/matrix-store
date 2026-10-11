-- Digital clock: big hours and minutes, the date, and the seconds as a bar.
-- The color follows the time of day. getTime() comes from the app.
local mx, my = getMatrix()
local floor = math.floor
local DAYS = { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" }
local MONTHS = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" }
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
local last_s, since = -1, millis()
while true do
  local h, m, s, day, month, year, wday = getTime()
  if not h then
    no_time(mx, my)
  else
    if s ~= last_s then last_s, since = s, millis() end
    local big = mx >= 62 and 2 or 1
    local r, g, b = colorWheel(floor((h * 60 + m) * 256 / 1440))
    clearDisplay()
    setTextWrap(false)
    setTextSize(big)
    setTextColor(r, g, b)
    local w = 5 * 6 * big
    local x0 = (mx - w) // 2 + 1
    setCursor(x0, 1)
    printText(string.format("%02d", h))
    -- the colon blinks: on for the first half of each second
    if millis() - since < 500 then
      setCursor(x0 + 12 * big, 1)
      printText(":")
    end
    setCursor(x0 + 18 * big, 1)
    printText(string.format("%02d", m))
    setTextSize(1)
    setTextColor(160, 160, 160)
    local date = DAYS[wday] .. " " .. day .. " " .. MONTHS[month]
    setCursor(math.max(0, (mx - #date * 6) // 2 + 1), 8 * big + 4)
    printText(date)
    -- seconds: a bar along the bottom, moving smoothly
    local frac = (s + math.min(999, millis() - since) / 1000) / 60
    fillRect(0, my - 2, floor(mx * frac), 2, r // 2, g // 2, b // 2)
    updateDisplay()
    delay(40)
  end
end
