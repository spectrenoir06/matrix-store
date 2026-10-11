-- Zone plate: rings that get closer and closer toward the edges
-- (brightness = cos(k * r^2)). Where they get finer than the LEDs, the
-- pixel grid samples them and ghost circles appear: moire made by the
-- matrix itself. k grows and shrinks: the ghosts multiply and move.
local mx, my = getMatrix()
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local C = {} -- one cosine period in 256 steps: 0..255
for i = 0, 255 do C[i] = floor(127.5 + 127.5 * cos(i / 256 * 2 * pi)) end
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local K = floor(160 + 150 * sin(t * 0.004)) -- ring tightness (x 1/256)
  local cx = floor(mx / 2 + (mx / 4) * sin(t * 0.007))
  local cy = floor(my / 2 + (my / 4) * cos(t * 0.009))
  local phase = t * 6
  local hue = floor(t / 3) % 256
  local r0, g0, b0 = colorWheel(hue)
  local r1, g1, b1 = colorWheel((hue + 100) % 256)
  for y = 0, my - 1 do
    local dy2 = (y - cy) * (y - cy)
    for x = 0, mx - 1 do
      local dx = x - cx
      local v = C[(((dx * dx + dy2) * K) >> 6) - phase & 255]
      local w = 255 - v
      drawPixel(x, y, (r0 * v + r1 * w) >> 8, (g0 * v + g1 * w) >> 8, (b0 * v + b1 * w) >> 8)
    end
  end
  updateDisplay()
  t = t + 1
  pace(30)
end
