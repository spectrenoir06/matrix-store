-- Langton's ants: on a white cell turn left, on a black one turn right,
-- flip the cell, step. Three ants, three colors: chaos, then highways.
local mx, my = getMatrix()
local random = math.random
local WORDS = (mx + 31) // 32
local grid = {}
local DX, DY = { 0, 1, 0, -1 }, { -1, 0, 1, 0 } -- up, right, down, left
local ants = {}
local function reset()
  for i = 1, WORDS * my do grid[i] = 0 end
  clearDisplay(); updateDisplay(true)
  ants = {}
  for k = 1, 3 do
    local r, g, b = colorWheel((k - 1) * 85)
    ants[k] = { x = random(mx // 4, 3 * mx // 4), y = random(my // 4, 3 * my // 4), d = random(1, 4), r = r, g = g, b = b }
  end
end
reset()
local steps = 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  for n = 1, 12 do
    for _, a in ipairs(ants) do
      local i = a.y * WORDS + (a.x >> 5) + 1
      local bit = 1 << (a.x & 31)
      if grid[i] & bit ~= 0 then
        a.d = (a.d + 2) % 4 + 1 -- set: turn left
        grid[i] = grid[i] & ~bit
        drawPixel(a.x, a.y, 0, 0, 0)
      else
        a.d = a.d % 4 + 1 -- clear: turn right
        grid[i] = grid[i] | bit
        drawPixel(a.x, a.y, a.r, a.g, a.b)
      end
      a.x, a.y = (a.x + DX[a.d]) % mx, (a.y + DY[a.d]) % my
    end
  end
  updateDisplay(true) -- the next frame starts from this one: only changes are drawn
  steps = steps + 1
  if steps > 1500 then reset(); steps = 0 end
  pace(30)
end
