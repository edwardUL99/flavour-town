
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local json = require("json")

local combinationsTable = {}
local uiLayer

local filePath = system.pathForFile("combo.json", system.DocumentsDirectory)

local function goToMainMenu()
	composer.removeScene("journal")
	composer.gotoScene("menu", "fade", 500)
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

local function displayCombos()
	local x = 100
	local y = 100
	local combo = ''
	local text

	for i = 1, #combinationsTable do
		for j = 1, #combinationsTable[i] do
			for k = 1, #combinationsTable[i][j] do
			combo = combo .. combinationsTable[i][j][k] .. "-"
			end
			text = display.newText(uiLayer, combo, x, y, system.nativeFont, 50)
			combo = ""
			x = x + 100
			y = y + 100
		end
	end
end

local function deleteFile()
	os.remove("combo.json", system.DocumentsDirectory)
	composer.setVariable("skewerArray", {})
	combinationsTable = {}
	saveCombos()
	composer.removeScene("journal")
	composer.gotoScene("journal")
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	uiLayer = display.newGroup()
	sceneGroup:insert(uiLayer)

	composer.removeScene("game")

	loadTables()


	table.insert(combinationsTable, composer.getVariable("skewerArray"))

	local background = display.newImageRect(sceneGroup, "backdrop.png", display.actualContentWidth, display.actualContentHeight + 3000)
	background.x = display.contentCenterX
	background.y = display.ContentCenterY
	background:toBack()

	local menuBtn = display.newText(uiLayer, "Menu", -100, display.contentHeight - 125, native.systemFont, 80)
	local resetBtn = display.newText(uiLayer, "Reset Records", 1000, display.contentHeight - 125, native.systemFont, 80)

	menuBtn:addEventListener("tap", goToMainMenu)
 resetBtn:addEventListener("tap", deleteFile)

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
		-- Code here runs when the scene is entirely on screen

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
