-- The sound scrolling by, like a track's waveform: each column as tall as
-- the volume, its color the mix (red bass, green mids, blue highs).
local mx, my = getMatrix()
local floor, min = math.floor, math.min
local cy = my / 2
local function band(fft, a, b) -- average of bins a..b
  local s = 0
  for k = a, b do s = s + fft[k] end
  return s / (b - a + 1)
end
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
  local bass, mid, high = band(fft, 2, 4), band(fft, 5, 30), band(fft, 31, 100)
  local vol = (bass * 2 + mid + high) / 4
  scroll(-1, 0) -- everything left one column
  local h = floor(vol * my / 255 / 2)
  local m = math.max(bass, mid, high, 1)
  local r, g, b = floor(255 * bass / m), floor(255 * mid / m), floor(255 * high / m)
  fillRect(mx - 1, floor(cy - h), 1, 2 * h, r, g, b)
  updateDisplay()
  pace(30)
end
