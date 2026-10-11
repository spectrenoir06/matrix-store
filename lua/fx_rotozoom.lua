-- Rotozoom: a checkerboard turning and zooming, the demoscene classic.
-- Along a row the texture moves by a constant step: additions only.
local mx, my = getMatrix()
local floor, sin, cos = math.floor, math.sin, math.cos
local cx, cy = mx / 2, my / 2
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local a = t * 0.015
  local zoom = 1.6 + 1.2 * sin(t * 0.011)
  local c, s = cos(a) * zoom, sin(a) * zoom
  local ox, oy = t * 0.7, t * 0.3
  local h1, h2 = floor(t / 2) % 256, (floor(t / 2) + 128) % 256
  local r1, g1, b1 = colorWheel(h1)
  local r2, g2, b2 = colorWheel(h2)
  r2, g2, b2 = r2 // 5, g2 // 5, b2 // 5
  for y = 0, my - 1 do
    local u = (-cx) * c - (y - cy) * s + ox
    local v = (-cx) * s + (y - cy) * c + oy
    for x = 0, mx - 1 do
      if (floor(u / 8) + floor(v / 8)) % 2 == 0 then
        drawPixel(x, y, r1, g1, b1)
      else
        drawPixel(x, y, r2, g2, b2)
      end
      u, v = u + c, v + s
    end
  end
  updateDisplay()
  t = t + 1
  pace()
end
