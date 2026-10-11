-- Outrun, for the cross (96x96): synthwave. A striped sun setting in the top
-- arm, mountains on the side arms, a neon grid racing below the horizon,
-- faster on the kick (130 BPM); every 16 beats the colors turn.
local floor, sin, min = math.floor, math.sin, math.min
local BEAT = 60000 / 130
local HY = 50 -- the horizon
local stars = {}
for i = 1, 40 do stars[i] = math.random(0, 96 * HY - 1) end
local t0, t_next, pos, last = millis(), millis(), 0, 0
while true do
  local now = millis()
  local b = (now - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  pos = pos + (now - last) * (0.0016 + 0.006 * kick)
  last = now
  local hue = floor(b / 16) * 40 -- the scene's colors
  clearDisplay()
  for i = 1, #stars do -- stars, twinkling
    local s = stars[i]
    local v = floor(120 + 120 * sin(b + i))
    drawPixel(s % 96, s // 96, v, v, v)
  end
  -- the sun: rows yellow to pink, stripes moving down
  local sy, sr = 35, 15
  for y = sy - sr, HY - 1 do
    local dy = y - sy
    local w = floor(math.sqrt(sr * sr - dy * dy))
    local band = (y - sy + floor(b * 2)) % 6
    if dy < -6 or band >= (dy + 8) // 6 then
      local r, g, bl = hsv(hue + 40 - (y - sy + sr) * 32 // sr, 255 - (y - sy + sr) * 2, 255)
      drawHLine(48 - w, y, 2 * w, r, g, bl)
    end
  end
  -- mountains on the horizon, the side arms
  for x = 0, 95 do
    local d = x < 48 and 47 - x or x - 48
    local h = floor((d / 48) ^ 1.5 * (14 + 6 * noise(x * 0.15, 3.7)))
    if h > 0 then
      local r, g, bl = hsv(hue + 200, 220, 95)
      drawVLine(x, HY - h, h, r, g, bl)
      r, g, bl = hsv(hue + 220, 160, 255)
      drawPixel(x, HY - h, r, g, bl)
    end
  end
  -- the grid: lines across going by, lines to the vanishing point
  local gr, gg, gb = hsv(hue + 210, 255, 255)
  drawHLine(0, HY, 96, gr, gg, gb)
  local f = pos % 1
  for i = 1, 12 do
    local z = i - f
    local y = HY + floor(46 / z)
    if y < 96 then
      local v = min(255, floor(500 / (z + 1)))
      local r, g, bl = hsv(hue + 210, 255, v)
      drawHLine(0, y, 96, r, g, bl)
    end
  end
  for k = -10, 10 do
    drawLine(48 + k * 2, HY, 48 + k * 26, 96 + 46, gr * 2 // 3, gg * 2 // 3, gb * 2 // 3)
  end
  updateDisplay()
  t_next = t_next + 25
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
