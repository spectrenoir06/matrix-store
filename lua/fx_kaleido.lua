-- Kaleidoscope: ribbons drawn in the top left quarter, mirrored 8 ways
-- (mirror "k"), fading out (fadeDisplay + updateDisplay(true)).
local mx, my = getMatrix()
local floor, sin, cos = math.floor, math.sin, math.cos
local cx, cy = mx // 2, my // 2
local t, t_next = 0, millis()
while true do
  fadeDisplay(225)
  for i = 0, 2 do
    local a, b = t * (0.031 + i * 0.007), t * (0.023 + i * 0.011) + i * 2
    local x1, y1 = floor(cx * (0.5 + 0.48 * sin(a))), floor(cy * (0.5 + 0.48 * cos(b)))
    local x2, y2 = floor(cx * (0.5 + 0.48 * cos(a * 1.3 + 1))), floor(cy * (0.5 + 0.48 * sin(b * 0.7)))
    local r, g, bl = hsv(t * 2 + i * 85, 220, 255)
    drawLine(x1, y1, x2, y2, r, g, bl)
  end
  if t % 40 == 0 then -- now and then a bloom
    local r, g, b = hsv(t * 2 + 128, 160, 255)
    fillCircle(floor(cx * 0.6), floor(cy * 0.6), 2, r, g, b)
  end
  mirror("k")
  updateDisplay(true)
  t = t + 1
  t_next = t_next + 25
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
