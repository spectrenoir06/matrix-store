-- Boids: a flock. Each bird keeps its distance, flies like its neighbors
-- and stays with the group; the color shows where it heads.
local mx, my = getMatrix()
local random, floor, sqrt, atan, pi = math.random, math.floor, math.sqrt, math.atan, math.pi
local N = 24
local x, y, vx, vy = {}, {}, {}, {}
for i = 1, N do
  x[i], y[i] = random() * mx, random() * my
  local a = random() * 2 * pi
  vx[i], vy[i] = math.cos(a) * 0.6, math.sin(a) * 0.6
end
local function wrap(d, size) -- the shortest way across the edges
  if d > size / 2 then return d - size elseif d < -size / 2 then return d + size end
  return d
end
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  for i = 1, N do
    local ax, ay, cx, cy, sx, sy, n = 0, 0, 0, 0, 0, 0, 0
    for j = 1, N do
      if i ~= j then
        local dx, dy = wrap(x[j] - x[i], mx), wrap(y[j] - y[i], my)
        local d2 = dx * dx + dy * dy
        if d2 < 100 then -- a neighbor (10 px)
          ax, ay = ax + vx[j], ay + vy[j]
          cx, cy = cx + dx, cy + dy
          n = n + 1
          if d2 < 9 then sx, sy = sx - dx, sy - dy end -- too close
        end
      end
    end
    if n > 0 then
      vx[i] = vx[i] + (ax / n - vx[i]) * 0.05 + cx / n * 0.004 + sx * 0.03
      vy[i] = vy[i] + (ay / n - vy[i]) * 0.05 + cy / n * 0.004 + sy * 0.03
    end
    local s = sqrt(vx[i] * vx[i] + vy[i] * vy[i])
    local target = 0.7
    if s > 0 then vx[i], vy[i] = vx[i] / s * target, vy[i] / s * target end
  end
  clearDisplay()
  for i = 1, N do
    x[i], y[i] = (x[i] + vx[i]) % mx, (y[i] + vy[i]) % my
    local r, g, b = colorWheel(floor((atan(vy[i], vx[i]) / pi + 1) * 128) % 256)
    drawPixel(floor(x[i]), floor(y[i]), r, g, b)
    drawPixel(floor((x[i] - vx[i] * 1.5) % mx), floor((y[i] - vy[i] * 1.5) % my), r // 2, g // 2, b // 2) -- not dimmer: black at 4 bits
  end
  updateDisplay()
  pace(20)
end
