local powerUps = {}

local function baconSizeIncrease(object, skewerOffset, scale)
  transition.scaleBy(object, {xScale = 1, yScale = 1})
  skewerOffset = skewerOffset + 50
  local playerShapeXL = {2*-200,2*111,  2*-41,2*111,   2*-41,2*-89,   2*-200,2*-89}
  local skewerShapeXL = {2*-40,2*50,  2*240,2*50,  2*240,2*31,  2*-40,2*31}
  physics.removeBody(object)
  physics.addBody(object,"static", {shape = skewerShapeXL, isSensor = true},{shape = playerShapeXL,isSensor = true})
  return skewerOffset
end

local function baconSizeShrink(object, skewerOffset, scale, defaultSkewerShape, defaultPlayerShape)
  if(object ~= nil) then
    physics.removeBody(object)
    physics.addBody(object,"static", {shape = defaultSkewerShape, isSensor = true}, {shape = defaultPlayerShape,isSensor = true})
    transition.scaleBy(object, {xScale = -1, yScale = -1})
    skewerOffset = skewerOffset - 50
  end
    return skewerOffset
end

local function evasivenessShrink(object)
  transition.scaleBy(object, {xScale = -0.5, yScale = -0.5})
  local playerShapeXS = {0.5*-200,0.5*111,  0.5*-41,0.5*111,   0.5*-41,0.5*-89,   0.5*-200,0.5*-89}
  local skewerShapeXS = {0.5*-40,0.5*50,  0.5*240,0.5*50,  0.5*240,0.5*31,  0.5*-40,0.5*31}
  physics.removeBody(object)
  physics.addBody(object,"static", {shape = skewerShapeXS, isSensor = true},
                          {shape = playerShapeXS,isSensor = true})
end

local function evasivenessRevert(object, defaultSkewerShape, defaultPlayerShape)
  if(object ~= nil) then
    transition.scaleBy(object, {xScale = 0.5, yScale = 0.5})
    physics.removeBody(object)
    physics.addBody(object,"static", {shape = defaultSkewerShape, isSensor = true},
                            {shape = defaultPlayerShape,isSensor = true})
  end
end

powerUps.baconSizeIncrease = baconSizeIncrease
powerUps.baconSizeShrink = baconSizeShrink
powerUps.evasivenessShrink = evasivenessShrink
powerUps.evasivenessRevert = evasivenessRevert

return powerUps
