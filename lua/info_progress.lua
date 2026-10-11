-- How far along: the day, the week, the month and the year, as bars.
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
local function leap(y) return (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0 end
local MDAYS = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
-- a dim version of a color, still visible: the panel shows nothing below
-- 53 (of 255) at 5 bits per color, 77 at 4, so the brightest channel goes to 95
local function dim(r, g, b)
  local k = 95 / math.max(r, g, b, 1)
  return floor(r * k), floor(g * k), floor(b * k)
end
while true do
  local h, m, s, day, month, year, wday = getTime()
  if not h then
    no_time(mx, my)
  else
    local dayf = (h * 3600 + m * 60 + s) / 86400
    local mdays = MDAYS[month] + ((month == 2 and leap(year)) and 1 or 0)
    local yday = day - 1
    for i = 1, month - 1 do yday = yday + MDAYS[i] + ((i == 2 and leap(year)) and 1 or 0) end
    local rows = {
      { "DAY", dayf },
      { "WEEK", ((wday + 5) % 7 + dayf) / 7 }, -- the week starts on Monday
      { "MONTH", (day - 1 + dayf) / mdays },
      { "YEAR", (yday + dayf) / (leap(year) and 366 or 365) },
    }
    clearDisplay()
    setTextSize(1)
    setTextWrap(false)
    local bar_x = 31
    local bar_w = mx - bar_x - 1
    local rh = my // #rows
    for i, row in ipairs(rows) do
      local y = (i - 1) * rh
      local r, g, b = colorWheel((i - 1) * 64)
      setTextColor(r, g, b)
      setCursor(1, y + (rh - 8) // 2 + 1)
      printText(row[1])
      local fill = floor(bar_w * row[2] + 0.5)
      fillRect(bar_x, y + 1, bar_w, rh - 2, dim(r, g, b)) -- the rest of the bar
      fillRect(bar_x, y + 1, fill, rh - 2, r, g, b)
    end
    updateDisplay()
    delay(1000)
  end
end
