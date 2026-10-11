-- Hypno spiral, for the cross (96x96): an endless zoom (rings on a log
-- scale: each one a copy of the one inside, bigger), twisting into a spiral
-- and back, its shape going round to cross and back. 130 BPM. One eighth
-- is drawn, mirror "k" copies it 8 ways. Each pixel's log radii and angle
-- read in one call, colors from a table.
local floor, atan, sqrt, log, sin, byte = math.floor, math.atan, math.sqrt, math.log, math.sin, string.byte
local BEAT = 60000 / 130
-- 3 bytes a pixel in one string (a 648-number table doesn't fit in 30 KB)
local rows, t = {}, {}
for y = 32, 47 do
  local dy, n = 47.5 - y, 0
  for x = 0, y do
    local dx = 47.5 - x
    t[n + 1] = floor(log(sqrt(dx * dx + dy * dy)) * 40) + 20 -- log radius, round
    t[n + 2] = floor(log(dx > 3 * dy and dx or 3 * dy) * 40) + 20 -- log radius, cross
    t[n + 3] = floor(atan(dy, dx) * 163) -- angle, 0..128 over the eighth
    n = n + 3
  end
  rows[y - 31] = string.char(table.unpack(t, 1, n))
end
local Q = table.concat(rows)
rows, t = nil, nil
collectgarbage()
local COL = {}
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  local m = floor(128 + 127 * sin(b * 0.1)) -- 0 round .. 255 cross
  local tw = floor(128 * sin(b * 0.06)) -- the twist
  local go = floor(b * 16)
  local pal = floor(b / 16) % 3
  for k = 0, 15 do -- 8 bands x (lit, dark); black and white first
    local r, g, bl = 255, 255, 255
    if pal > 0 then r, g, bl = hsv(floor(b * 3) + (k & 7) * (pal == 1 and 40 or 128), 255, 255) end
    if k > 7 then
      local s = pal > 0 and floor(40 + 120 * kick) or 0
      r, g, bl = r * s // 255, g * s // 255, bl * s // 255
    end
    COL[k] = r << 16 | g << 8 | bl
  end
  i = 1
  for y = 32, 47 do
    for x = 0, y do
      local c, p, a = byte(Q, i, i + 2)
      i = i + 3
      local u = (c + (p - c) * m // 256) * 2 - go + a * tw // 64
      local col = COL[(u >> 6 & 7) + (u & 32) // 4]
      drawPixel(x, y, col >> 16, col >> 8 & 255, col & 255)
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
