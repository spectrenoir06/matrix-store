-- The shape functions (drawn in C, clipped: fast): a radar sweep, a
-- spinning triangle, bouncing circles, a breathing frame.
local mx, my = getMatrix()
local floor, sin, cos, min = math.floor, math.sin, math.cos, math.min
local cx, cy, R = mx // 2, my // 2, min(mx, my) // 2 - 1
local balls = {}
for i = 1, 3 do balls[i] = { x = i * mx / 4, y = my / 2, dx = .7 + i * .3, dy = .5 + i * .2, c = i * 85 } end

local t, t_next = 0, millis()
while true do
  clearDisplay()
  -- a radar sweep with a fading tail
  for k = 0, 8 do
    local a = t * .08 - k * .06
    drawLine(cx, cy, floor(cx + R * 2 * cos(a)), floor(cy + R * 2 * sin(a)), 0, 255 - k * 24, 0)
  end
  drawCircle(cx, cy, R, 0, 90, 0)
  drawHLine(0, cy, mx, 0, 70, 0)
  drawVLine(cx, 0, my, 0, 70, 0)
  -- a spinning triangle
  local p = {}
  for i = 0, 2 do
    local a = t * .05 + i * 2.094
    p[#p + 1] = floor(cx + R * .7 * cos(a))
    p[#p + 1] = floor(cy + R * .7 * sin(a))
  end
  fillTriangle(p[1], p[2], p[3], p[4], p[5], p[6], 120, 0, 160)
  drawTriangle(p[1], p[2], p[3], p[4], p[5], p[6], 255, 120, 255)
  -- bouncing circles
  for _, b in ipairs(balls) do
    b.x, b.y = b.x + b.dx, b.y + b.dy
    if b.x < 3 or b.x > mx - 4 then b.dx = -b.dx end
    if b.y < 3 or b.y > my - 4 then b.dy = -b.dy end
    local r, g, bl = colorWheel(b.c)
    fillCircle(floor(b.x), floor(b.y), 3, r, g, bl)
  end
  -- a breathing frame
  local m = floor(2 + 2 * sin(t * .1))
  drawRect(m, m, mx - 2 * m, my - 2 * m, 255, 160, 0)
  updateDisplay()
  t = t + 1
  t_next = t_next + 20
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
