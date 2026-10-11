-- Analog clock: a round face with hands (a smooth second hand), the
-- digital time and the date beside it.
local mx, my = getMatrix()
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local R = my // 2 - 1
local cx, cy = R, my // 2
local DAYS = { "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT" }
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
local function hand(angle, len, r, g, b)
  drawLine(cx, cy, floor(cx + sin(angle) * len + 0.5), floor(cy - cos(angle) * len + 0.5), r, g, b)
end
local last_s, since = -1, millis()
while true do
  local h, m, s, day, month, year, wday = getTime()
  if not h then
    no_time(mx, my)
  else
    if s ~= last_s then last_s, since = s, millis() end
    local sf = s + math.min(999, millis() - since) / 1000
    clearDisplay()
    -- the face: 60 dots, brighter every 5 minutes
    for i = 0, 59 do
      local a = i / 60 * 2 * pi
      local x, y = floor(cx + sin(a) * R + 0.5), floor(cy - cos(a) * R + 0.5)
      if i % 15 == 0 then drawPixel(x, y, 255, 255, 255)
      elseif i % 5 == 0 then drawPixel(x, y, 120, 120, 160)
      else drawPixel(x, y, 90, 90, 115) end -- dimmer: below 77 a 4-bit panel shows nothing
    end
    hand(((h % 12) + m / 60) / 12 * 2 * pi, R * 0.5, 255, 200, 80)
    hand((m + sf / 60) / 60 * 2 * pi, R * 0.8, 140, 220, 255)
    hand(sf / 60 * 2 * pi, R * 0.9, 255, 40, 40)
    drawPixel(cx, cy, 255, 255, 255)
    -- beside it: the time and the date (if there is room)
    if mx >= 2 * R + 30 then
      local tx = 2 * R + 4 + (mx - 2 * R - 4 - 30) // 2
      setTextSize(1)
      setTextColor(140, 220, 255)
      setCursor(tx, cy - 12)
      printText(string.format("%02d:%02d", h, m))
      setTextColor(150, 150, 150)
      setCursor(tx + 3, cy - 2)
      printText(DAYS[wday])
      setCursor(tx, cy + 8)
      printText(string.format("%02d/%02d", day, month))
    end
    updateDisplay()
    delay(40)
  end
end
