
local composer = require( "composer" )

local scene = composer.newScene()

local objects = require("objects")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require("json")

local combinationsTable = {}
local displayObjects = {}
local highScore = {}
local lastScore = 0
local backLayer
local uiLayer

local filePath = system.pathForFile("combo.json", system.DocumentsDirectory)
local scoresPath = system.pathForFile("score.json", system.DocumentsDirectory)

local function goToMainMenu()
  composer.setVariable("scene", "menu")
  composer.setVariable("fromScene", "journal")
	composer.gotoScene("loading", {time=800, effect="crossFade"})
end

local function goBackToGame()
  composer.setVariable("scene", "game")
  composer.setVariable("fromScene", "journal")
  composer.removeScene("game")
  composer.gotoScene("loading", {time=800, effect="crossFade"})
end

local function printTable(table)
	for i = 1, #table do
		print(table[i])
	end
	print("------------")
end

local function print2D(twoD)
	for i = 1, #twoD do
		printTable(twoD[i])
	end
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

local function displayArray(array)
	for i = 1, #array do
		for j = 1, #array[i] do
			print(array[i][j])
		end
		print("----------------------")
	end
end

local function isEqualArray(table1, table2)
	--Since the score value is only stored at end of each combination table, we can ignore it and check the names only
	if (#table1 - 1 == #table2) then
		for i = 1, #table2 do
			if (table1[i] ~= table2[i]) then
				return false
			end
		end
		return true
	end
	return false
end

local function createDisplayObject(x, y, object)
  local newDisplay = display.newImageRect(uiLayer, "Images/comboBack.png", 500, 300)
  newDisplay.x = x
  newDisplay.y = y
  table.insert(displayObjects, newDisplay)

  x = x - 100
  for i = 1, #object do
    objects:spawnObject(uiLayer, x, y, 100, 100, object[i])
    x = x + 100
  end
end

local function displayCombos()
	local x = -600
	local y = 250
  local maxPerRow = 5
  local displayed = 0
	local combo = ""
	local text

  if (combinationsTable[1] ~= nil) then
    for i = 1, #combinationsTable do
      for j = 1, #combinationsTable[i] do
        --for k = 1, #combinationsTable[i][j] do
          --combo = combo .. combinationsTable[i][j].. "-"
          --objects:spawnObject(uiLayer, x, y, 100, 100, combinationsTable[i][j][k])
          createDisplayObject(x, y, combinationsTable[i][j])
          displayed = displayed + 1
          print(displayed)
          if (displayed == maxPerRow) then
            x = -600
            y = y + 350
            displayed = 0
          else
        --end
          x = x + 500
        end
      end
      --combo = combo .. combinationsTable[i][#combinationsTable[i]]
      --text = display.newText(uiLayer, combo, x, y, system.nativeFont, 50)
      --combo = ""
		end
	end
end

local function deleteFile()
	combinationsTable = {}
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
  combinationsTable = {}

  loadCombos()
  loadScore()

	local background = display.newImageRect(backLayer, "Images/backdrop.png", display.actualContentWidth, display.actualContentHeight + 3000)
	background.x = display.contentCenterX
	background.y = display.ContentCenterY

	local menuBtn = display.newText(uiLayer, "Menu", -250, display.contentHeight - 125, native.systemFont, 80)
	local resetBtn = display.newText(uiLayer, "Reset Records", 1000, display.contentHeight - 125, native.systemFont, 80)
  local gameBtn = display.newText(uiLayer, "Back to Game", 300, display.contentHeight - 125, native.systemFont, 80)

	menuBtn:addEventListener("tap", goToMainMenu)
 	resetBtn:addEventListener("tap", deleteFile)
  gameBtn:addEventListener("tap", goBackToGame)

  if (composer.getVariable("skewerArray") ~= nil) then
    table.insert(combinationsTable, composer.getVariable("skewerArray"))
    composer.variables["skewerArray"] = nil
  end
  
  if (composer.getVariable("score") ~= nil) then
    local score = composer.getVariable("score")
    if (score > highScore[1]) then
      local newHighScore = display.newText(uiLayer, "New High Score: " .. " " .. score .. "!", 500, display.contentCenterY, native.systemFont, 80)
      newHighScore:setFillColor(0.75, 1, 0.5)
			timer.performWithDelay(2000, function() transition.fadeOut(newHighScore, {time = 500}) end, 1)
      highScore[1] = score
    end
    composer.variables["score"] = nil
  end
  
  local highScoreText = display.newText(uiLayer, "High Score: " .. highScore[1], 1250, 90, native.systemFont, 80)

 	displayCombos()
  saveScore()
 	saveCombos()

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
