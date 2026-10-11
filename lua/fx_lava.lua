-- Lava: two layers of smooth noise (noise(), Perlin, in C) turned into
-- hot colors with hsv(), in blocks of 2x2 or more.
local mx, my = getMatrix()
local floor, max, min = math.floor, math.max, math.min
local C = max(2, floor(math.sqrt(mx * my / 512))) -- block size: ~512 blocks
local t, t_next = 0, millis()
while true do
  for y = 0, my - 1, C do
    for x = 0, mx - 1, C do
      local n = noise(x * 0.06, y * 0.06, t) + 0.5 * noise(x * 0.13 + 7, y * 0.13, t * 1.7)
      local r, g, b = hsv(floor(n * 50 + 12), 255 - max(0, floor(n * 120)), min(255, max(60, floor(170 + n * 140))))
      fillRect(x, y, C, C, r, g, b)
    end
  end
  updateDisplay()
  t = t + 0.02
  t_next = t_next + 33
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
