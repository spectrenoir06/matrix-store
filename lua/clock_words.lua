-- Word clock: the time in words, to the nearest five minutes ("TEN PAST
-- SEVEN"). Set lang to "fr" for French ("SEPT HEURES DIX").
local lang = "en"
local mx, my = getMatrix()
local floor = math.floor
local EN = { "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "ELEVEN", "TWELVE" }
local FR = { "UNE", "DEUX", "TROIS", "QUATRE", "CINQ", "SIX", "SEPT", "HUIT", "NEUF", "DIX", "ONZE", "MIDI" }
local function words_en(h, m)
  local five = floor((m + 2.5) / 5) % 12
  if m >= 58 then h = h + 1 end
  local w = { "IT IS" }
  local next_h = five > 6
  local hour = EN[((h + (next_h and 1 or 0)) - 1) % 12 + 1]
  local mins = { "", "FIVE", "TEN", "QUARTER", "TWENTY", "TWENTY FIVE", "HALF" }
  if five == 0 then w[#w + 1] = hour; w[#w + 1] = "O'CLOCK"
  elseif five <= 6 then w[#w + 1] = mins[five + 1]; w[#w + 1] = "PAST"; w[#w + 1] = hour
  else w[#w + 1] = mins[12 - five + 1]; w[#w + 1] = "TO"; w[#w + 1] = hour end
  return w
end
local function words_fr(h, m)
  local five = floor((m + 2.5) / 5) % 12
  if m >= 58 then h = h + 1 end
  local hh = (h + (five > 6 and 1 or 0)) % 24
  local hour
  if hh == 0 then hour = "MINUIT" elseif hh == 12 then hour = "MIDI"
  else hour = FR[(hh - 1) % 12 + 1] .. (hh % 12 == 1 and " HEURE" or " HEURES") end
  local w = { "IL EST", hour }
  local after = { "", "CINQ", "DIX", "ET QUART", "VINGT", "VINGT-CINQ", "ET DEMIE" }
  local before = { "", "MOINS CINQ", "MOINS DIX", "MOINS LE QUART", "MOINS VINGT", "MOINS VINGT-CINQ" }
  if five >= 1 and five <= 6 then w[#w + 1] = after[five + 1]
  elseif five > 6 then w[#w + 1] = before[12 - five + 1] end
  return w
end
-- greedy wrap into lines that fit the width (6 px per letter)
local function wrap(words, cols)
  local text = table.concat(words, " ")
  local lines, line = {}, ""
  for word in text:gmatch("%S+") do
    if #line == 0 then line = word
    elseif #line + 1 + #word <= cols then line = line .. " " .. word
    else lines[#lines + 1] = line; line = word end
  end
  if #line > 0 then lines[#lines + 1] = line end
  return lines
end
local shown, fade = "", 0
while true do
  local h, m = getTime()
  clearDisplay()
  setTextSize(1)
  setTextWrap(false)
  if not h then
    setTextColor(255, 120, 0)
    setCursor(1, my // 2 - 4)
    printText(lang == "fr" and "PAS D'HEURE" or "NO TIME")
  else
    local words = lang == "fr" and words_fr(h, m) or words_en(h, m)
    local cols = mx // 6
    local lines = wrap(words, cols)
    if #lines * 8 > my then table.remove(words, 1); lines = wrap(words, cols) end -- without "IT IS"
    local key = table.concat(lines, "/")
    if key ~= shown then shown, fade = key, 0 end -- a new time: fade in
    fade = math.min(1, fade + 0.05)
    local y0 = (my - #lines * 8) // 2 + 1
    for i, l in ipairs(lines) do
      local r, g, b = colorWheel(floor((h * 60 + m) / 1440 * 256 + i * 30) % 256)
      setTextColor(floor(r * fade), floor(g * fade), floor(b * fade))
      setCursor((mx - #l * 6) // 2 + 1, y0 + (i - 1) * 8)
      printText(l)
    end
  end
  updateDisplay()
  delay(50)
end
