-- The spectrum as bars, a flash on the beat (the matrix's microphone).
-- getFFT(): 128 levels 0..255, low to high frequencies (0 - 8 kHz)
local mx, my = getMatrix()
local floor = math.floor
local avg = 0
while true do
  local fft = getFFT()
  clearDisplay()
  for x = 0, mx - 1 do
    -- the low half of the spectrum, where music is
    local v = fft[1 + floor(x * 64 / mx)]
    local h = floor(v * my / 255)
    local r, g, b = colorWheel(floor(x * 255 / mx))
    fillRect(x, my - h, 1, h, r, g, b)
  end
  -- a beat: the bass well above its average
  local bass = (fft[2] + fft[3] + fft[4]) / 3
  if bass > avg * 1.3 and bass > 120 then
    fillRect(0, 0, mx, 2, 255, 255, 255)
  end
  avg = avg * 0.95 + bass * 0.05
  updateDisplay()
end
