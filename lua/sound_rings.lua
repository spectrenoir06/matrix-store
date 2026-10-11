-- Each beat sends a ring of color out from the center.
local mx, my = getMatrix()
local floor = math.floor
local cx, cy = mx / 2, my / 2
local reach = math.sqrt(cx * cx + cy * cy)
local rings = {} -- {radius, hue}
local avg, last, hue = 0, 0, 0
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
    hue = (hue + 40) % 256
    rings[#rings + 1] = { 1, hue }
  end
  avg = avg * 0.92 + bass * 0.08
  clearDisplay()
  -- the core glows with the bass
  local glow = floor(bass / 4)
  fillRect(floor(cx) - 1, floor(cy) - 1, 2, 2, glow, glow, glow)
  for i = #rings, 1, -1 do
    local rg = rings[i]
    local rad, fade = rg[1], 0.3 + 0.7 * (1 - rg[1] / reach) -- not to black: dim is black at 4 bits
    local r, g, b = colorWheel(rg[2])
    r, g, b = floor(r * fade), floor(g * fade), floor(b * fade)
    drawCircle(floor(cx), floor(cy), floor(rad), r, g, b)
    rg[1] = rad + 0.8
    if rg[1] > reach then table.remove(rings, i) end
  end
  updateDisplay()
  pace()
end
