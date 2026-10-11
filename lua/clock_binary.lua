-- Binary clock: each digit of HH MM SS as a column of 4 lights
-- (8, 4, 2, 1 from the top). Read the lit ones and add them up.
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
local cols = 6
local cell = math.min((mx - 4) // cols, my // 4)
local dot = cell - 2
local x0 = (mx - cols * cell - 4) // 2
-- a dim version of a color, still visible: the panel shows nothing below
-- 53 (of 255) at 5 bits per color, 77 at 4, so the brightest channel goes to 95
local function dim(r, g, b)
  local k = 95 / math.max(r, g, b, 1)
  return floor(r * k), floor(g * k), floor(b * k)
end
while true do
  local h, m, s = getTime()
  if not h then
    no_time(mx, my)
  else
    local digits = { h // 10, h % 10, m // 10, m % 10, s // 10, s % 10 }
    clearDisplay()
    for c = 1, cols do
      local pair = (c - 1) // 2 -- hours, minutes, seconds: one color each
      local r, g, b = colorWheel(pair * 85 + 20)
      local x = x0 + (c - 1) * cell + pair * 2
      for bit = 0, 3 do
        local y = my - (bit + 1) * cell + 1
        if (digits[c] >> bit) & 1 == 1 then
          fillRect(x, y, dot, dot, r, g, b)
        else
          fillRect(x, y, dot, dot, dim(r, g, b)) -- off
        end
      end
    end
    updateDisplay()
    delay(100)
  end
end
