-- Mandala, for the cross (96x96): polar plasma, petals waving, rings and
-- crosses flowing out of the center, colors cycling, 130 BPM. One eighth
-- is drawn, mirror "k" copies it 8 ways. Each pixel's radius, angle and
-- cross distance read in one call, sin and the colors in tables.
local floor, atan, sqrt, byte = math.floor, math.atan, math.sqrt, string.byte
local BEAT = 60000 / 130
-- sin, 0..254, S[1..256]
local S = {}
for k = 0, 255 do S[k + 1] = floor(127 + 127 * math.sin(k * math.pi / 128)) end
-- 3 bytes a pixel in one string (a 648-number table doesn't fit in 30 KB)
local rows, t = {}, {}
for y = 32, 47 do
  local dy, n = 47.5 - y, 0
  for x = 0, y do
    local dx = 47.5 - x
    t[n + 1] = floor(sqrt(dx * dx + dy * dy) * 3) -- radius
    t[n + 2] = floor(atan(dy, dx) * 325) -- angle, 0..255 over the eighth
    t[n + 3] = floor((dx > 3 * dy and dx or 3 * dy) * 4) & 255 -- cross distance
    n = n + 3
  end
  rows[y - 31] = string.char(table.unpack(t, 1, n))
end
local Q = table.concat(rows)
rows, t = nil, nil
collectgarbage()
-- colors: 4 lights x 64 hues
local PAL = {}
for k = 0, 255 do
  local r, g, bl = hsv((k & 63) * 4, 255, 90 + (k >> 6) * 55) -- 4-bit: under 77 is black
  PAL[k + 1] = r << 16 | g << 8 | bl
end
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  local t = floor(b * 32 + 24 * kick) -- a jolt on the kick
  local petals = 1 + floor(b / 8) % 3 -- 8, 16, 24 petals
  local wob = floor(40 + 30 * (S[floor(b * 4) % 256 + 1] - 127) / 127)
  local hue = floor(b * 5)
  i = 1
  for y = 32, 47 do
    for x = 0, y do
      local r, a, p = byte(Q, i, i + 2)
      i = i + 3
      local v = S[(r * 2 - t) % 256 + 1]
        + S[(a * petals + (S[(r * 3 + t) % 256 + 1] - 127) * wob // 64) % 256 + 1]
        + S[(p * 2 + t * 2) % 256 + 1] -- 0..762
      local c = PAL[v // 191 * 64 + ((v - 381) // 8 + (r >> 3) + hue) % 64 + 1]
      drawPixel(x, y, c >> 16, c >> 8 & 255, c & 255)
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
