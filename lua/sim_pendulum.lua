-- Double pendulum: two arms, gravity, chaos. The tip leaves a fading
-- rainbow trail; tiny changes at the start give completely different paths.
local mx, my = getMatrix()
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local ox, oy = mx / 2, my / 2 - 2
local L1 = math.min(mx, my * 2) / 4.6
local L2 = L1 * 0.9
local a1, a2, w1, w2 = 2.0 + math.random() * 0.5, 2.5, 0, 0
local G, dt = 9.81, 0.01
local N = 120
local tx, ty = {}, {}
local head, hue = 0, 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  for step = 1, 8 do -- the equations of motion (masses 1, lengths in "meters")
    local d = a1 - a2
    local den = 3 - cos(2 * d)
    local n1 = -G * 3 * sin(a1) - G * sin(a1 - 2 * a2) - 2 * sin(d) * (w2 * w2 * 1 + w1 * w1 * cos(d))
    local n2 = 2 * sin(d) * (w1 * w1 * 2 + G * 2 * cos(a1) + w2 * w2 * cos(d))
    w1 = w1 + n1 / den * dt
    w2 = w2 + n2 / den * dt
    a1, a2 = a1 + w1 * dt, a2 + w2 * dt
  end
  -- angles kept within -pi..pi: the matrix's floats are 32-bit, a big angle
  -- loses precision
  a1, a2 = (a1 + pi) % (2 * pi) - pi, (a2 + pi) % (2 * pi) - pi
  -- the numbers ran away (they can, with steps this simple): start again
  if a1 ~= a1 or a2 ~= a2 or math.abs(w1) > 40 or math.abs(w2) > 40 then
    a1, a2, w1, w2 = 2.0 + math.random() * 0.5, 2.5, 0, 0
    for i = 1, N do tx[i] = nil end
  end
  local x1, y1 = ox + L1 * sin(a1), oy + L1 * cos(a1)
  local x2, y2 = x1 + L2 * sin(a2), y1 + L2 * cos(a2)
  head = head % N + 1
  tx[head], ty[head] = floor(x2 + 0.5), floor(y2 + 0.5)
  hue = (hue + 1) % 256
  clearDisplay()
  for k = N - 1, 1, -1 do
    local i = (head - k - 1) % N + 1
    if tx[i] then
      local fade = 1 - k / N
      local r, g, b = colorWheel((hue - k * 2) % 256)
      drawPixel(tx[i], ty[i], floor(r * fade), floor(g * fade), floor(b * fade))
    end
  end
  local px, py, qx, qy = floor(ox + 0.5), floor(oy + 0.5), floor(x1 + 0.5), floor(y1 + 0.5)
  drawLine(px, py, qx, qy, 90, 90, 90)
  drawLine(qx, qy, tx[head], ty[head], 150, 150, 150)
  drawPixel(floor(ox), floor(oy), 255, 255, 255)
  updateDisplay()
  pace(20)
end
