-- Fireworks: each beat bursts a rocket of sparks that fall and fade.
local mx, my = getMatrix()
local floor, random, sin, cos, pi = math.floor, math.random, math.sin, math.cos, math.pi
local N = 72 -- sparks at most (memory: the script has 30 KB)
local px, py, vx, vy, life, cr, cg, cb = {}, {}, {}, {}, {}, {}, {}, {}
for i = 1, N do life[i] = 0 end
local avg, last = 0, -1000
local fx, fy, flash = 0, 0, 0 -- where the last rocket burst
local function burst()
  local x, y = random(8, mx - 9), random(3, floor(my / 2))
  fx, fy, flash = x, y, 1
  local r, g, b = colorWheel(random(0, 255))
  local made = 0
  for i = 1, N do
    if life[i] <= 0 and made < 24 then
      local a, s = random() * 2 * pi, 0.3 + random() * 0.9
      px[i], py[i], vx[i], vy[i] = x, y, cos(a) * s, sin(a) * s - 0.3
      life[i], cr[i], cg[i], cb[i] = 1, r, g, b
      made = made + 1
    end
  end
end
-- ~60 frames/s (the microphone's rate): the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = math.floor(t_next - millis())
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local fft = getFFT()
  local bass = (fft[2] + fft[3] + fft[4]) / 3
  if bass > avg * 1.3 and bass > 110 and millis() - last > 200 then
    last = millis()
    burst()
  end
  avg = avg * 0.92 + bass * 0.08
  clearDisplay()
  if flash > 0.1 then -- the burst itself: a white flash
    local c = floor(255 * flash)
    fillRect(fx - 1, fy - 1, 3, 3, c, c, c)
    flash = flash * 0.7
  end
  for i = 1, N do
    if life[i] > 0 then
      px[i], py[i] = px[i] + vx[i], py[i] + vy[i]
      vy[i] = vy[i] + 0.04 -- gravity
      vx[i] = vx[i] * 0.98
      life[i] = life[i] - 0.018
      local x, y, l = floor(px[i]), floor(py[i]), math.sqrt(math.max(0, life[i]))
      if l > 0 and x >= 0 and x < mx and y < my then
        drawPixel(x, y, floor(cr[i] * l), floor(cg[i] * l), floor(cb[i] * l))
      end
    end
  end
  updateDisplay()
  pace()
end
