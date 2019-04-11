
local composer = require( "composer" )

local scene = composer.newScene()

local objects = require("objects")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require("json")

local combinationsTable
local displayObjects = {}
local highScore = {}
local lastScore = 0
local backLayer
local uiLayer

local filePath = system.pathForFile("combo.json", system.DocumentsDirectory)
local scoresPath = system.pathForFile("score.json", system.DocumentsDirectory)

local function goToMainMenu()
  composer.setVariable("scene", "menu")
	timer.performWithDelay(500, function() composer.gotoScene( "loading", "fade", 500 ) end)
end

local function goBackToGame()
  composer.setVariable("scene", "game")
  timer.performWithDelay(500, function() composer.gotoScene( "loading", "fade", 500 ) end)
end

local function loadScore()
  local file = io.open(scoresPath, "r")

  if file then
    local contents = file:read("*a")
    io.close(file)
    highScore = json.decode(contents)
  end

  if (highScore == nil or #highScore == 0 ) then
    highScore = {0}
  end
end

local function saveScore()
  local file = io.open(scoresPath, "w")

	if file then
		file:write(json.encode(highScore))
		io.close(file)
	end
end


local function loadCombos()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		combinationsTable = json.decode(contents)
	end

  if (combinationsTable == nil or #combinationsTable == 0) then
    combinationsTable = {}
  end
end

local function saveCombos()
	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(combinationsTable))
		io.close(file)
	end
end

local function isEqualArray(table1, table2)
	--Since the score value is only stored at end of each combination table, we can ignore it and check the names only
	if (#table1 == #table2) then
		for i = 1, #table2 do
			if (table1[i] ~= table2[i]) then
				return false
			end
		end
		return true
	end
	return false
end

local function countSameCombos(combo)
  local count = 0
  for i = 1, #combinationsTable do
    if (isEqualArray(combinationsTable[i], combo)) then
      count = count + 1
    end
  end
  return count
end

local function comboIndex(combo)
  for i = #combinationsTable, 1, -1 do
    if (isEqualArray(combinationsTable[i], combo)) then
      return i
    end
  end
  return nil
end


local function createDisplayObject(x, y, object)
  local newDisplay = display.newImageRect(uiLayer, "Images/comboBack.png", 550, 300)
  local savedX = x
  newDisplay.x = x
  newDisplay.y = y
  table.insert(displayObjects, newDisplay)

  x = x - 130
  for i = 1, #object-1 do
    objects:spawnObject(uiLayer, x, y, 150, 150, object[i])
    x = x + 130
  end

  local pointsText = display.newText(uiLayer, object[#object], savedX, y + 70, native.systemFont, 50)
end

local function removeDuplicates(object)
  if (object ~= nil) then
  	local objectCount = countSameCombos(object)
  	while(objectCount > 1) do
  		table.remove(combinationsTable, comboIndex(object))
  		objectCount = objectCount - 1
  	end
  end
end

local function displayCombos()
	local x = -500
	local y = 300
  local maxPerRow = 4
  local displayed = 0
  local alreadyDisplayed = false
	local combo = ""

  for i = 1, #combinationsTable do
      --for k = 1, #combinationsTable[i][j] do
        --combo = combo .. combinationsTable[i][j].. "-"
        --objects:spawnObject(uiLayer, x, y, 100, 100, combinationsTable[i][j][k])
          local object = combinationsTable[i]
          if object then
          	createDisplayObject(x, y, object)
          	displayed = displayed + 1
          	if (displayed == maxPerRow) then
          	  x = -500
           	  y = y + 300
              displayed = 0
            else
              --end
              x = x + 600
            end
        end
      --combo = combo .. combinationsTable[i][#combinationsTable[i]]
    --text = display.newText(uiLayer, combo, x, y, system.nativeFont, 50)
      --combo = ""
	end
end

local function deleteFile()
	combinationsTable = nil
  	highScore = {}
  	saveCombos()
  	saveScore()
	composer.setVariable("fromScene", "journal")
	composer.setVariable("scene", "journal")
	composer.gotoScene("loading")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	backLayer = display.newGroup()
	sceneGroup:insert(backLayer)
	uiLayer = display.newGroup()
	sceneGroup:insert(uiLayer)

  loadCombos()
  loadScore()


	local background = display.newImageRect(backLayer, "Images/background.jpg", display.actualContentWidth, display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local menuBtn = display.newText(uiLayer, "Menu", -250, display.contentHeight - 125, native.systemFont, 80)
	local resetBtn = display.newText(uiLayer, "Reset Records", 1000, display.contentHeight - 125, native.systemFont, 80)
  local gameBtn = display.newText(uiLayer, "Back to Game", 300, display.contentHeight - 125, native.systemFont, 80)
  local information = display.newText(uiLayer, "These are the discovered combinations that have special effects/Extra points", 400, display.contentHeight- 270, native.systemFont, 50)


  if (composer.getVariable("skewerArray") ~= nil) then
    local skewer = composer.getVariable("skewerArray")
    for i = 1, #skewer do
    	table.insert(combinationsTable, skewer[i])
    end

    for j = 1, #combinationsTable do
    	removeDuplicates(combinationsTable[j])
    end
  end

  if (composer.getVariable("score") ~= nil) then
    local score = composer.getVariable("score")
    if (score > highScore[1]) then
      local newHighScore = display.newText(uiLayer, "New High Score: " .. " " .. score .. "!", 500, display.contentCenterY, native.systemFont, 80)
      newHighScore:setFillColor(0.75, 1, 0.5)
      timer.performWithDelay(2000, function() transition.fadeOut(newHighScore, {time = 500}) end, 1)
      highScore[1] = score
    end
  end

  local highScoreText = display.newText(uiLayer, "High Score: " .. highScore[1], 1250, 90, native.systemFont, 80)

  displayCombos()
  saveScore()
  saveCombos()

  composer.variables["skewerArray"] = nil
  composer.variables["score"] = nil

	menuBtn:addEventListener("tap", goToMainMenu)
 	resetBtn:addEventListener("tap", deleteFile)
  gameBtn:addEventListener("tap", goBackToGame)

	--deleteFile()

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	elseif ( phase == "did" ) then
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    composer.removeScene("journal")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
