-- Plasma that dances to the bass: faster and brighter when it hits.
local mx, my = getMatrix()
local floor = math.floor
-- sine table (0..255 → 0..255): math.sin per pixel is too slow
local S = {}
for i = 0, 255 do S[i] = floor(128 + 127 * math.sin(i / 256 * 2 * math.pi)) end
local t, bright = 0, 0.3
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
  t = t + 1 + bass / 40               -- the bass pushes it forward
  bright = math.max(bright * 0.92, 0.25 + bass / 340)
  local ti = floor(t)
  for y = 0, my - 1 do
    local sy = S[(y * 8 + ti) & 255]
    for x = 0, mx - 1 do
      local v = (S[(x * 6 + ti) & 255] + sy + S[(x * 3 + y * 5 - ti) & 255]) // 3
      local r, g, b = colorWheel((v + ti) & 255)
      drawPixel(x, y, floor(r * bright), floor(g * bright), floor(b * bright))
    end
  end
  updateDisplay()
  pace()
end
