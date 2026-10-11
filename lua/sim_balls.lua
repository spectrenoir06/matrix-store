-- Bouncing balls: gravity, bounces off the walls and off each other. The
-- walls are the panels' edges: on the cross, the arms and their corners.
local mx, my = getMatrix()
local random, floor, sqrt = math.random, math.floor, math.sqrt
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
local function on(x, y)
  x, y = floor(x), floor(y)
  return y >= 0 and y < my and x >= L[y + 1] and x <= R[y + 1]
end
local N = 7
local x, y, vx, vy, r, cr, cg, cb = {}, {}, {}, {}, {}, {}, {}, {}
for i = 1, N do
  r[i] = random(2, 3)
  repeat x[i], y[i] = random(r[i], mx - r[i] - 1), random(r[i], my // 2)
  until on(x[i] - r[i], y[i]) and on(x[i] + r[i], y[i]) and on(x[i], y[i] - r[i]) and on(x[i], y[i] + r[i])
  vx[i], vy[i] = (random() - 0.5) * 1.6, (random() - 0.5) * 1.2
  cr[i], cg[i], cb[i] = colorWheel(i * 256 // N)
end
local t = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  for i = 1, N do
    vy[i] = vy[i] + 0.05 -- gravity
    -- move unless the ball's edge would leave the panels: then bounce
    local R0, nx, ny = r[i], x[i] + vx[i], y[i] + vy[i]
    local sx, sy = vx[i] > 0 and R0 or -R0, vy[i] > 0 and R0 or -R0
    local hx, hy = not on(nx + sx, y[i]), not on(x[i], ny + sy)
    if not hx and not hy and not on(nx + sx * 0.7, ny + sy * 0.7) then hx, hy = true, true end -- a corner
    if hx then vx[i] = -vx[i] else x[i] = nx end
    if hy then vy[i] = vy[i] > 0 and -vy[i] * 0.95 or -vy[i] else y[i] = ny end
  end
  -- collisions: push apart, swap the speeds along the line between them
  for i = 1, N - 1 do
    for j = i + 1, N do
      local dx, dy = x[j] - x[i], y[j] - y[i]
      local d2, rr = dx * dx + dy * dy, r[i] + r[j] + 1
      if d2 < rr * rr and d2 > 0 then
        local d = sqrt(d2)
        local nx, ny = dx / d, dy / d
        local p = (vx[i] - vx[j]) * nx + (vy[i] - vy[j]) * ny
        if p > 0 then
          vx[i], vy[i] = vx[i] - p * nx, vy[i] - p * ny
          vx[j], vy[j] = vx[j] + p * nx, vy[j] + p * ny
        end
        local push = (rr - d) / 2
        x[i], y[i], x[j], y[j] = x[i] - nx * push, y[i] - ny * push, x[j] + nx * push, y[j] + ny * push
      end
    end
  end
  -- a kick now and then, so they never settle
  t = t + 1
  if t % 400 == 0 then for i = 1, N do vy[i] = vy[i] - 1.5 - random() end end
  clearDisplay()
  for i = 1, N do fillCircle(floor(x[i]), floor(y[i]), r[i], cr[i], cg[i], cb[i]) end
  updateDisplay()
  pace()
end
