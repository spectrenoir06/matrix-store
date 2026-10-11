-- Metaballs: blobs of light that merge and split like a lava lamp.
-- Computed on 2x2 cells (a quarter of the work).
local mx, my = getMatrix()
local floor, sin, cos, min = math.floor, math.sin, math.cos, math.min
local balls = { {0.9, 1.3, 0.0}, {1.4, 0.8, 2.0}, {0.7, 1.7, 4.0} }
local bx, by = {}, {}
local R2 = (my / 4) ^ 2 -- the size of a ball
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  for i, b in ipairs(balls) do
    bx[i] = mx / 2 + (mx / 2 - 6) * sin(t * 0.02 * b[1] + b[3])
    by[i] = my / 2 + (my / 2 - 4) * cos(t * 0.02 * b[2] + b[3])
  end
  clearDisplay()
  for y = 0, my - 1, 2 do
    for x = 0, mx - 1, 2 do
      local f = 0
      for i = 1, 3 do
        local dx, dy = x - bx[i], y - by[i]
        f = f + R2 / (dx * dx + dy * dy + 1)
      end
      if f > 0.6 then
        local r, g, b = colorWheel(floor(f * 40 + t) % 256)
        local k = min(1, (f - 0.6) * 2)
        fillRect(x, y, 2, 2, floor(r * k), floor(g * k), floor(b * k))
      end
    end
  end
  updateDisplay()
  t = t + 1
  pace()
end
