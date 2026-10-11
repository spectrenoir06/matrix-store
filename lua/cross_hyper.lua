-- Hyper, for the cross (96x96): 4D objects turning in 4 dimensions, seen in
-- 3D then flat, green phosphor trails, glitches on the kick (130 BPM).
-- Every 16 beats: the tesseract (4D cube) or the 16-cell (4D cross).
local floor, sin, cos, random = math.floor, math.sin, math.cos, math.random
local BEAT = 60000 / 130
-- objects: V = flat x, y, z, w per vertex; E = flat pairs of vertex numbers
local V1, E1, V2, E2 = {}, {}, {}, {}
for i = 0, 15 do -- tesseract: (+-1, +-1, +-1, +-1), edges = one coordinate apart
  for k = 0, 3 do V1[i * 4 + k + 1] = (i >> k) & 1 == 1 and 1 or -1 end
  for k = 0, 3 do
    local j = i ~ (1 << k)
    if j > i then E1[#E1 + 1] = i; E1[#E1 + 1] = j end
  end
end
for i = 0, 7 do -- 16-cell: +-1 on one axis, edges = all but opposite
  for k = 0, 3 do V2[i * 4 + k + 1] = (k == i >> 1) and (i & 1 == 1 and 1.5 or -1.5) or 0 end
  for j = i + 1, 7 do if j >> 1 ~= i >> 1 then E2[#E2 + 1] = i; E2[#E2 + 1] = j end end
end
local PX, PY, PW = {}, {}, {}
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  local V, E, acid = V1, E1, false
  if floor(b / 16) % 2 == 1 then V, E, acid = V2, E2, true end
  local a1, a2, a3 = b * 0.21, b * 0.13, b * 0.08
  local c1, s1, c2, s2, c3, s3 = cos(a1), sin(a1), cos(a2), sin(a2), cos(a3), sin(a3)
  local size = (acid and 150 or 100) + 40 * kick
  for i = 0, #V // 4 - 1 do
    local x, y, z, w = V[i * 4 + 1], V[i * 4 + 2], V[i * 4 + 3], V[i * 4 + 4]
    x, w = x * c1 - w * s1, x * s1 + w * c1 -- XW plane
    y, z = y * c2 - z * s2, y * s2 + z * c2 -- YZ
    z, w = z * c3 - w * s3, z * s3 + w * c3 -- ZW
    x, y = x * c3 - y * s3, x * s3 + y * c3 -- XY
    local k = 1 / (3 - w) -- 4D -> 3D
    x, y, z = x * k, y * k, z * k
    k = size / (2.4 - z) -- 3D -> 2D
    PX[i], PY[i], PW[i] = floor(48 + x * k), floor(48 + y * k), w
  end
  local glitch = kick > 0.6 and floor(b) % 4 == 3
  if glitch then scroll(random(-6, 6), 0, true) end -- the trails jump
  fadeDisplay(kick > 0.5 and 120 or 205)
  for e = 1, #E, 2 do
    local i, j = E[e], E[e + 1]
    local v = floor(160 + 28 * (PW[i] + PW[j])) -- far edges too: under 77 is black
    if glitch then -- RGB split
      local o = random(2, 5)
      drawLine(PX[i] - o, PY[i], PX[j] - o, PY[j], 255, 0, 60)
      drawLine(PX[i] + o, PY[i], PX[j] + o, PY[j], 0, 200, 255)
    end
    if acid then -- the 16-cell: rainbow trails
      local r, g, bl = hsv(floor(b * 10 + 30 * (PW[i] + PW[j])), 255, v)
      drawLine(PX[i], PY[i], PX[j], PY[j], r, g, bl)
    else drawLine(PX[i], PY[i], PX[j], PY[j], v // 3, v, v // 4) end
  end
  for i = 0, #V // 4 - 1 do fillRect(PX[i] - 1, PY[i] - 1, 2, 2, 230, 255, 230) end
  updateDisplay(true)
  t_next = t_next + 25
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
