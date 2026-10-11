-- Vicsek zoom, for the cross (96x96): the cross is the first step of the
-- Vicsek fractal (a square cut 3x3, the plus kept, again and again). An
-- endless zoom into it, x3 every 4 beats at 130 BPM. One eighth is drawn,
-- mirror "k" copies it 8 ways. Integer math: a pixel's place in the square
-- in 3^7ths, its base-3 digits say how deep its hole is.
local floor, min = math.floor, math.min
local BEAT = 60000 / 130
local U = 2187 -- 3^7
local P = { 729, 243, 81, 27, 9, 3 }
local YO, COL = {}, {}
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local z = b / 4 -- zoom: x3 per unit
  local c = floor(z)
  local S = 96 * 3 ^ (z - c)
  local kick = (1 - b % 1) ^ 2
  local hue = floor(b * 6)
  local green = floor(b / 32) % 2 == 1
  for k = 0, 6 do -- a color per depth: the same hole keeps its color while zooming
    local d = k + c
    local r, g, bl
    if k == 6 then r, g, bl = 255, 255, 255
    elseif green then
      g = (d % 3 == 0) and 255 or 60 + (d & 1) * 60
      r, bl = (d % 3 == 0) and floor(200 * kick) or 0, floor(g * 0.3)
    else r, g, bl = hsv(d * 37 + hue, 230, min(255, 70 + k * 30 + floor(120 * kick * (d & 1)))) end
    COL[k] = r << 16 | g << 8 | bl
  end
  local step = floor(U * 65536 / S) -- 16.16 fixed point
  local base = U * 32768 + floor(47.5 * step)
  for y = 32, 47 do
    local yu = (base - y * step) >> 16
    for k = 1, 6 do YO[k] = yu // P[k] % 3 == 1 end
    local xb = base
    for x = 0, y do
      local xu = xb >> 16
      xb = xb - step
      local k = 1
      while k <= 6 and (YO[k] or xu // P[k] % 3 == 1) do k = k + 1 end
      local col = COL[k - 1]
      drawPixel(x, y, col >> 16, col >> 8 & 255, col & 255)
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
