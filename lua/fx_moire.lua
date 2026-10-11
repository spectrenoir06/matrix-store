-- Moire: three sets of rings, one per color (red, green, blue), wandering
-- and expanding. Where they overlap they interfere: every color mix shows.
-- The distances are computed once, for one quarter (they are symmetric):
-- byte strings, ~2.5 KB (scripts have 30 KB). Each center reads them with
-- its own offsets.
local mx, my = getMatrix()
local floor, sin, cos, sqrt, byte, char = math.floor, math.sin, math.cos, math.sqrt, string.byte, string.char
-- big panels: computed per SxS block (the table stays ~2.3 KB)
local S = 1
while (mx // S) * (my // S) > 2304 do S = S + 1 end
local pw, ph = mx, my
mx, my = (pw + S - 1) // S, (ph + S - 1) // S
local field, row = {}, {}
for dy = 0, my - 1 do
  for dx = 0, mx - 1 do
    row[dx + 1] = floor(sqrt(dx * dx + dy * dy) * 3) % 256 -- in thirds of a pixel
  end
  field[dy + 1] = char(table.unpack(row))
end
row = nil
collectgarbage()
local RING = 12 // S -- ring width: 4 px (in thirds of a computed pixel)
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  -- three centers on slow, different paths
  local cx, cy = {}, {}
  for k = 1, 3 do
    cx[k] = floor(mx / 2 + (mx / 2 - 4) * sin(t * (0.011 + k * 0.004) + k * 2.1))
    cy[k] = floor(my / 2 + (my / 2 - 3) * cos(t * (0.013 + k * 0.003) + k * 1.3))
  end
  local grow = t % (RING * 2) -- rings move outward
  local x1, x2, x3 = cx[1], cx[2], cx[3]
  for y = 0, my - 1 do
    local d1, d2, d3 = y - cy[1], y - cy[2], y - cy[3]
    local rr = field[(d1 < 0 and -d1 or d1) + 1]
    local rg = field[(d2 < 0 and -d2 or d2) + 1]
    local rb = field[(d3 < 0 and -d3 or d3) + 1]
    for x = 0, mx - 1 do
      local a, b, c = x - x1, x - x2, x - x3
      local r = ((byte(rr, (a < 0 and -a or a) + 1) - grow) // RING) & 1
      local g = ((byte(rg, (b < 0 and -b or b) + 1) - grow) // RING) & 1
      local bl = ((byte(rb, (c < 0 and -c or c) + 1) - grow) // RING) & 1
      if S == 1 then drawPixel(x, y, r * 255, g * 200, bl * 255)
      else fillRect(x * S, y * S, S, S, r * 255, g * 200, bl * 255) end
    end
  end
  updateDisplay()
  t = t + 1
  pace(30)
end
