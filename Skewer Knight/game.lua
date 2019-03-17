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
local life=display.newImageRect("heart.png",200,200)
  life.x=-700
  life.y=150
local life1=display.newImageRect("heart.png",200,200)
  life1.x=-600
  life1.y=150
local life2=display.newImageRect("heart.png",200,200)
  life2.x=-500
  life2.y=150
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
local pauseButton
local playButton
local pauseText
local bg1
local bg2 --two SCROLLING backgrounds, to make it look like player is moving)
local bgImage2 = {type = "image", filename ="background.jpg"}
local foodScrollSpeed = 10
local bgScrollSpeed = 5
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
------------------- (I don't know if we're still using these, but I saw they were deleted.
--local motionx = 0     Keeping them here just in case that was by accident) (Aidan)
--local motiony = 0	--Character movement variables
--local speed = 2
-------------------

---------------------
--BACKGROUND CRAP
-------------------
local function moveBg(dt)
	bg1.x = bg1.x - bgScrollSpeed * dt
	bg2.x = bg2.x - bgScrollSpeed * dt

	if(bg1.x + display.actualContentWidth - 400) < 0 then
		bg1:translate( -bg1.contentWidth * -2, 0)
	end
	if (bg2.x + display.actualContentWidth - 400) < 0 then
		bg2:translate( -bg2.contentWidth * -2, 0)
	end
end

local function getDeltaTime() --Delta time ensures we have smooth scrolling accross different devices
	local temp = system.getTimer()
	local dt = (temp-runtime) / (1000/60)
	runtime = temp
	return dt
end

local function enterFrame(event) --( * It will be for the moving background. http://lomza.totem-soft.com/tutorial-scrollable-background-in-corona-sdk/)
	local dt = getDeltaTime()
	moveBg(dt)
end

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
	--I added the getWidth and getHeight methods to the spritesheet.lua file. Better to use newImageRect
	local newItem = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(name), sheetInfo:getWidth(name), sheetInfo:getHeight(name))
	newItem.height = 200
	newItem.width = 200
	newItem.myName = name
	table.insert(looseFoodsTable, newItem)
	physics.addBody(newItem, "dynamic", {radius=40, bounce=0.0}) --(*Static and static cant collide with each other)
	newItem.x = rightBound + 100
	newItem.y = math.random(bottomBound)
end

local function dragPlayer(event)
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
	--
	return true
end

local function moveObject(event)
	local dt = getDeltaTime();
	if (paused ~= true) then
		moveBg(dt)
		for i = #looseFoodsTable, 1, -1 do
			looseFoodsTable[i].x = looseFoodsTable[i].x - foodScrollSpeed * dt
			if (looseFoodsTable[i].x < -(display.actualContentWidth)) then
				display.remove(looseFoodsTable[i])
				table.remove(looseFoodsTable, i)
			end
		end
	end
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
 local i = #onSkewerArray
 if (i==nil) then i=0 end
 print("There are " .. #onSkewerArray .. " foods on the skewer.")
if(#onSkewerArray == 1) then
	foodPos1 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos1.x = display.contentCenterX - (1200 - 55*1)
	foodPos1.y = display.contentCenterY + 600
	foodPos1.height = 50
	foodPos1.width = 50
elseif (#onSkewerArray == 2) then
	foodPos2 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos2.x = display.contentCenterX - (1200 - 55*2)
	foodPos2.y = display.contentCenterY + 600
	foodPos2.height = 50
	foodPos2.width = 50
elseif (#onSkewerArray == 3) then
	foodPos3 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos3.x = display.contentCenterX - (1200 - 55*3)
	foodPos3.y = display.contentCenterY + 600
	foodPos3.height = 50
	foodPos3.width = 50
elseif (#onSkewerArray == 4) then
	foodPos4 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos4.x = display.contentCenterX - (1200 - 55*4)
	foodPos4.y = display.contentCenterY + 600
	foodPos4.height = 50
	foodPos4.width = 50
end
end

local function clearSkewer()
	display.remove(foodPos1)
	display.remove(foodPos2)
	display.remove(foodPos3)
	display.remove(foodPos4)
end

local function createCombinationsTable()
	for i = 1, amountOfCombos do --Creating 2D array
		foodCombinations[i] = {}
	end
	--The score values for each combination is in the last position i.e #foodCombinations[i] where i is some number 1-5
	foodCombinations[1] = {"bread", "bread", "bread", "bread", 500}
	foodCombinations[2] = {"broccoli", "broccoli", "broccoli", "broccoli", 50}
	foodCombinations[3] = {"burger", "burger", "burger", "burger", 1000}
	foodCombinations[4] = {"lettuce", "lettuce", "lettuce", "lettuce", -100}
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

local function pause()
 timer.pause(gameLoopTimer)
 paused = true
 pauseText.isVisible = true
 pauseButton.isVisible = false
 playButton.isVisible = true
  bgScrollSpeed = 0
end

local function resume()
	timer.resume(gameLoopTimer)
	paused = false
	pauseText.isVisible = false
	playButton.isVisible = false
	pauseButton.isVisible = true
	bgScrollSpeed = 5
end

local function updateText()
 scoreText.text = "Score: " .. score
 if(health==2) then
 display.remove(life2)
 elseif(health==1) then
 display.remove(life1)
 end	
end

local function gameLoop()
	createObjects()
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--INCOMPLETE/BROKEN FUNCTIONS BELOW
----------------------------------------------------------------------------

---------------------------------------------------------------------------
----------------------------------------------------------------------------
--EMPTY/UNUSED FUNCTIONS BELOW
----------------------------------------------------------------------------


--local function moveSprite(event)
----Will be used when joystick is added
	--player.x = player.x + motionx
	--player.y = player.y + motiony
--end

--[[ Will be used if we switch to Windows and use arrow keys
local fuction arrowsPressed(event)
	if (event.phase == "down") then
		if (event.keyName == "left") then
			motionx = -speed
		elseif (event.keyName == "right") then
			motionx = speed
		elseif (event.keyName == "down") then
			motiony = speed
		elseif (event.keyName == "up") then
			motiony = -speed
		end
	end
	if (event.phase == "up) then
		motionx = 0
		motiony = 0
	end
	return false
end
--]]

local function restorePlayer()
	player.isBodyActive = false

	transition.to(player, {alpha=1, time=4000,
		onComplete = function()
			player.isBodyActive = true
		end
	})
	Runtime:addEventListener("enterFrame", checkBounds)
end

local function onCollision(event) --(*Is lettuce considered an enemy food? I'll assume it is for now)
	if (event.phase == "began") then
		local collidedObject = event.object2
		if (collidedObject.myName == "player") then
			collidedObject = event.object1
		end

		print(collidedObject.myName)
		display.remove(collidedObject)

		for i = #looseFoodsTable, 1, -1 do
			if (looseFoodsTable[i] == collidedObject) then
				table.remove(looseFoodsTable, i)
			end
		end

		table.insert(onSkewerArray, collidedObject.myName)
		updateSkewer()

		if (#onSkewerArray == maxOnSkewer) then
			local points = checkCombination(onSkewerArray)
			local plusOrMinus = "+"
			if (points < 0) then
				plusOrMinus = ""
			end
			onSkewerArray = {}
			clearSkewer()
			local pointsText = display.newText(uiLayer, plusOrMinus .. points, 100, 100, display.systemFont, 60)
			local hideTimer = timer.performWithDelay(3000, function()
																										 	pointsText.isVisible = false end, 1)
			score = score + points

			if (points < 0 and health > 0) then
				health = health - 1
			end
			updateText()

			if (health == 0) then
				player.alpha = 0
				timer.performWithDelay(2000, goToMainMenu)
			elseif (points < 0) then
				player.alpha = 0
				timer.performWithDelay(1000, restorePlayer)
			end
		end
	end
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

	--[[local background = display.newImageRect(backLayer, "background.jpg", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY]]--
	--
	-- Add First bg image
	--bg1 = display.newRect(0, 0, display.actualContentWidth, display.actualContentHeight )
	bg1 = display.newRect(backLayer, 0, 0, display.actualContentWidth,display.actualContentHeight)
	bg1.fill = bgImage2
	bg1.x = display.contentCenterX
	bg1.y = display.contentCenterY
	--
	-- Add Second bg image
	bg2 = display.newRect(backLayer, 0, 0, display.actualContentWidth,display.actualContentHeight)
	bg2.fill = bgImage2
	bg2.x = display.contentCenterX + display.actualContentWidth
	bg2.y = display.contentCenterY

	player = display.newImageRect(mainLayer, "player.png", 400, 300)
	player.x = display.contentCenterX - 1000
	player.y = display.contentCenterY
	physics.addBody(player, "static", {radius = 30, isSensor=true})
	player.myName = "player"

	--Score is text for prototype
	scoreText = display.newText(uiLayer, "Score: " .. score, display.contentCenterX + 1000, display.contentCenterY - 500, native.systemFont, 80)

	pauseButton = display.newImageRect(uiLayer, "pause.png", 200, 200)
	pauseButton.x = rightBound - 200
	pauseButton.y = bottomBound - 100
	pauseButton.isVisible = true

	playButton = display.newImageRect(uiLayer, "play.png", 200, 200)
	playButton.x = rightBound - 200
	playButton.y = bottomBound - 100
	playButton.isVisible = false

	pauseText = display.newText(uiLayer, "Paused", 100, 100, display.systemFont, 60)
	pauseText.isVisible = false

	createCombinationsTable()
	--init()
	--Debug to print test output to console, will remove later
	print2D(foodCombinations)

	local good = {"lettuce", "lettuce", "lettuce", "lettuce"}
	print(checkCombination(good))
	--------------------------------------------------------------

	player:addEventListener("touch", dragPlayer)
	pauseButton:addEventListener("tap", pause)
	playButton:addEventListener("tap", resume)

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
		--Runtime:addEventListener("enterFrame", enterFrame)
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
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener("collision",onCollision)
		Runtime:removeEventListener("enterFrame", checkBounds)
		Runtime:removeEventListener("enterFrame", moveObject)
		Runtime:removeEventListener("key", keyPressed)
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	physics.pause()
	timer.cancel(gameLoopTimer)
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
