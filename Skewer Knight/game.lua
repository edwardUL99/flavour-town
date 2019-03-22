local composer = require( "composer" ) --This is very IMPORTANT
local scene = composer.newScene()
local sheetInfo = require("spritesheet") --Introduces the functions required to grab sprites from sheet
local physics = require( "physics" )
local objects = require("objects")

physics.start()
physics.setGravity(0,0)
local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())
----------------------------------------------------------------------------
--VARIABLES BELOW
----------------------------------------------------------------------------
---UI related variables--
local health = 3
local score = 0
local lives = {}
local scoreText
--------------------
--Basic Game Variables--
local paused = false
local died = false
local gameLoopTimer
local gameLoopCycle = 2000 --Time between each game loop
local runtime = 0
--------------------
--Arrays & tables--
local looseFoodsTable = {}
local maxLooseFoods = 10
local onSkewerArray = {}
local foodsToMove = {}
local maxOnSkewer = 4
local foodCombinations = {}
local amountOfCombos = 5 --Decide later
-----------------------
--Audio--
local hurtAudio = audio.loadSound("Oof.mp3")
local eatAudio = audio.loadSound("OmNomNom.wav")
--------------------
--Graphics variables--
local player
local playerShape = {-200,111,  -41,111,   -41,-89,   -200,-89}
local skewerShape = {-40,50,  240,50,  240,31,  -40,31}
local pauseButton
local playButton
local pauseText
local eatButton
local menuButton
local bg1
local bg2 --two SCROLLING backgrounds, to make it look like player is moving)
local bgImage2 = {type = "image", filename ="background.jpg"}
local foodScrollSpeed = 10
local bgScrollSpeed = 5
--------------------
--Boundaries variables--
local leftBound
local rightBound
local topBound
local bottomBound
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
	if (not paused) then
		bg1.x = bg1.x - bgScrollSpeed * dt
		bg2.x = bg2.x - bgScrollSpeed * dt

		if(bg1.x + display.actualContentWidth - 400) < 0 then
			bg1:translate( -bg1.contentWidth * -2, 0)
		end
		if (bg2.x + display.actualContentWidth - 400) < 0 then
			bg2:translate( -bg2.contentWidth * -2, 0)
		end
	end
end

local function trackPlayer()
	if (not paused) then
		for i = #foodsToMove, 1, -1 do
			foodsToMove[i].x = player.x + (75*(i-1))
			foodsToMove[i].y = player.y
		end
	end
end

local function unTrackPlayer()
	for i = #foodsToMove, 1, -1 do
		display.remove(foodsToMove[i])
		table.remove(foodsToMove, i)
	end
end

local function getDeltaTime() --Delta time ensures we have smooth scrolling accross different devices
	local temp = system.getTimer()
	local dt = (temp-runtime) / (1000/60)
	runtime = temp
	return dt
end

local function goToMainMenu()
	composer.setVariable("toScene", "menu")
	composer.removeScene("loading")
	composer.gotoScene("loading","fade",500)

	return true
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

local function dragPlayer(event)
	local player = event.target
	local phase = event.phase
	if (not paused) then
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
	if (not paused) then
		moveBg(dt)
		trackPlayer()
		for i = #looseFoodsTable, 1, -1 do
			looseFoodsTable[i].x = looseFoodsTable[i].x - foodScrollSpeed * dt
			if (looseFoodsTable[i].x < -(display.actualContentWidth)) then
				display.remove(looseFoodsTable[i])
				table.remove(looseFoodsTable, i)
			end
		end
	end
end

--(*Mightn't need if using new checkCombination method)
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


--[[local function updateSkewer()
 --Will provide code to update the food contents on the skewer
 local i = #onSkewerArray
 if (i==nil) then i=0 end
 print("There are " .. #onSkewerArray .. " foods on the skewer.")
if(#onSkewerArray == 1) then
	local foodPos1 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos1.x = display.contentCenterX - (1200 - 55*1)
	foodPos1.y = display.contentCenterY + 600
	foodPos1.height = 50
	foodPos1.width = 50
elseif (#onSkewerArray == 2) then
	local foodPos2 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos2.x = display.contentCenterX - (1200 - 55*2)
	foodPos2.y = display.contentCenterY + 600
	foodPos2.height = 50
	foodPos2.width = 50
elseif (#onSkewerArray == 3) then
	local foodPos3 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos3.x = display.contentCenterX - (1200 - 55*3)
	foodPos3.y = display.contentCenterY + 600
	foodPos3.height = 50
	foodPos3.width = 50
elseif (#onSkewerArray == 4) then
	local foodPos4 = display.newImageRect(mainLayer, imageSheet, sheetInfo:getFrameIndex(onSkewerArray[i]), sheetInfo:getWidth(onSkewerArray[i]), sheetInfo:getHeight(onSkewerArray[i]))
	foodPos4.x = display.contentCenterX - (1200 - 55*4)
	foodPos4.y = display.contentCenterY + 600
	foodPos4.height = 50
	foodPos4.width = 50
end
end
--]]
local function clearSkewer()
	display.remove(foodPos1)
	display.remove(foodPos2)
	display.remove(foodPos3)
	display.remove(foodPos4)
end

--(*Mightn't need if using new checkCombination method)
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

--[[
local function checkCombination(namesTable)
	for i = 1, #foodCombinations do
		if (isEqualArray(foodCombinations[i], namesTable)) then
			return foodCombinations[i][#foodCombinations[i]]
	--[[	end
	end
	return #onSkewerArray*50
end]]--

local function checkCombination(namesTable)
	local foodScores = {
		["bread"] = 125,
		["burger"] = 250,
		["broccoli"] = 25,
		["lettuce"] = -25,
		["tomato"] = 50,
	}
	local sum = 0
	for i = 1, #namesTable do
		sum = sum + foodScores[namesTable[i]]
	end
	return sum
end

local function eatSkewer(event)
	if(#onSkewerArray>0)then
			clearSkewer()
			audio.play(eatAudio)
			unTrackPlayer()
			local points = checkCombination(onSkewerArray)
			score = score + points
			local pointsText = display.newText(uiLayer, "+".. points, player.x+200, player.y+100, display.systemFont, 60)
			timer.performWithDelay(2000, function() transition.fadeOut(pointsText, {time = 500}) end, 1)
			scoreText.text = "Score: " .. score

		--	updateSkewer()
			onSkewerArray = {}
		end
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

local function pause()
 timer.pause(gameLoopTimer)
 paused = true
 pauseText.isVisible = true
 pauseButton.isVisible = false
 playButton.isVisible = true
 eatButton.isVisible = false
 menuButton.isVisible = true
end

local function resume()
	timer.resume(gameLoopTimer)
	paused = false
	pauseText.isVisible = false
	playButton.isVisible = false
	pauseButton.isVisible = true
	eatButton.isVisible = true
	menuButton.isVisible = false
end

local function updateText()
 scoreText.text = "Score: " .. score
 if (health == 2) then
    display.remove(lives[2])
 elseif(health == 1) then
    display.remove(lives[1])
 elseif ( health == 0) then
   display.remove(lives[0])
 end
end

local function gameLoop()
	table.insert(looseFoodsTable, objects:createObjects(mainLayer, rightBound, bottomBound))
	foodScrollSpeed = foodScrollSpeed + 0.5
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--INCOMPLETE/BROKEN FUNCTIONS BELOW
----------------------------------------------------------------------------

---------------------------------------------------------------------------
----------------------------------------------------------------------------
--EMPTY/UNUSED FUNCTIONS BELOW
----------------------------------------------------------------------------


local function moveSprite(event)
----Will be used when joystick is added
	player.x = player.x + motionx
	player.y = player.y + motiony
--end

-- Will be used if we switch to Windows and use arrow keys
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
	if (event.phase == "up") then
		motionx = 0
		motiony = 0
	end
	return false
end

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
      if(event.element1 == 1) then --event.element1 == 1, when the body of the player collides with the food
         print("Player hit!")
         health = health - 1
         print(health)
         --Changes colour of player to red, then changes it back after 500ms
         player:setFillColor(1, 0.2, 0.2)
         timer.performWithDelay(500, function() player:setFillColor(1, 1, 1) end, 1)
         audio.play(hurtAudio)
         updateText()
				 display.remove(collidedObject)
      else
         print("Things stabbed!")
         table.insert(onSkewerArray, collidedObject.myName)
				 timer.performWithDelay(50, function()
				 														collidedObject.isBodyActive = false
																		table.insert(foodsToMove, collidedObject) end)
   			--updateSkewer()
        print(collidedObject.myName)
      end
      for i = #looseFoodsTable, 1, -1 do
         if (looseFoodsTable[i] == collidedObject) then
            table.remove(looseFoodsTable, i)
					end
      end
		if (#onSkewerArray == maxOnSkewer) then
			timer.performWithDelay(200, unTrackPlayer)
			local points = checkCombination(onSkewerArray)
			local plusOrMinus = "+"
			if (points < 0) then
				plusOrMinus = ""
			end
			onSkewerArray = {}
      	audio.play(eatAudio)
			timer.performWithDelay(850, function() clearSkewer() end)
			local pointsText = display.newText(uiLayer, plusOrMinus .. points, player.x+200, player.y+100, display.systemFont, 100)
			local hideTimer = timer.performWithDelay(2000, function() transition.fadeOut(pointsText, {time = 500}) end, 1)
			score = score + points

			if (points < 0 and health > 0) then
				health = health - 1
			end
			updateText()
      end
			if (health < 1) then
				player.alpha = 0
				unTrackPlayer()
				timer.performWithDelay(2000, goToMainMenu)
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
	leftBound = -(display.viewableContentWidth)
	rightBound = display.actualContentWidth - display.contentWidth
	topBound = 0
	bottomBound = display.actualContentHeight

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

  lives[0] = display.newImageRect(uiLayer,"heart.png",200,200)
  lives[0].x = -700
  lives[0].y = 150

  lives[1] = display.newImageRect(uiLayer,"heart.png",200,200)
  lives[1].x = -600
  lives[1].y = 150

  lives[2] = display.newImageRect(uiLayer,"heart.png",200,200)
  lives[2].x = -500
  lives[2].y = 150

	player = display.newImageRect(mainLayer, "player.png", 480, 222)
	player.x = display.contentCenterX - 1000
	player.y = display.contentCenterY
	physics.addBody(player, "static",   {shape = playerShape, isSensor=true},
                                       {shape = skewerShape, isSensor=true})
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

	eatButton = display.newText(uiLayer, "Eat", leftBound + 100, bottomBound - 100, display.systemFont, 80)
	menuButton = display.newText(uiLayer, "Menu", leftBound + 100, bottomBound - 100, display.systemFont, 80)
	menuButton.isVisible = false

	createCombinationsTable()

	player:addEventListener("touch", dragPlayer)
	player:addEventListener("tap", eatSkewer)
	pauseButton:addEventListener("tap", pause)
	menuButton:addEventListener("tap", goToMainMenu)
	playButton:addEventListener("tap", resume)
	eatButton:addEventListener("tap", eatSkewer)

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
		gameLoopTimer = timer.performWithDelay(gameLoopCycle, gameLoop, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		physics.pause()
		timer.cancel(gameLoopTimer)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		print("done")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	Runtime:removeEventListener("collision",onCollision)
	Runtime:removeEventListener("enterFrame", checkBounds)
	Runtime:removeEventListener("enterFrame", moveObject)
	Runtime:removeEventListener("key", keyPressed)
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
