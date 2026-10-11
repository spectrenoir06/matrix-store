-- Qix (after acondolu.me/qix): lines that glide and swirl with a trail of
-- 12. Straight for a while, then turning; at an edge (of the panels: the
-- cross's too), back to the center. Short: compiling takes from the 30 KB.
local mx, my = getMatrix()
local floor, random, sin, cos = math.floor, math.random, math.sin, math.cos
-- the panels' shape (the cross has no corners): a pixel drawn and read back;
-- per row, the first and last that exist
local L, R = {}, {}
for y = 1, my do
  L[y], R[y] = mx, -1
  for x = 0, mx - 1 do
    drawPixel(x, y - 1, 255, 255, 255)
    if getPixel(x, y - 1) > 0 then L[y] = math.min(L[y], x); R[y] = x end
  end
end
clearDisplay()
local function on(x, y) return y >= 0 and y < my and x >= L[y + 1] and x <= R[y + 1] end
local min, max = math.min, math.max
-- 3 palettes (pinks, greens, blues) of 5 colors: r, g, b, ...
local PAL = { 255,0,153, 255,45,0, 255,0,0, 227,0,255, 255,89,0,
  107,255,0, 0,255,87, 0,255,0, 213,255,0, 0,255,173,
  0,81,255, 83,0,255, 0,0,255, 0,161,255, 167,0,255 }
local TRAIL = 12
local KMAX = max(4, floor(min(mx, my) * 0.38)) -- sizes of the page / 31
local K2MAX, SC = max(4, floor(KMAX * 27 / 31)), KMAX / 31
local N = max(3, min(4, floor(mx * my / 1500)))
local function rand(a, b) return a + floor(random() * (b - a) + 0.5) end
local function sg() return random(0, 1) * 2 - 1 end

local Q = {}
for k = 1, N do
  Q[k] = { pal = random(0, 2) * 15, x = mx / 2, y = my / 2, d = 6 * SC, a = random() * 6.283,
    n = rand(5, 15), turn = false, k = KMAX // 3, kd = sg(), k2 = K2MAX // 3, k2d = sg(),
    rd = sg(), ld = sg(), cl = 0, c = 0, t = {}, h = 0 }
end

local function step(q)
  q.k = q.k + q.kd
  if q.k > KMAX then q.kd = -1 elseif q.k < 2 then q.kd = 1 end
  q.k2 = q.k2 + q.k2d
  if q.k2 > K2MAX then q.k2d = -1 elseif q.k2 < 2 then q.k2d = 1 end
  q.cl = q.cl - 1
  if q.cl <= 0 then q.c, q.cl = random(0, 4) * 3, rand(5, 15) end
  local f = 1
  if q.turn then
    q.a = q.a + q.rd * 0.1
    f = rand(-5, 10) / 10
  elseif not on(floor(q.x), floor(q.y)) then -- back to the center
    q.x, q.y = max(0, min(q.x, mx)), max(0, min(q.y, my))
    local tx, ty = mx / 2 - q.x, my / 2 - q.y
    local n = floor(math.sqrt(tx * tx + ty * ty) / q.d + 0.5)
    q.n, q.ld, q.a = rand(min(5, n), n), 1, math.atan(ty, tx)
  end
  local dx, dy = q.ld * cos(q.a), q.ld * sin(q.a)
  q.x, q.y = q.x + f * q.d * dx, q.y + f * q.d * dy
  q.h = q.h % TRAIL + 1
  local t, i = q.t, (q.h - 1) * 5 -- x1, y1, x2, y2, color
  t[i + 1], t[i + 2] = floor(q.x - q.k * dy), floor(q.y + q.k2 * dx)
  t[i + 3], t[i + 4], t[i + 5] = floor(q.x + q.k * dy), floor(q.y - q.k2 * dx), q.pal + q.c
  q.n = q.n - 1
  if q.n <= 0 then
    if q.turn then q.ld, q.n, q.d, q.turn = sg(), rand(5, 20), rand(4, 10) * SC, false
    else q.rd, q.n, q.turn = sg(), rand(6, 16), true end
  end
end

local t_next = millis()
while true do
  clearDisplay()
  for _, q in ipairs(Q) do
    step(q)
    local t = q.t
    for i = 0, TRAIL * 5 - 1, 5 do
      local c = t[i + 5]
      if c then drawLine(t[i + 1], t[i + 2], t[i + 3], t[i + 4], PAL[c + 1], PAL[c + 2], PAL[c + 3]) end
    end
  end
  updateDisplay()
  t_next = t_next + 40 -- the page's 25 frames a second
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
