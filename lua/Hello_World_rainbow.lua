local i = 0
local str = "Hello_World!"
local size = 3
local offset = 64
local floor = math.floor
local sin = math.sin

setTextWrap(false)
while true do
  --fillRect(0, 0, 64, 32, colorWheel(i))
  for x = 0, 63 do
    for y = 0, 31 do
      drawPixel(x, y, colorWheel(x*3+y*3+i*10))
    end
  end
  setTextSize(size)
  for j=1,str:len() do    
    setTextColor(0,0,0)
    setCursor(((j-1)*6*size+floor(offset))+1, floor((32-7*size) / 2) + floor(sin((j*6+i)/10)*4)+1)
    printText(str:sub(j, j))

    setTextColor(colorWheel(i+128+j*20))
    setCursor(((j-1)*6*size+floor(offset)), floor((32-7*size) / 2) + floor(sin((j*6+i)/10)*4))
    printText(str:sub(j, j))
  end
  updateDisplay()
  i = i + 1
  offset = offset - 2
  if offset < -(str:len() * 6 * size) then offset = 65 end
  delay(5)
end
