local objects = {}

local sheetInfo = require("spritesheet")
local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())


function objects:createObjects(layer, rightBound, bottomBound)
	--local names = {"bread", "broccoli", "burger", "lettuce", "tomato"} --Will be randomly accessed
    local names = {"bacon", "broccoli", "tomato", "sushi", "cheese", "carrot"}
    local name = "sushi"--names[math.random(#names)]
    --I added the getWidth and getHeight methods to the spritesheet.lua file. Better to use newImageRect
    local newItem = display.newImageRect(layer, imageSheet, sheetInfo:getFrameIndex(name), sheetInfo:getWidth(name), sheetInfo:getHeight(name))
    newItem.height = 200
    newItem.width = 200
    newItem.myName = name
    physics.addBody(newItem, "dynamic") --(*Static and static cant collide with each other)
    newItem.x = rightBound + 100
    newItem.y = math.random(bottomBound)

    return newItem
end

function objects:spawnObject(layer, x, y, height, width, objectName)
  local object = display.newImageRect(layer, imageSheet, sheetInfo:getFrameIndex(objectName), sheetInfo:getWidth(objectName), sheetInfo:getHeight(objectName))
  object.height = height
  object.width = width
  object.myName = objectName
  object.x = x
  object.y = y
  return object
end

return objects
