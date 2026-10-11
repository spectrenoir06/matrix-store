-- Pharmacy cross, techno: for the cross (96x96, 5 panels of 32x32).
-- At 130 BPM, a new show every 16 beats: pulse, tunnel, arms chase,
-- scanner, heartbeat, glitch, spinning plus. Mostly fillRect: fast.
local floor, sin, cos, random, abs, min = math.floor, math.sin, math.cos, math.random, math.abs, math.min
local BEAT = 60000 / 130

-- a filled cross, arms L from the center, as wide as L / 1.5
local function X(L, r, g, b)
  if L < 3 then return end
  local w = L // 3
  fillRect(48 - w, 48 - L, 2 * w, 2 * L, r, g, b)
  fillRect(48 - L, 48 - w, 2 * L, 2 * w, r, g, b)
end

local ARMS = { 32, 0, 64, 32, 32, 64, 0, 32 } -- top, right, bottom, left
local ecg, eh, lb = {}, 1, 0
for i = 1, 96 do ecg[i] = 48 end
local function heart(p) -- one heartbeat, p 0..1: up is negative
  if p < .08 then return -3 * sin(p / .08 * 3.14) end
  if p < .1 then return 0 end
  if p < .12 then return 4 end
  if p < .15 then return -14 end
  if p < .18 then return 8 end
  if p > .3 and p < .45 then return -4 * sin((p - .3) / .15 * 3.14) end
  return 0
end

local shows = {
  function(b, e) -- pulse on the kick, white every 4
    local v = floor(90 + 165 * e)
    if floor(b) % 4 == 0 then X(48, v, v, v) else X(48, 0, v, v // 3) end
    X(30, 0, 0, 0)
    X(24, 0, floor(255 - 195 * e), 40)
  end,
  function(b) -- tunnel: crosses flowing out
    for k = 8, 1, -1 do
      local i = (k - floor(b * 4)) % 4
      if i == 0 then X(k * 6, 255, 255, 255) elseif i == 1 then X(k * 6, 0, 255, 70) else X(k * 6, 0, 0, 0) end
    end
  end,
  function(b, e) -- arms chase, the center flashing
    X(48, 0, 100, 30)
    local a = floor(b * 4) % 4
    fillRect(ARMS[a * 2 + 1], ARMS[a * 2 + 2], 32, 32, 0, 255, 70)
    local v = floor(90 + 165 * e)
    fillRect(32, 32, 32, 32, v, v, v)
  end,
  function(b) -- scanner
    X(48, 0, 100, 30)
    fillRect(floor(48 + 47 * sin(b * 1.6)) - 1, 0, 3, 96, 255, 255, 255)
    fillRect(0, floor(48 + 47 * sin(b * 2.2 + 1)) - 1, 96, 3, 0, 255, 70)
  end,
  function(b) -- heartbeat across, 2 px a frame
    if b < lb then lb = b end
    for s = 1, 2 do
      eh = eh % 96 + 1
      ecg[eh] = 48 + floor(heart(((lb + (b - lb) * s / 2) / 2) % 1))
    end
    lb = b
    local py = ecg[eh % 96 + 1]
    for x = 0, 95 do
      local y = ecg[(eh + x) % 96 + 1]
      local c = 90 + 165 * x // 95
      fillRect(x, min(y, py) - 1, 1, abs(y - py) + 3, x > 92 and 255 or 0, c, c // 3)
      py = y
    end
  end,
  function(b, e) -- glitch blocks, more on the kick
    for i = 1, 15 + floor(80 * e) do
      local bx, by = random(0, 11), random(0, 11)
      if (bx >= 4 and bx < 8) or (by >= 4 and by < 8) then
        if random() < .3 then fillRect(bx * 8, by * 8, 8, 8, 255, 255, 255)
        else fillRect(bx * 8, by * 8, 8, 8, 0, 255, 70) end
      end
    end
  end,
  function(b, e) -- a plus spinning faster and faster
    X(floor(48 * e) // 3 * 3, 0, 120, 40)
    local a = b * b * .02 + b * .5
    local c, s = cos(a), sin(a)
    for r = -66, 66, 2 do
      fillRect(floor(47 + r * c), floor(47 + r * s), 3, 3, 255, 255, 255)
      fillRect(floor(47 - r * s), floor(47 + r * c), 3, 3, 0, 255, 70)
    end
  end,
}

local t0 = millis()
local t_next = t0
while true do
  local b = (millis() - t0) / BEAT
  local f = b % 1
  clearDisplay()
  if b % 16 < .15 then X(48, 255, 255, 255) -- a flash between shows
  else shows[floor(b / 16) % #shows + 1](b % 16, (1 - f) * (1 - f)) end
  updateDisplay()
  t_next = t_next + 33
  local w = t_next - millis()
  if w > 0 then delay(w) else t_next = millis() end
end
