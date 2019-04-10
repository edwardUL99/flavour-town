local objects = {}

local sheetInfo = require("spritesheet")
local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())

objects.foodsIndices =
{

    ["bacon"] = 1,
    ["broccoli"] = 2,
    ["carrot"] = 3,
    ["cheese"] = 4,
    ["sushi"] = 5,
    ["tomato"] = 6,
}


function objects:createObjects(layer, rightBound, bottomBound, topBound)
    local foodCollisionFilter = {groupIndex = -2}
    local names = {"tomato", "broccoli", "carrot","bacon", "sushi", "cheese"}
    local name = names[math.random(#names)]
    --I added the getWidth and getHeight methods to the spritesheet.lua file. Better to use newImageRect
    local newItem = display.newImageRect(layer, imageSheet, sheetInfo:getFrameIndex(name), sheetInfo:getWidth(name), sheetInfo:getHeight(name))
    newItem.height = 200
    newItem.width = 200
    newItem.myName = name
    physics.addBody(newItem, "dynamic", {filter = foodCollisionFilter}) --(*Static and static cant collide with each other)
    newItem.x = math.random(rightBound + 100, rightBound + 2000)
    newItem.y = math.random(topBound,bottomBound)

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

function objects:foodObject(food)
  if self.foodsIndices[food] then
    return self.foodsIndices[food]
  else
    return nil
  end
end

return objects
