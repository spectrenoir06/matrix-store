-- A sun: rays all around, each one a frequency band, slowly turning.
local mx, my = getMatrix()
local floor, sin, cos, pi, max = math.floor, math.sin, math.cos, math.pi, math.max
local cx, cy = (mx - 1) / 2, (my - 1) / 2
local rx, ry = cx, cy -- rays reach the panel's edges, whatever its shape
local rays = 24
local smooth, cs, sn = {}, {}, {}
for i = 1, rays do smooth[i] = 0 end
local spin = 0
-- ~60 frames/s (the microphone's rate): the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = math.floor(t_next - millis())
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local fft = getFFT()
  clearDisplay()
  local bass = (fft[2] + fft[3]) / 2
  local core = 0.16 + bass / 2200 -- the core breathes with the bass
  for i = 1, rays do
    -- mirrored left / right: bass at the top, highs at the bottom
    local k = i <= rays / 2 and i or rays + 1 - i
    smooth[i] = max(fft[1 + floor(k * 5)], smooth[i] * 0.85)
    local reach = core + (smooth[i] / 255) ^ 0.7 * (1 - core)
    local a = (i - 1) / rays * 2 * pi + spin - pi / 2
    local dx, dy = cos(a) * rx, sin(a) * ry
    local r, g, b = colorWheel(floor(i * 256 / rays + spin * 60) % 256)
    drawLine(floor(cx + dx * core + 0.5), floor(cy + dy * core + 0.5), floor(cx + dx * reach + 0.5), floor(cy + dy * reach + 0.5), r, g, b)
  end
  -- the core: a disc, a row at a time
  local c = floor(math.min(255, 140 + bass / 2))
  local hy = core * ry
  for y = -floor(hy), floor(hy) do
    local hx = floor(core * rx * math.sqrt(1 - (y / (hy + 0.5)) ^ 2) + 0.5)
    fillRect(floor(cx - hx + 0.5), floor(cy + y + 0.5), 2 * hx, 1, c, floor(c * 0.8), floor(c / 4))
  end
  spin = spin + 0.006
  updateDisplay()
  pace()
end
