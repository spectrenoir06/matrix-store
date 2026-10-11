-- A word that jumps on every beat: bigger, new color, then settles.
local word = "BASS"
local mx, my = getMatrix()
local floor = math.floor
local avg, last, hue, punch = 0, 0, 0, 0
setTextWrap(false)
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
  if bass > avg * 1.3 and bass > 110 and millis() - last > 150 then
    last = millis()
    hue = (hue + 70) % 256
    punch = 1
  end
  avg = avg * 0.92 + bass * 0.08
  local size = punch > 0.5 and 2 or 1
  if mx < #word * 12 then size = 1 end
  local w, h = #word * 6 * size, 8 * size
  clearDisplay()
  -- a flash behind the word on the beat
  if punch > 0.7 then
    local r, g, b = colorWheel((hue + 128) % 256)
    fillDisplay(floor(r / 6), floor(g / 6), floor(b / 6))
  end
  local r, g, b = colorWheel(hue)
  setTextSize(size)
  setTextColor(r, g, b)
  setCursor(floor((mx - w) / 2) + 1, floor((my - h) / 2) + 1)
  printText(word)
  punch = punch * 0.85
  updateDisplay()
  pace()
end
