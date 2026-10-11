-- Space invaders: sprites written as text (drawSprite), two frames,
-- marching and stepping down; a cannon shoots back. The title is centered
-- with textWidth.
local mx, my = getMatrix()
local S = math.max(1, math.min(mx, my) // 40) -- bigger pixels on big panels
local A = [[
..x.....x..
...x...x...
..xxxxxxx..
.xx.xxx.xx.
xxxxxxxxxxx
x.xxxxxxx.x
x.x.....x.x
...xx.xx...]]
local B = [[
..x.....x..
x..x...x..x
x.xxxxxxx.x
xxx.xxx.xxx
xxxxxxxxxxx
.xxxxxxxxx.
..x.....x..
.x.......x.]]
local CANNON = [[
..c..
ccccc
ccccc]]
local ROWS = { 0x40FF60, 0x40C0FF, 0xFF40C0 }

setTextSize(S)
local tw, th = textWidth("INVADERS")
clearDisplay()
setTextColor(80, 255, 120)
setCursor((mx - tw) // 2, (my - th) // 2)
printText("INVADERS")
updateDisplay()
delay(1500)

local cols = math.max(1, (mx - 4 * S) // (14 * S))
local nrows = math.max(1, math.min(3, (my - 8 * S) // (11 * S)))
local ox, oy, dir, frame, step = 0, 0, 1, 0, 0
local gun, shot_x, shot_y = mx // 2, -1, -1
local t_next = millis()
while true do
  step = step + 1
  if step % 12 == 0 then -- the march: a step aside, down at the edge
    frame = 1 - frame
    ox = ox + dir * S
    if ox < 0 or ox + cols * 14 * S > mx then
      dir, ox, oy = -dir, ox - dir * S, oy + 2 * S
      if oy + nrows * 11 * S > my - 6 * S then oy = 0 end
    end
  end
  gun = gun + (math.random(0, 2) - 1) * S
  gun = math.max(0, math.min(mx - 5 * S, gun))
  if shot_y < 0 and math.random() < 0.05 then shot_x, shot_y = gun + 2 * S, my - 4 * S end
  clearDisplay()
  for r = 1, nrows do
    for c = 0, cols - 1 do
      drawSprite(ox + c * 14 * S + S, oy + (r - 1) * 11 * S, frame == 0 and A or B, { x = ROWS[r] }, S)
    end
  end
  drawSprite(gun, my - 3 * S, CANNON, { c = 0x80FF80 }, S)
  if shot_y >= 0 then
    drawVLine(shot_x, shot_y, 3 * S, 255, 255, 255)
    shot_y = shot_y - 2 * S
  end
  updateDisplay()
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
