-- Dream, for the cross (96x96): noise bent by waves, its contour lines
-- breathing and crawling like the walls on a trip, colors drifting, the
-- lines flashing on the beat (130 BPM). One eighth is drawn, mirror "k"
-- copies it 8 ways. Colors from a table (a ramp per band, white lines).
local floor, sin = math.floor, math.sin
local BEAT = 60000 / 130
local WX, WY, PAL = {}, {}, {}
local t0, t_next, frame = millis(), millis(), 0
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 4
  if frame % 6 == 0 then -- the colors drift
    local hue, line = floor(b * 4), 200 + floor(55 * kick)
    for k = 0, 255 do
      local e = k & 31
      if e < 3 then PAL[k] = line * 0x10101
      else
        local r, g, bl = hsv(hue + k, 240, 60 + e * 6)
        PAL[k] = r << 16 | g << 8 | bl
      end
    end
  end
  frame = frame + 1
  local zoom = 0.028 + 0.01 * sin(b * 0.07) -- breathing
  for x = 0, 47 do WX[x] = 0.7 * sin(x * 0.11 + b * 0.13) end -- the bending waves
  for y = 32, 47 do WY[y] = 0.7 * sin(y * 0.17 - b * 0.09) end
  local t, flow = b * 0.05, b * 12
  for y = 32, 47 do
    local fy, wy = (47.5 - y) * zoom, WY[y]
    for x = 0, y do
      local fx = (47.5 - x) * zoom
      local c = PAL[floor(noise(fx + wy, fy + WX[x], t) * 220 + flow) & 255]
      drawPixel(x, y, c >> 16, c >> 8 & 255, c & 255)
    end
  end
  mirror("k")
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
