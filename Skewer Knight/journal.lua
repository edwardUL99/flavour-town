
local composer = require( "composer" )

local scene = composer.newScene()

local objects = require("objects")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require("json")

local combinationsTable = {}
local backLayer
local uiLayer
local alreadyLoaded = false

local filePath = system.pathForFile("combo.json", system.DocumentsDirectory)

local function goToMainMenu()
  composer.setVariable("scene", "menu")
  composer.setVariable("fromScene", "journal")
	composer.gotoScene("loading", "fade", 500)
end

local function goBackToGame()
  composer.setVariable("scene", "game")
  composer.setVariable("fromScene", "journal")
  composer.gotoScene("loading", "fade", 500)
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

local function loadTables()
	local file = io.open(filePath, "r")

	if file then
		print("File Read")
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
	if (#table1 == #table2) then
		for i = 1, #table1 do
			if (table1[i] ~= table2[i]) then
				return false
			end
		end
		return true
	end
	return false
end

local function containsCombo(combo)
	for i = 1, #combinationsTable do
    if (isEqualArray(combinationsTable[i], combo)) then
      return true
    end
	end
	return false
end


local function displayCombos()
	local x = 100
	local y = 100
	local combo = ""
	local text
  
  if (combinationsTable[1] ~= nil) then 
    for i = 1, #combinationsTable do
      for j = 1, #combinationsTable[i] do
        --combo = combo .. combinationsTable[i][j].. "-"
        objects:spawnObject(uiLayer, x, y, 100, 100, combinationsTable[i][j])
        x = x + 100
      end
      --combo = combo .. combinationsTable[i][#combinationsTable[i]]
      --text = display.newText(uiLayer, combo, x, y, system.nativeFont, 50)
      --combo = ""
      x = 100
      y = y + 100
		end
	end
end

local function deleteFile()
	combinationsTable = {}
  saveCombos()
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

  loadTables()

	local background = display.newImageRect(backLayer, "backdrop.png", display.actualContentWidth, display.actualContentHeight + 3000)
	background.x = display.contentCenterX
	background.y = display.ContentCenterY

	local menuBtn = display.newText(uiLayer, "Menu", -250, display.contentHeight - 125, native.systemFont, 80)
	local resetBtn = display.newText(uiLayer, "Reset Records", 1000, display.contentHeight - 125, native.systemFont, 80)
  local gameBtn = display.newText(uiLayer, "Back to Game", 300, display.contentHeight - 125, native.systemFont, 80)

	menuBtn:addEventListener("tap", goToMainMenu)
 	resetBtn:addEventListener("tap", deleteFile)
  gameBtn:addEventListener("tap", goBackToGame)
  
  if (composer.getVariable("skewerArray") ~= nil) then
    print("Not equal to nil")
    table.insert(combinationsTable, composer.getVariable("skewerArray"))
    composer.variables["skewerArray"] = nil
  end

 	displayCombos()
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
