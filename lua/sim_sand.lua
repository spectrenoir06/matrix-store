-- Falling sand: colored grains pour from a moving spout and pile up,
-- sliding down the slopes. When the pile reaches the top: start again.
-- Where grains are: bits (32 per integer). Their color: on the screen.
-- No panel (the cross's corners) is a wall: sand piles on the arms.
local mx, my = getMatrix()
local random, floor = math.random, math.floor
-- the panels' shape (the cross has no corners): a pixel drawn and read back;
-- per row, the first and last that exist
local L, R = {}, {}
for y = 1, my do
  L[y], R[y] = mx, -1
  for x = 0, mx - 1 do
    drawPixel(x, y - 1, 255, 255, 255)
    if getPixel(x, y - 1) > 0 then L[y] = math.min(L[y], x); R[y] = x end
  end
end
clearDisplay()
local function on(x, y) return y >= 0 and y < my and x >= L[y + 1] and x <= R[y + 1] end
local WORDS = (mx + 31) // 32
local occ = {}
local function clear_all()
  for i = 1, WORDS * my do occ[i] = 0 end
  clearDisplay(); updateDisplay(true)
end
local function is(x, y)
  if y < 0 then return false end
  if not on(x, y) then return true end -- walls, floor, no panel
  return (occ[y * WORDS + (x >> 5) + 1] >> (x & 31)) & 1 == 1
end
local function set(x, y, on)
  local i = y * WORDS + (x >> 5) + 1
  if on then occ[i] = occ[i] | (1 << (x & 31)) else occ[i] = occ[i] & ~(1 << (x & 31)) end
end
clear_all()
local spout, dir, hue, t, blocked = (L[1] + R[1]) // 2, 1, 0, 0, 0
-- ~60 frames/s at most: the same speed on the matrix and in the app
local t_next = millis()
local function pace(ms)
  t_next = t_next + (ms or 16)
  local wait = t_next - millis()
  if wait > 0 then delay(wait) else t_next = millis() end
end
while true do
  -- new grains
  local added = 0
  for k = 1, 2 do
    local x = spout + random(-1, 1)
    if x >= 0 and x < mx and not is(x, 0) then
      local r, g, b = colorWheel(hue)
      set(x, 0, true)
      drawPixel(x, 0, r, g, b)
      added = added + 1
    end
  end
  -- fall, from the bottom up; rows scanned in alternating directions
  for y = my - 2, 0, -1 do
    local x0, x1, step = 0, mx - 1, 1
    if (y + t) % 2 == 1 then x0, x1, step = mx - 1, 0, -1 end
    for x = x0, x1, step do
      if on(x, y) and is(x, y) then -- a grain (not a wall: is() says walls too)
        local nx = nil
        if not is(x, y + 1) then nx = x
        else
          local a, b = x - 1, x + 1
          if random(0, 1) == 1 then a, b = b, a end
          if not is(a, y + 1) then nx = a elseif not is(b, y + 1) then nx = b end
        end
        if nx then
          local r, g, b = getPixel(x, y)
          set(x, y, false); set(nx, y + 1, true)
          drawPixel(x, y, 0, 0, 0)
          drawPixel(nx, y + 1, r, g, b)
        end
      end
    end
  end
  updateDisplay(true) -- the next frame starts from this one: only changes are drawn
  -- the spout wanders, the color shifts
  spout = spout + dir
  if spout <= L[1] + 2 or spout >= R[1] - 2 or random(0, 40) == 0 then dir = -dir end
  hue = (hue + 1) % 256
  t = t + 1
  -- full (the spout can't pour for a while): again
  if added == 0 then blocked = blocked + 1 else blocked = 0 end
  if blocked > 40 then delay(800); clear_all(); blocked = 0 end
  pace(25)
end
