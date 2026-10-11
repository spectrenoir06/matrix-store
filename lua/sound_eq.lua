-- Hi-fi equalizer: bars green → yellow → red, peaks that fall back slowly.
local mx, my = getMatrix()
local floor, max, min = math.floor, math.max, math.min
local bars = 16
local bw = floor(mx / bars)
local level, peak, edges = {}, {}, {}
-- bins per bar: few for the bass, many for the highs
for i = 0, bars do edges[i] = floor(1 + 63 * (i / bars) ^ 2) end
for i = 1, bars do level[i] = 0; peak[i] = 0 end
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
  for i = 1, bars do
    local s, n = 0, 0
    for k = edges[i - 1], max(edges[i - 1], edges[i] - 1) do s = s + fft[k + 1]; n = n + 1 end
    level[i] = max(s / n * my / 255, level[i] * 0.85) -- up at once, down smoothly
    peak[i] = level[i] > peak[i] and level[i] or max(0, peak[i] - 0.35)
    local x, h = (i - 1) * bw, floor(level[i])
    for y = 0, h - 1 do
      local t = y / my
      fillRect(x, my - 1 - y, bw - 1, 1, floor(255 * min(1, t * 2)), floor(255 * min(1, 2 - t * 2)), 0)
    end
    fillRect(x, my - 1 - min(my - 1, floor(peak[i])), bw - 1, 1, 255, 255, 255)
  end
  updateDisplay()
  pace()
end
