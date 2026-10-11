-- Digital rain: green streams falling down each column, a bright head and
-- a tail that fades.
local mx, my = getMatrix()
local random, floor = math.random, math.floor
local head, speed, len = {}, {}, {}
for x = 1, mx do
  head[x] = random(-my * 2, my)
  speed[x] = 0.2 + random() * 0.5
  len[x] = random(6, 16)
end
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  clearDisplay()
  for x = 1, mx do
    head[x] = head[x] + speed[x]
    local h = floor(head[x])
    if h - len[x] > my then -- gone: a new stream starts above the top
      head[x] = random(-my, 0)
      speed[x] = 0.2 + random() * 0.5
      len[x] = random(6, 16)
    end
    for k = 0, len[x] - 1 do
      local y = h - k
      if y >= 0 and y < my then
        if k == 0 then
          drawPixel(x - 1, y, 180, 255, 180)
        else
          local g = floor(220 * (1 - k / len[x])) + 20
          drawPixel(x - 1, y, 0, g, g // 6)
        end
      end
    end
  end
  updateDisplay()
  pace()
end
