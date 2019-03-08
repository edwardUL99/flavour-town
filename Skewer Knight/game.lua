----------------------------------------------------------------------------
--	NOTES
----------------------------------------------------------------------------
--I've renamed most of the variables to be more readable, and moved them about
--	slightly. Check to see their new names before using them.
-- (I haven't touched the functions except move them.
--   Haven't touched the Scene Functions yet)
--
--If you want someone to check something out, mark it with an " * ".
--
--NOTES ON SYNTAX:
--[1] Name Variables so you tell exactly what it is just by looking.
--[2] Same with Functions, make their names a VERB that says what it does.
--[3] Don't leave empty lines inside functions, it makes it harder to read. Corona tutorials says don't clump code together because it makes it harder to read
--[4] All comments related to it should be inside the function itself,
--	  NOT above/below it etc, It's convention for function comments to go above just like in Java no?
----------------------------------------------------------------------------
--STARTUP / IMPORTS ETC
----------------------------------------------------------------------------
local composer = require( "composer" ) --This is very IMPORTANT
local scene = composer.newScene()
local sheetInfo = require("spritesheet") --Introduces the functions required to grab sprites from sheet
local physics = require( "physics" )
physics.start()
physics.setGravity(0,0)
local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())
----------------------------------------------------------------------------
--VARIABLES BELOW
----------------------------------------------------------------------------
---UI related variables--
local health = 3
local score = 0
local healthText
local scoreText
--------------------
--Basic Game Variables--
local paused = false
local died = false
local gameLoopTimer
local runtime = 0
--------------------
--Arrays & tables--
local looseFoodsTable = {}
local maxLooseFoods = 10
local onSkewerArray = {}
local maxOnSkewer = 4
local foodCombinations = {}
local amountOfCombos = 5 --Decide later
--------------------
--Graphics variables--
local player
local bg1
local bg2 --two SCROLLING backgrounds, to make it look like player is moving)
local foodScrollSpeed = 2--(Add multiple backgrounds of different speeds,
local bg2ScrollSpeed = 3 --Food moves at the same speed as the first)
--------------------
--Boundaries variables--
local leftBound = -(display.viewableContentWidth)
local rightBound = display.actualContentWidth - display.contentWidth
local topBound = 0
local bottomBound = display.actualContentHeight
--------------------
--Providing variables for displayGroups to be used later--
local backLayer
local mainLayer
local uiLayer
--------------------
----------------------------------------------------------------------------
--WORKING FUNCTIONS
----------------------------------------------------------------------------
local function goToMainMenu()
	composer.removeScene("game")
	composer.gotoScene("menu","fade",500)
end

local function checkBounds()
	if (player.x > rightBound) then
		player.x = rightBound - 20
	elseif (player.x < leftBound) then
		player.x = leftBound + 20
	end

	if (player.y < topBound) then
		player.y = topBound + 20
	elseif (player.y > bottomBound) then
		player.y = bottomBound - 20
	end
end

local function createObjects()
	local names = {"bread", "broccoli", "burger", "lettuce", "tomato"} --Will be randomly accessed
	local name = names[math.random(#names)]
	local newItem = display.newImage(mainLayer, imageSheet, sheetInfo:getFrameIndex(name))
	newItem.height = 200
	newItem.width = 200
	newItem.myName = name
	table.insert(looseFoodsTable, newItem)
	physics.addBody(newItem, "dynamic", {radius=40, bounce=0.0})
  --
	newItem.x = rightBound + 100
	newItem.y = math.random(bottomBound)
	newItem:toBack()
end

local function dragplayer(event)
	local player = event.target
	local phase = event.phase
	if (paused ~= true) then
		if ("began" == phase) then
			display.currentStage:setFocus(player)
			player.touchOffsetX = event.x - player.x
			player.touchOffsetY = event.y - player.y
		elseif ("moved" == phase) then
			player.x = event.x - player.touchOffsetX
			player.y = event.y - player.touchOffsetY
		elseif ("ended" == phase or "cancelled" == phase) then
			display.currentStage:setFocus(nil)
		end
	end

	return true
end

local function getDeltaTime() --Delta time ensures we have smooth scrolling accross different devices
	local temp = system.getTimer()
	local dt = (temp-runtime) / (1000/60)
	runtime = temp
	return dt
end

local function moveObject(event)
	local dt = getDeltaTime();
	if (paused ~= true) then
		for i = #looseFoodsTable, 1, -1 do
			looseFoodsTable[i].x = looseFoodsTable[i].x - foodScrollSpeed * dt
			if (looseFoodsTable[i].x < -(display.actualContentWidth)) then
				display.remove(looseFoodsTable[i])
				table.remove(looseFoodsTable, i)
			end
		end
	end
end

local function moveBg(dt) --May not be needed?
	--Code to move background if necessary.
	--Google how to do scrolling background
	--http://lomza.totem-soft.com/tutorial-scrollable-background-in-corona-sdk/
end

local function enterFrame(event) --( * It will be for the moving background. http://lomza.totem-soft.com/tutorial-scrollable-background-in-corona-sdk/)
	local dt = getDeltaTime()
	moveBg(dt)
end

local function isEqualArray(table1, table2)
	--Since the score value is only stored at end of each combination table, we can ignore it and check the names only
	if ((#table1-1) == #table2) then
		for i = 1, (#table1 - 1) do
			if (table1[i] ~= table2[i]) then
				return false
			end
		end
		return true
	end
	return false
end

local function updateSkewer()
 --Will provide code to update the food contents on the skewer
end

local function createCombinationsTable()
	for i = 1, amountOfCombos do --Creating 2D array
		foodCombinations[i] = {}
	end
	--The score values for each combination is in the last position i.e #foodCombinations[i] where i is some number 1-5
	foodCombinations[1] = {"bread", "bread", "bread", "bread", 500}
	foodCombinations[2] = {"broccoli", "broccoli", "broccoli", "broccoli", 50}
	foodCombinations[3] = {"burger", "burger", "burger", "burger", 1000}
	foodCombinations[4] = {"lettuce", "lettuce", "lettuce", "lettuce", 100}
	foodCombinations[5] = {"tomato", "tomato", "tomato", "tomato", 200}
end

--debug to test output on console
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
---Will remove later--

local function checkCombination(namesTable)
	for i = 1, #foodCombinations do
		if (isEqualArray(foodCombinations[i], namesTable)) then
			return foodCombinations[i][#foodCombinations[i]]
		end
	end
	return 500
end

local function keyPressed(event)
	if (event.phase == "down") then
		if (event.keyName == "back") then
			goToMainMenu()
		end
	end

	if (event.phase == "up") then
		return true
	end
end

--The return value is the score to be given to the player
local function store(objectsTable)
 local namesTable = {}
 for i = 1, #objectsTable, 1 do
   namesTable[i] = objectsTable[i].myName
 end
 return checkCombination(namesTable)
end

local function updateText()
 scoreText = "Score: " .. score
 healthText = "Health: " .. health
end

local function gameLoop()
	createObjects()
	updateText()
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--INCOMPLETE/BROKEN/UNKNOWN FUNCTIONS BELOW
----------------------------------------------------------------------------

local function addScrollableBg()
	local bgImage = {type="image",filename="background.png"}
	--Code to add first background image
	--Code to add second background image
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
--EMPTY/UNUSED FUNCTIONS BELOW
----------------------------------------------------------------------------


--local function moveSprite(event)
----Will be used when joystick is added
	--player.x = player.x + motionx
	--player.y = player.y + motiony
--end

local function pause()
 --Will provide pause function
end

local function resume()
	--Will provide resume function
end

local function onCollision(event)
	--Will provide code for collision events
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Scene event functions
----------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	backLayer = display.newGroup()
	sceneGroup:insert(backLayer)

	mainLayer = display.newGroup()
	sceneGroup:insert(mainLayer)

	uiLayer = display.newGroup()
	sceneGroup:insert(uiLayer)

	local background = display.newImageRect(backLayer, "background.jpg", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	player = display.newImageRect(mainLayer, "player.png", 400, 300)
	player.x = display.contentCenterX - 1000
	player.y = display.contentCenterY
	physics.addBody(player, "static", {radius = 30, isSensor=true})
	player.myName = "player"

	--Health is just text for prototype
	healthText = display.newText(uiLayer, "Health: " .. health, display.contentCenterX - 1000, display.contentCenterY - 500, native.systemFont, 80)

	--Score is text for prototype
	scoreText = display.newText(uiLayer, "Score: " .. score, display.contentCenterX + 1000, display.contentCenterY - 500, native.systemFont, 80)

	createCombinationsTable()

	--Debug to print test output to console, will remove later
	print2D(foodCombinations)

	local good = {"lettuce", "lettuce", "lettuce", "lettuce"}
	print(checkCombination(good))
	--------------------------------------------------------------

	player:addEventListener("touch", dragplayer)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener("collision", onCollision)
		Runtime:addEventListener("enterFrame", checkBounds)
		Runtime:addEventListener("enterFrame", moveObject)
		--Runtime:addEventListener("enterFrame", moveSprite)
		Runtime:addEventListener("key", keyPressed)
		gameLoopTimer = timer.performWithDelay(2000, gameLoop, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel(gameLoopTimer)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		physics.pause()
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-------------------------------------------------------------------------------------
-- Scene event function listeners
-------------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-------------------------------------------------------------------------------------

return scene
