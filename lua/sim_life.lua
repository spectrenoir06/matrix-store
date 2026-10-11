-- Game of Life on a torus: cells born in bright colors, survivors calmer.
-- The grid is bits, 32 cells per integer: tiny in memory. Starts again
-- with a new random field when it gets stuck.
local mx, my = getMatrix()
local random, floor = math.random, math.floor
-- big panels: cells of CxC pixels (the grid stays small, scripts have 30 KB)
local C = 1
while (mx // C) * (my // C) > 2400 do C = C + 1 end
local pw, ph = mx, my
mx, my = pw // C, ph // C
local WORDS = (mx + 31) // 32 -- integers per row
local cur, nxt = {}, {}
local function get(g, x, y)
  x, y = x % mx, y % my
  return (g[y * WORDS + (x >> 5) + 1] >> (x & 31)) & 1
end
local function seed()
  for i = 1, WORDS * my do cur[i] = 0 end
  for y = 0, my - 1 do
    for x = 0, mx - 1 do
      if random() < 0.3 then
        local i = y * WORDS + (x >> 5) + 1
        cur[i] = cur[i] | (1 << (x & 31))
      end
    end
  end
end
seed()
local hue, gen, last_pop, same = 0, 0, -1, 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  local pop = 0
  for i = 1, WORDS * my do nxt[i] = 0 end
  clearDisplay()
  local br, bg, bb = colorWheel(hue)
  local sr, sg, sb = colorWheel((hue + 40) % 256)
  sr, sg, sb = sr // 4, sg // 4, sb // 4
  for y = 0, my - 1 do
    for x = 0, mx - 1 do
      local n = get(cur, x - 1, y - 1) + get(cur, x, y - 1) + get(cur, x + 1, y - 1)
              + get(cur, x - 1, y) + get(cur, x + 1, y)
              + get(cur, x - 1, y + 1) + get(cur, x, y + 1) + get(cur, x + 1, y + 1)
      local alive = get(cur, x, y) == 1
      if n == 3 or (alive and n == 2) then
        local i = y * WORDS + (x >> 5) + 1
        nxt[i] = nxt[i] | (1 << (x & 31))
        pop = pop + 1
        if alive then fillRect(x * C, y * C, C, C, sr, sg, sb) else fillRect(x * C, y * C, C, C, br, bg, bb) end
      end
    end
  end
  updateDisplay()
  cur, nxt = nxt, cur
  gen = gen + 1
  hue = (hue + 1) % 256
  -- stuck (same population for long, or empty): a new field
  if pop == last_pop then same = same + 1 else same = 0 end
  last_pop = pop
  if pop == 0 or same > 40 or gen > 1500 then seed(); gen = 0; same = 0 end
  pace(80)
end
