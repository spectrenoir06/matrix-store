-- No health, for the cross (96x96): the pharmacy that doesn't want your
-- health. A gag every 8 beats (130 BPM): the slogan, a heart rate through
-- the roof, an acid smiley, the side effects.
local floor, sin, cos = math.floor, math.sin, math.cos
setTextWrap(false)
local function T(s, y, z, r, g, b, x) -- x nil: centered
  setTextSize(z)
  setTextColor(r, g, b)
  setCursor(x or 48 - textWidth(s) // 2, y)
  printText(s)
end
local ROLL = { "WE DON'T WANT YOUR HEALTH *", "SIDE EFFECTS: DANCING TILL 8AM, HUGGING STRANGERS, SEEING SOUNDS, TALKING TO PLANTS *" }
local ARMS = { "NO", "THX", "", "BPM", "SMILE", "MORE", "ASK", "DJ" }
local t0, tn = millis(), millis()
while true do
  local b = (millis() - t0) / 461.5
  local k = (1 - b % 1) ^ 3
  local sc, sb = floor(b / 8) % 4, b % 8
  local r, g, bl = hsv(floor(b * 20), 255, 255)
  local v = sc == 0 and floor(100 + 155 * k) or 0 -- 4 bits: under 77 is black
  clearDisplay()
  if sc ~= 2 then
    fillRect(32, 0, 32, 96, sc // 3 * 100, v, v // 4)
    fillRect(0, 32, 96, 32, sc // 3 * 100, v, v // 4)
    fillRect(0, 38, 96, 20, 0, 0, 0)
  end
  T(ARMS[sc * 2 + 1], 12, 1, 255, 255, 255)
  T(ARMS[sc * 2 + 2], 76, 1, 255, 255, floor(255 * k))
  if sc == 1 then -- heart rate through the roof, then flat
    local bpm = floor(60 * 2 ^ (sb / 2))
    local flat = sb > 7
    for x = 0, 95 do
      local p, y = ((x - sb * 40) / 96 * bpm / 60) % 1, 0
      if flat or p < .1 then y = 0 elseif p < .13 then y = 3 elseif p < .17 then y = -13
      elseif p < .21 then y = 7 elseif p > .3 and p < .42 then y = -3 end
      fillRect(x, 47 + y, 1, 2, flat and 255 or 0, x * 2 + 60, flat and 0 or x)
    end
    T(flat and "OOPS" or bpm > 200 and bpm .. "!!" or tostring(bpm), 24, 1, 255, flat and 0 or 255, flat and 0 or 255)
  elseif sc == 2 then -- acid house smiley
    local s = floor(14 + 3 * k)
    fillCircle(47, 47, s, 255, 230, 0)
    fillRect(41, 40, 3, 5, 0, 0, 0)
    fillRect(51, 40, 3, 5, 0, 0, 0)
    for a = .5, 2.7, .15 do drawPixel(floor(47 + cos(a) * s * .6), floor(48 + sin(a) * s * .6), 0, 0, 0) end
    T("ACID", 44, 1, r, g, bl, 2)
    T("ACID", 44, 1, r, g, bl, 70)
  else -- the slogan, the side effects: going on where they stopped
    local s = ROLL[sc // 3 + 1]
    T(s, 41, 2, r, g, bl, 96 - floor(floor(b / 32) * 400 + sb * (50 + sc * 15)) % (#s * 12 + 96))
  end
  updateDisplay()
  tn = tn + 30
  local w = tn - millis()
  if w > 0 then delay(w) else tn = millis() end
end
