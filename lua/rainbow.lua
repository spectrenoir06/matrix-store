local x = 0
local mx, my = getMatrix()
while true do
  for i = 0, mx-1 do
    for j = 0, my-1 do
      r, g, b = colorWheel(i*3+j*3+x*10)
      drawPixel(i, j, r, g, b)
    end
  end
  updateDisplay()
  x = x + 1
end
