local Screen = {
  width = 960,
  height = 540,
  scale = 1,
  offset_x = 0,
  offset_y = 0
}

function Screen.update()
  local width, height = love.graphics.getDimensions()
  Screen.scale = math.min(width / Screen.width, height / Screen.height)
  Screen.offset_x = (width - Screen.width * Screen.scale) / 2
  Screen.offset_y = (height - Screen.height * Screen.scale) / 2
end

function Screen.apply()
  love.graphics.translate(Screen.offset_x, Screen.offset_y)
  love.graphics.scale(Screen.scale, Screen.scale)
end

function Screen.to_virtual(x, y)
  return (x - Screen.offset_x) / Screen.scale, (y - Screen.offset_y) / Screen.scale
end

return Screen
