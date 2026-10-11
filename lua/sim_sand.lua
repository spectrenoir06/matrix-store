-- Falling sand: colored grains pour from a moving spout and pile up,
-- sliding down the slopes. When the pile reaches the top: start again.
-- A grain is a lit pixel (the screen is the grid: no table); no panel (the
-- cross's corners) is a wall. Fast: only where something can move is looked
-- at, a span per row, not the whole pile.
local mx, my = getMatrix()
local random = math.random
-- per row: the panels (first*1024+last pixel that lights), the span to check
local S, D = {}, {}
for y = 1, my do
  local a, b = mx, -1
  for x = 0, mx - 1 do
    drawPixel(x, y - 1, 255, 255, 255)
    if getPixel(x, y - 1) > 0 then
      if x < a then a = x end
      b = x
    end
  end
  S[y], D[y] = a * 1024 + b, -1
end
local function is(x, y) -- a grain or a wall
  if y < 0 then return false end
  if y >= my then return true end
  local s = S[y + 1]
  if x < s // 1024 or x > s % 1024 then return true end
  local r, g, b = getPixel(x, y)
  return r + g + b > 0
end
local function mark(y, a, b) -- look at row y, x a..b
  if y < 0 then return end
  if a < 0 then a = 0 end
  if b >= mx then b = mx - 1 end
  local s = D[y + 1]
  if s >= 0 then
    if s // 1024 < a then a = s // 1024 end
    if s % 1024 > b then b = s % 1024 end
  end
  D[y + 1] = a * 1024 + b
end
local L1, R1 = S[1] // 1024, S[1] % 1024 -- the top row: where the spout moves
local spout, dir, hue, t, blocked = (L1 + R1) // 2, 1, 0, 0, 0
clearDisplay(); updateDisplay(true)
local t_next = millis()
while true do
  local added = 0
  for k = 1, 2 do -- new grains
    local x = spout + random(-1, 1)
    if not is(x, 0) then
      drawPixel(x, 0, colorWheel(hue))
      mark(0, x, x)
      added = added + 1
    end
  end
  -- fall, bottom up (rows each way in turn): a row's span is taken as it is
  -- looked at; marks above count this frame, marks below the next
  for y = my - 2, 0, -1 do
    local s = D[y + 1]
    if s >= 0 then
      D[y + 1] = -1
      local x0, x1, step = s // 1024, s % 1024, 1
      if (y + t) % 2 == 1 then x0, x1, step = x1, x0, -1 end
      for x = x0, x1, step do
        local r, g, b = getPixel(x, y)
        if r + g + b > 0 then
          local nx
          if not is(x, y + 1) then nx = x
          else
            local a, c = x - 1, x + 1
            if random(0, 1) == 1 then a, c = c, a end
            if not is(a, y + 1) then nx = a elseif not is(c, y + 1) then nx = c end
          end
          if nx then
            drawPixel(x, y, 0, 0, 0)
            drawPixel(nx, y + 1, r, g, b)
            mark(y + 1, nx, nx) -- it falls on
            mark(y - 1, x - 1, x + 1) -- those above may follow
          end
        end
      end
    end
  end
  updateDisplay(true) -- the next frame starts from this one
  spout = spout + dir
  if spout <= L1 + 2 or spout >= R1 - 2 or random(0, 40) == 0 then dir = -dir end
  hue = (hue + 1) % 256
  t = t + 1
  if added == 0 then blocked = blocked + 1 else blocked = 0 end
  if blocked > 40 then -- full: again
    delay(800)
    clearDisplay(); updateDisplay(true)
    for y = 1, my do D[y] = -1 end
    blocked = 0
  end
  t_next = t_next + 25
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
