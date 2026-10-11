-- Fire: flames rising from the bottom. Each cell takes the heat of the ones
-- below it, a little cooler. Cells of 2x2 pixels (bigger on big panels):
-- the grid stays ~700 cells, scripts have 30 KB.
local mx, my = getMatrix()
local floor, random, min = math.floor, math.random, math.min
local C = 2 -- cell size
while (mx // C) * (my // C + 2) > 700 do C = C + 1 end
local W, H = mx // C, my // C + 2 -- two extra rows below the screen: the fuel
local heat = {}
for i = 1, W * H do heat[i] = 0 end
-- palette, 64 steps: black, dark red, red, orange, yellow, white
local pr, pg, pb = {}, {}, {}
for i = 0, 63 do
  local t = i / 63
  pr[i] = floor(min(1, t * 3) * 255)
  pg[i] = floor(min(1, math.max(0, t * 3 - 1)) * 255)
  pb[i] = floor(min(1, math.max(0, t * 3 - 2)) * 255)
end
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  -- fuel: random hot spots on the two bottom rows
  for x = 1, W do
    heat[(H - 1) * W + x] = random(0, 3) == 0 and 255 or random(120, 200)
    heat[(H - 2) * W + x] = random(140, 255)
  end
  -- rise: the average of the cells below, minus a little (the cooling)
  for y = 0, H - 3 do
    local row, below, below2 = y * W, (y + 1) * W, (y + 2) * W
    for x = 1, W do
      local l, r = x > 1 and x - 1 or W, x < W and x + 1 or 1
      local h = (heat[below + l] + heat[below + x] + heat[below + r] + heat[below2 + x]) >> 2
      h = h - random(6, 22) -- cooling: the flames die out as they rise
      heat[row + x] = h > 0 and h or 0
    end
  end
  clearDisplay()
  for y = 0, H - 3 do
    local row = y * W
    for x = 1, W do
      local h = heat[row + x] >> 2
      if h > 2 then fillRect((x - 1) * C, y * C, C, C, pr[h], pg[h], pb[h]) end
    end
  end
  updateDisplay()
  pace(30)
end
