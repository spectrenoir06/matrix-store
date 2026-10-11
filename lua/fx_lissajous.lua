-- Lissajous: a point tracing curves that slowly change shape, with a
-- fading trail of where it has been (fadeDisplay + updateDisplay(true):
-- only the newest segments are drawn).
local mx, my = getMatrix()
local floor, sin = math.floor, math.sin
local t = 0
local px, py
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local fa = 3 + sin(t * 0.0007) -- the frequencies drift: the shape morphs
  local fb = 2 + sin(t * 0.0011 + 1)
  -- every other frame: at 4 bits a color, each fade takes a whole level (15 of them)
  if t % 6 == 0 then fadeDisplay(240) end
  for step = 1, 3 do -- three segments per frame: a smooth line
    t = t + 1
    local x = floor(mx / 2 + (mx / 2 - 1) * sin(t * 0.03 * fa))
    local y = floor(my / 2 + (my / 2 - 1) * sin(t * 0.03 * fb + 0.5))
    local r, g, b = colorWheel(floor(t / 4) % 256)
    if px then drawLine(px, py, x, y, r, g, b) end
    px, py = x, y
  end
  updateDisplay(true)
  pace()
end
