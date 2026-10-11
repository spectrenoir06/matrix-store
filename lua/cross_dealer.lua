-- Dealer, for the cross (96x96): the pharmacy sign selling the fun stuff.
-- A gag every 8 beats (130 BPM). Keep it short: 30 KB to compile and run.
local floor, random = math.floor, math.random
setTextWrap(false)
local function T(s, y, z, r, g, b, x) -- x nil: centered
  setTextSize(z)
  setTextColor(r, g, b)
  setCursor(x or 48 - textWidth(s) // 2, y)
  printText(s)
end
local function cross(g, top, bottom, k)
  fillRect(32, 0, 32, 96, 0, g, g // 4)
  fillRect(0, 32, 96, 32, 0, g, g // 4)
  fillRect(0, 38, 96, 20, 0, g // 3, g // 12)
  T(top, 12, 1, 255, 255, floor(255 * k))
  T(bottom, 72, 1, 0, 255, 70)
end
local MENU = { "LSD  5$", "MDMA 2+1", "KETA-50%", "DMT  ???", "SHROOMS!", "FREE HUG" }
local SMALL = "NO PRESCRIPTION NEEDED * CASH ONLY * 10TH TRIP FREE *"
local PY = {}
for i = 1, 10 do PY[i] = random(-96, 0) end
local GAGS = {
  function(b, sb, k) -- PHARMA -> DEALER
    cross(floor(120 + 135 * k), "", "", k)
    local s = ""
    for i = 1, 6 do
      s = s .. ((sb > 2 + i * .6 or sb > 2 and random() < .25) and "DEALER" or "PHARMA"):sub(i, i)
    end
    if sb > 2 and k > .5 then T(s, 41, 2, 255, 0, 60, 13); T(s, 41, 2, 0, 200, 255, 21) end
    T(s, 41, 2, 255, 255, 255)
  end,
  function(b, sb, k) -- the menu
    cross(110, "TODAY", "24/7", k)
    T(MENU[floor(b / 2) % #MENU + 1], 41, 2, 0, 255, 70)
  end,
  function(b, sb, k) -- clock, temperature
    if sb < 5 then
      cross(110, "TIME", "TO", k)
      T(floor(b * 2) % 2 == 0 and "04:20" or "04 20", 41, 2, 0, 255, 70)
      T("HIGH", 82, 1, 255, 255, 255)
    else
      cross(110, "TEMP", "TOO", k)
      T("+42 C", 41, 2, 255, 80, 0)
      T("HOT", 82, 1, 255, 255, 255)
    end
  end,
  function(b, sb, k) -- small print
    cross(0, "CASH", "ONLY", k)
    local r, g, bl = hsv(floor(b * 20), 255, 255)
    T(SMALL, 41, 2, r, g, bl, 96 - floor(floor(b / 40) * 480 + sb * 60) % (#SMALL * 12 + 96))
  end,
  function(b, sb, k) -- pills
    for i = 1, 10 do
      PY[i] = PY[i] + 2 + i % 3
      if PY[i] > 96 then PY[i] = random(-40, -4) end
      local r, g, bl = hsv(i * 25, 255, 255)
      local x = 33 + i * 37 % 24
      fillRect(x, PY[i], 3, 2, r, g, bl)
      fillRect(x + 3, PY[i], 3, 2, 255, 255, 255)
    end
    fillRect(0, 38, 96, 20, 0, 0, 0)
    T(floor(b) % 2 == 0 and "TAKE 2" or "OR 3", 41, 2, 255, 255, 255)
  end,
}
local t0, tn = millis(), millis()
while true do
  local b = (millis() - t0) / 461.5
  clearDisplay()
  GAGS[floor(b / 8) % #GAGS + 1](b, b % 8, (1 - b % 1) ^ 3)
  updateDisplay()
  tn = tn + 30
  local w = tn - millis()
  if w > 0 then delay(w) else tn = millis() end
end
