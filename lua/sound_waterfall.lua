-- Spectrogram: time scrolls up, bass on the left, loud = hot colors.
-- scroll() moves the picture in C: only the new row is drawn from Lua.
local mx, my = getMatrix()
local floor = math.floor
-- heat palette, 32 steps: black, blue, purple, red, orange, yellow, white
local stops = { {0,0,0}, {0,0,160}, {140,0,180}, {255,0,40}, {255,140,0}, {255,255,60}, {255,255,255} }
local pr, pg, pb = {}, {}, {}
for i = 0, 31 do
  local t = i / 31 * (#stops - 1)
  local a, f = floor(t) + 1, t - floor(t)
  local b = math.min(a + 1, #stops)
  pr[i] = floor(stops[a][1] + (stops[b][1] - stops[a][1]) * f)
  pg[i] = floor(stops[a][2] + (stops[b][2] - stops[a][2]) * f)
  pb[i] = floor(stops[a][3] + (stops[b][3] - stops[a][3]) * f)
end
-- each column's FFT bin: stretched toward the bass, like the ear hears
local bin = {}
for x = 1, mx do bin[x] = floor(1 + 100 * ((x - 1) / mx) ^ 1.7) end
-- a row every 40 ms: about 1.3 s of history on a 32-row panel
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = math.floor(t_next - millis())
  if wait > 0 then delay(wait) else t_next = millis() end
end
clearDisplay()
updateDisplay()
while true do
  local fft = getFFT()
  scroll(0, -1) -- everything up one row
  for x = 1, mx do
    local v = fft[bin[x]] >> 3
    drawPixel(x - 1, my - 1, pr[v], pg[v], pb[v])
  end
  updateDisplay()
  pace(40)
end
