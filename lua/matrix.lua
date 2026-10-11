-- Matrix rain: green drops falling, a bright head and a fading tail.
-- Fits any panel (getMatrix); tails stay above 80: dimmer is black at 4 bits.
local mx, my = getMatrix()
local max, floor, random = math.max, math.floor, math.random
local N = mx * my // 100
local L = max(8, my // 2) -- tail length
local xs, ys, sp = {}, {}, {}
for i = 1, N do
  xs[i], ys[i], sp[i] = random(0, mx - 1), random(0, my + L), 0.15 + random() * 0.3
end
local t_next = millis()
while true do
  clearDisplay()
  for i = 1, N do
    local y = floor(ys[i])
    for j = max(0, y - L), y do
      if j == y then drawPixel(xs[i], j, 180, 255, 180)
      else
        local c = (j - y + L) / L -- 0 at the tail's end, 1 at the head
        drawPixel(xs[i], j, 0, floor(80 + c * 150), floor(c * 40))
      end
    end
    ys[i] = ys[i] + sp[i]
    if ys[i] > my + L then xs[i], ys[i] = random(0, mx - 1), 0 end
  end
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
