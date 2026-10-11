-- Hacker, for the cross (96x96): streams of bits rushing out of the center
-- along the 4 arms, green with white heads, the center a glitching
-- terminal. RGB split and jumps on the kick (130 BPM).
local floor, random = math.floor, math.random
local BEAT = 60000 / 130
local N = 56
local arm, lane, pos, spd = {}, {}, {}, {}
local function spawn(i)
  arm[i], lane[i], pos[i], spd[i] = random(0, 3), random(0, 31), random(-20, 0), 0.6 + random() * 1.4
end
for i = 1, N do spawn(i); pos[i] = random(0, 47) end
-- arm a, distance d from the center panel, lane l: x, y
local function at(a, d, l)
  if a == 0 then return 32 + l, 31 - d end
  if a == 1 then return 64 + d, 32 + l end
  if a == 2 then return 63 - l, 64 + d end
  return 31 - d, 63 - l
end
local WORDS = { "ACID", "LSD!", "DMT?", "TRIP", "HACK", "ROOT", "0xFF", "SUDO", "????", "LOVE" }
local word, hex = WORDS[1], "0000"
local t0, t_next, lastb = millis(), millis(), -1
while true do
  local b = (millis() - t0) / BEAT
  local kick = (1 - b % 1) ^ 3
  local beat = floor(b)
  local glitch = kick > 0.6 and beat % 4 == 3
  if beat ~= lastb then
    lastb = beat
    if beat % 2 == 0 then word = WORDS[random(#WORDS)] end
  end
  hex = string.format("%04X", random(0, 0xFFFF))
  if glitch then scroll(random(-4, 4), random(-4, 4), true) end
  fadeDisplay(200)
  for i = 1, N do
    local d0 = floor(pos[i])
    pos[i] = pos[i] + spd[i] * (1 + 2 * kick)
    local d = floor(pos[i])
    if d > 31 then spawn(i)
    elseif d >= 0 then
      local x, y = at(arm[i], d, lane[i])
      if d0 >= 0 and d0 ~= d then -- the pixel behind the head, green
        local px, py = at(arm[i], d0, lane[i])
        drawPixel(px, py, 0, 255, 60)
      end
      drawPixel(x, y, 220, 255, 220)
    end
  end
  -- the center: a terminal
  fillRect(32, 32, 32, 32, 0, 0, 0)
  local v = 120 + floor(135 * kick)
  drawRect(32, 32, 32, 32, 0, v, v // 3)
  setTextSize(1)
  if glitch then
    setTextColor(255, 0, 60); setCursor(36 + random(1, 3), 44); printText(word)
    setTextColor(0, 200, 255); setCursor(36 - random(1, 3), 44); printText(word)
  end
  setTextColor(230, 255, 230); setCursor(36, 44); printText(word)
  setTextColor(0, 160, 50); setCursor(36, 35); printText(hex)
  setCursor(36, 54); printText(floor(b * 4) % 2 == 0 and "> _" or ">")
  updateDisplay(true)
  t_next = t_next + 30
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
