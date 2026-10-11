-- Comets: bouncing dots whose trails fade out (fadeDisplay with
-- updateDisplay(true): only the heads are drawn). They bounce off the
-- panels' edges, the cross's inside corners too.
local mx, my = getMatrix()
local floor, random = math.floor, math.random
-- the panels' shape (no corners on the cross): per row, the first and last
-- pixel that lights, as first * 1024 + last
local S = {}
for y = 0, my - 1 do
  local a, b = mx, -1
  for x = 0, mx - 1 do
    drawPixel(x, y, 255, 255, 255)
    if getPixel(x, y) > 0 then
      if x < a then a = x end
      b = x
    end
  end
  S[y + 1] = a * 1024 + b
end
clearDisplay()
local function on(x, y)
  if y < 0 or y >= my then return false end
  local s = S[y + 1]
  return x >= s // 1024 and x <= s % 1024
end
local N = 6
local x, y, vx, vy, hue = {}, {}, {}, {}, {}
for i = 1, N do
  repeat x[i], y[i] = random(2, mx - 3), random(2, my - 3) until on(x[i], y[i])
  vx[i], vy[i] = (random() - 0.5) * 1.6, (random() - 0.5) * 1.2
  hue[i] = i * 256 // N
end
local t_next = millis()
while true do
  fadeDisplay(210)
  for i = 1, N do
    -- the next spot, a pixel ahead (the comet is 3 wide): off the panels, bounce
    local ax, ay = vx[i] > 0 and 1 or -1, vy[i] > 0 and 1 or -1
    local nx, ny = floor(x[i] + vx[i] + ax), floor(y[i] + vy[i] + ay)
    local fx, fy = not on(nx, floor(y[i])), not on(floor(x[i]), ny)
    if not fx and not fy and not on(nx, ny) then fx, fy = true, true end -- a corner
    if fx then vx[i] = -vx[i] end
    if fy then vy[i] = -vy[i] end
    x[i], y[i] = x[i] + vx[i], y[i] + vy[i]
    hue[i] = hue[i] + 0.5
    local r, g, b = hsv(hue[i], 200, 255)
    fillCircle(floor(x[i]), floor(y[i]), 1, r, g, b)
  end
  updateDisplay(true)
  t_next = t_next + 20
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
