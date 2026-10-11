-- An oscilloscope: the microphone's waveform (getWave(): 128 = silence)
local mx, my = getMatrix()
local floor = math.floor
local t = 0
while true do
  local wave = getWave()
  clearDisplay()
  local last
  for x = 0, mx - 1 do
    local y = floor(wave[1 + floor(x * 127 / (mx - 1))] * (my - 1) / 255)
    local r, g, b = colorWheel(floor(t + x * 2) % 256)
    drawPixel(x, y, r, g, b)
    if last then -- join the dots
      for yy = math.min(last, y), math.max(last, y) do drawPixel(x, yy, r, g, b) end
    end
    last = y
  end
  updateDisplay()
  t = t + 3
end
