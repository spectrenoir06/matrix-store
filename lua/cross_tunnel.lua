-- Cross tunnel, for the cross (96x96): flying down an endless plus-shaped
-- tube at 130 BPM. One eighth is drawn (rows 32..47, x 0..y), mirror "k"
-- copies it 8 ways. Fast on the matrix: each pixel's depth, angle and light
-- read in one call, colors from a table.
local floor, atan, min, byte = math.floor, math.atan, math.min, string.byte
local BEAT = 60000 / 130
-- 3 bytes a pixel in one string (a 648-number table doesn't fit in 30 KB)
local rows, t = {}, {}
for y = 32, 47 do
  local dy, n = 47.5 - y, 0
  for x = 0, y do
    local dx = 47.5 - x
    local d = dx > 3 * dy and dx or 3 * dy -- plus-shaped distance: 48 = the cross's edge
    local a = floor(atan(dy, dx) * 163) -- 0..128
    t[n + 1], t[n + 2], t[n + 3] = floor(1400 / d) % 256, a, a // 3 | min(3, floor(d / 11)) << 6
    n = n + 3
  end
  rows[y - 31] = string.char(table.unpack(t, 1, n))
end
local Q = table.concat(rows)
rows, t = nil, nil
collectgarbage()
-- colors: 4 lights x (ring dark, lit) x 32 hues; palettes change every 16
-- beats: rainbow, acid green, pink/cyan, fire
local LIGHT = { 70, 150, 220, 255 }
local function pal(p, v, s)
  if p == 0 then return hsv(v, 255, s) end
  if p == 1 then return (v & 64 > 0) and s or 0, s, (v & 64 > 0) and s or s // 4 end
  if p == 2 then return hsv(v & 128 > 0 and 215 or 130, 255 - (v & 63) * 2, s) end
  return hsv((v >> 3) & 31, 255, s)
end
local PAL, made = {}, -1
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  local p = floor(b / 16) % 4
  if p ~= made then
    made = p
    for k = 0, 255 do
      local s = LIGHT[(k >> 6) + 1]
      if k & 32 == 0 then s = s // 4 end
      local r, g, bl = pal(p, (k & 31) * 8, s)
      PAL[k + 1] = r << 16 | g << 8 | bl
    end
  end
  local go = floor(b * 24 + 40 * kick) -- the speed jumps on the kick
  local twist = floor(40 * math.sin(b * 0.19))
  local ho = floor(b * 8) & 255
  local wl = 10 + floor(30 * kick) -- the white line, fat on the kick
  i = 1
  for y = 32, 47 do
    for x = 0, y do
      local z, a, e = byte(Q, i, i + 2)
      i = i + 3
      local v = (z * 2 - go + a * twist // 64) & 255
      if v < wl then drawPixel(x, y, 255, 255, 255)
      else
        local c = PAL[(e & 192) + ((v + (e & 63)) & 32) + ((v + ho) >> 3 & 31) + 1]
        drawPixel(x, y, c >> 16, c >> 8 & 255, c & 255)
      end
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
