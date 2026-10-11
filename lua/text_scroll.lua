local str = "Hello_World!"
local size = 2
local background = false
local shadow = false
local wait = 1

local floor = math.floor
local sin = math.sin
local mx, my = getMatrix()
local offset = mx
local i = 0

setTextWrap(false)
while true do
  if not background then
    clearDisplay()
  else
    local r,g,b = colorWheel(floor(i/5))
    fillDisplay(floor(r*0.8), floor(g*0.8), floor(b*0.8))
  end
  setTextSize(size)
  for j=1,str:len() do
    if shadow then
      setTextColor(0,0,0)
      setCursor(((j-1)*6*size+floor(offset))+1, floor((my-7*size) / 2) + floor(sin((j*6+i)/10)*4)+1)
      printText(str:sub(j, j))
    end

    setTextColor(colorWheel(i+128+j*20))
    setCursor(((j-1)*6*size+floor(offset)), floor((my-7*size) / 2) + floor(sin((j*6+i)/10)*4))
    printText(str:sub(j, j))
  end
  updateDisplay()
  i = i + 1
  offset = offset - 0.4
  if offset < -(str:len() * 6 * size) then offset = mx+1 end
  delay(wait)
end

