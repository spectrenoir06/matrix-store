-- Tunnel: flying down an endless striped tube. The angle and the depth of
-- each pixel are computed once, kept as strings of bytes (little memory).
local mx, my = getMatrix()
local floor, byte, char, atan, sqrt, pi = math.floor, string.byte, string.char, math.atan, math.sqrt, math.pi
-- big panels: computed per BxB block (at most 64x32 of them: the tables
-- stay ~8 KB, scripts have 30 KB)
local B = 1
while (mx // B) * (my // B) > 2048 do B = B + 1 end
local pw, ph = mx, my
mx, my = (pw + B - 1) // B, (ph + B - 1) // B
local cx, cy = mx / 2 - 0.5, my / 2 - 0.5
local ASPECT = pw / ph * 0.8 -- 1.6 on a 64x32 panel: a round tube that fills it
local ang, dep, shade = {}, {}, {}
local a, d, s = {}, {}, {} -- one row at a time, reused: no garbage (30 KB)
for y = 0, my - 1 do
  for x = 0, mx - 1 do
    local dx, dy = x - cx, (y - cy) * ASPECT
    local dist = sqrt(dx * dx + dy * dy) + 0.5
    a[x + 1] = floor((atan(dy, dx) / pi + 1) * 128) % 256
    d[x + 1] = floor(512 / dist) % 256
    s[x + 1] = floor(math.min(255, 50 + dist * 16)) -- dark only in the very middle
  end
  ang[y + 1], dep[y + 1], shade[y + 1] = char(table.unpack(a)), char(table.unpack(d)), char(table.unpack(s))
end
a, d, s = nil, nil, nil
collectgarbage()
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local spin = floor(t * 0.7)
  for y = 1, my do
    local A, D, S = ang[y], dep[y], shade[y]
    for x = 1, mx do
      local u = (byte(A, x) + spin) & 255
      local v = (byte(D, x) + t * 3) & 255
      local s = byte(S, x)
      local p = (v + (u >> 2)) & 255
      -- the stripes: the opposite color, not darker (at 4 bits a color, dark is black)
      if ((u >> 5) ~ (v >> 4)) & 1 == 1 then p, s = (p + 128) & 255, s * 7 // 8 end
      local r, g, b = hsv(p, 255, s) -- its brightest channel at s: mixes don't sink
      if B == 1 then drawPixel(x - 1, y - 1, r, g, b)
      else fillRect((x - 1) * B, (y - 1) * B, B, B, r, g, b) end
    end
  end
  updateDisplay()
  t = t + 1
  pace()
end
