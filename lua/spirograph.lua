-- A spirograph drawn a few lines a frame: updateDisplay(true) keeps the
-- picture, each frame adds to it. A new one every ~10 s.
local mx, my = getMatrix()
local floor, sin, cos, min, random = math.floor, math.sin, math.cos, math.min, math.random
local cx, cy, S = mx / 2, my / 2, min(mx, my) / 2 - 1

local R, r, d, hue, a, px, py
local function new()
  R, r = random(5, 9), random(2, 7) * (random(0, 1) * 2 - 1) -- inside or outside
  d = random(3, 9) / 10
  hue, a = random(0, 255), 0
  clearDisplay()
  updateDisplay(true) -- both frames black
end
local function at(t) -- the curve, scaled to fit
  local k = (R - r) / r
  local x = (R - r) * cos(t) + d * r * cos(k * t)
  local y = (R - r) * sin(t) + d * r * sin(k * t)
  local s = S / (math.abs(R - r) + d * math.abs(r))
  return floor(cx + x * s * mx / (2 * S) * .95), floor(cy + y * s)
end

new()
px, py = at(0)
local t_next = millis()
while true do
  for _ = 1, 4 do
    a = a + .05
    local x, y = at(a)
    local cr, cg, cb = colorWheel(floor(hue + a * 12) % 256)
    drawLine(px, py, x, y, cr, cg, cb)
    px, py = x, y
  end
  updateDisplay(true)
  if a > 6.283 * 12 then
    delay(1500)
    new()
    px, py = at(0)
  end
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
