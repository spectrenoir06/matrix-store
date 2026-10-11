-- Starfield: flying through space, stars streaming out from the center.
local mx, my = getMatrix()
local random, floor = math.random, math.floor
local cx, cy = mx / 2, my / 2
local N = 90
local sx, sy, sz = {}, {}, {}
local function new_star(i, far)
  sx[i] = (random() - 0.5) * mx * 2
  sy[i] = (random() - 0.5) * my * 2
  sz[i] = far and 64 or random(1, 64)
end
for i = 1, N do new_star(i, false) end
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local speed = 0.6 + 0.5 * math.sin(t / 120) -- it speeds up and slows down
  clearDisplay()
  for i = 1, N do
    sz[i] = sz[i] - speed
    if sz[i] <= 0.5 then new_star(i, true) end
    local k = 16 / sz[i]
    local x, y = floor(cx + sx[i] * k), floor(cy + sy[i] * k)
    if x < 0 or x >= mx or y < 0 or y >= my then
      new_star(i, true)
    else
      local b = floor(80 + 175 * (1 - sz[i] / 64)) -- 80+: dimmer is black at 4 bits
      if sz[i] < 12 then -- close: a streak toward the center
        local s = sz[i] + speed * 3
        drawLine(floor(cx + sx[i] * 16 / s), floor(cy + sy[i] * 16 / s), x, y, b // 2, b // 2, b)
      end
      drawPixel(x, y, b, b, b)
    end
  end
  updateDisplay()
  t = t + 1
  pace()
end
