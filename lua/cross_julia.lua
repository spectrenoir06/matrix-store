-- Julia cross, for the cross (96x96): the Julia set of z^4 + c, c real
-- (between -1.25 and -0.9 it is a fractal cross), breathing, its colors
-- flowing out on the beat (130 BPM). The set has the cross's 8 symmetries:
-- one eighth is computed, mirror "k" copies it. Every other row a frame
-- (the frame kept, updateDisplay(true)): twice the frame rate.
local floor, sin, min = math.floor, math.sin, math.min
local BEAT = 60000 / 130
local N = 14
local COL = {}
local t0, t_next, odd = millis(), millis(), 0
while true do
  local b = (millis() - t0) / BEAT
  local c = -1.08 + 0.17 * sin(b * 0.09) + 0.03 * sin(b * 0.37)
  local zoom = 1 / (36 + 6 * sin(b * 0.13))
  local hue = floor(b * -12)
  for n = 0, N - 1 do
    local r, g, bl = hsv(n * 23 + hue, n > 9 and 120 or 255, min(255, 80 + n * 26)) -- 4-bit crosses: under 77 is black
    COL[n] = r << 16 | g << 8 | bl
  end
  local r, g, bl = hsv(floor(b * 3) + 128, 255, 90) -- inside (steady: rows are drawn every other frame)
  COL[N] = r << 16 | g << 8 | bl
  odd = 1 - odd
  for y = 32 + odd, 47, 2 do
    local y0 = (47.5 - y) * zoom
    for x = 0, y do
      local zx, zy, n = (47.5 - x) * zoom, y0, 0
      local xx, yy = zx * zx, zy * zy
      while n < N and xx + yy < 4 do
        local a, bb = xx - yy, 2 * zx * zy -- z^2
        zx, zy = a * a - bb * bb + c, 2 * a * bb -- z^4 + c
        xx, yy = zx * zx, zy * zy
        n = n + 1
      end
      local col = COL[n]
      drawPixel(x, y, col >> 16, col >> 8 & 255, col & 255)
    end
  end
  mirror("k")
  updateDisplay(true)
  t_next = t_next + 25
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
