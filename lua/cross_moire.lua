-- Moire, for the cross (96x96): op-art. Zone plates (rings closer and closer)
-- around 5 points, the center and 4 sliding along the arms, crossed with
-- XOR: interference patterns that boil. Black and a color changing every 4
-- beats, inverted on the kick (130 BPM). One eighth is drawn, mirror "k"
-- copies it 8 ways. Integer math only: squared distances, in half pixels.
local floor, sin = math.floor, math.sin
local BEAT = 60000 / 130
local X0, XM, XP = {}, {}, {}
local t0, t_next = millis(), millis()
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 4
  local A = floor(48 + 40 * sin(b * 0.11)) -- where the 4 points are (half pixels)
  local K = floor(110 + 70 * sin(b * 0.07)) -- how fast the rings get close
  local G = floor(b * 20000) & 0x1ffff -- the rings flowing
  local r, g, bl = hsv(floor(b / 4) * 67, floor(b / 4) % 3 == 0 and 0 or 255, 255)
  local r2, g2, b2 = 0, 0, 0
  if kick > 0.5 and floor(b) % 2 == 1 then r, g, bl, r2, g2, b2 = 0, 0, 0, r, g, bl end
  for x = 0, 47 do
    local X = 95 - 2 * x
    X0[x], XM[x], XP[x] = X * X * K, (X - A) * (X - A) * K, (X + A) * (X + A) * K
  end
  for y = 32, 47 do
    local Y = 95 - 2 * y
    local y0, ym, yp = Y * Y * K, (Y - A) * (Y - A) * K, (Y + A) * (Y + A) * K
    local g0, gm, gp = y0 + G, ym + G, yp + G
    for x = 0, y do
      local x0 = X0[x]
      local n = ((x0 + g0) >> 16) + ((XM[x] + g0) >> 16) + ((XP[x] + g0) >> 16)
        + ((x0 + gm) >> 16) + ((x0 + gp) >> 16)
      if n & 1 == 1 then drawPixel(x, y, r, g, bl) else drawPixel(x, y, r2, g2, b2) end
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
