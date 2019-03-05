
local composer = require( "composer" )

local scene = composer.newScene()

local sheetInfo = require("spritesheet")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()
physics.setGravity(0,0)

local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())

local foodsTable = {}
local collideds = {}
local gameLoopTimer
local scrollSpeed --Speed of background
local health = 3
local score = 0
local healthText
local scoreText
local paused = false
local died = false
local character
--We want two of the same background to add scrolling effect.
--Does the background remain constant with character/foods moving
--or is it moving?
local bg1
local bg2

-----------------
local motionx = 0
local motiony = 0	--Movement variables
local speed = 2
-----------------

--Boundaries variables
------------------------------------------------
local leftBound = -(display.viewableContentWidth)
local rightBound = display.actualContentWidth - display.contentWidth
local topBound = 0
local bottomBound = display.actualContentHeight
-------------------------------------------------

---------------
local backGroup
local mainGroup  ---------Providing variables for displayGroups to be used later
local uiGroup
---------------

--Providing a simple function to return to menu
local function goToMenu()
	composer.gotoScene("menu","fade",500)
end

local function createObjects()
	--Will provide code to randomly create certain objects
	names = {"bread", "broccoli", "burger", "lettuce", "tomato"}
	local name = names[math.random(5)]
	newItem = display.newImage(mainGroup, imageSheet, sheetInfo:getFrameIndex(name))
	newItem.height = 200
	newItem.width = 200
	newItem.myName = name
	table.insert(foodsTable, newItem)
	physics.addBody(newItem,"dynamic", {radius=40, isSensor = true} )
	newItem.x = rightBound + 100
	newItem.y = math.random(bottomBound)
	newItem:toBack()
end

local function addScrollableBg()
	local bgImage = {type="image",filename="background.png"}
	--Code to add first background image
	--Code to add second background image
end

--May not need this function if we are using mouse to drag character
--Will have to add boundaries
local function keyPressed(event)
	--Need to add code to add boundaries
	if (event.phase == "down" and paused ~= true) then
		if (event.keyName == "left") then
			motionx = -speed
		elseif (event.keyName == "right") then
			motionx = speed
		elseif (event.keyName == "up") then
			motiony = -speed
		elseif (event.keyName == "down") then
			motiony = speed
		end
	end

	if (event.phase == "up") then
		motionx = 0
		motiony = 0
	end
	return true
end

--Will be used when joystick is added
local function moveSprite(event)
	character.x = character.x + motionx
	character.y = character.y + motiony
end

local function checkBounds()
	if (character.x > rightBound) then
		character.x = rightBound - 20
	elseif (character.x < leftBound) then
		character.x = leftBound + 20
	end

	if (character.y < topBound) then
		character.y = topBound + 20
	elseif (character.y > bottomBound) then
		character.y = bottomBound - 20
	end
end

local function dragCharacter(event)
	local character = event.target
	local phase = event.phase
	if ("began" == phase) then
		display.currentStage:setFocus(character)
		character.touchOffsetX = event.x - character.x
		character.touchOffsetY = event.y - character.y
	elseif ("moved" == phase) then
		character.x = event.x - character.touchOffsetX
		character.y = event.y - character.touchOffsetY
	elseif ("ended" == phase or "cancelled" == phase) then
		display.currentStage:setFocus(nil)
	end

	return true
end

local function back(event)
	local key = event.keyName
  if (event.phase == "down") then
		if (key == "back") then
			composer.removeScene("game")
			composer.gotoScene("menu",{time=800,effect="crossFade"})
		end
	end

	if (event.phase == "up") then
		return true
	end
end

local runtime = 0

--Delta time ensures we have smooth scrolling accross different devices
local function getDeltaTime()
	local temp = system.getTimer()
	local dt = (temp-runtime) / (1000/60)
	runtime = temp
	return dt
end

local function moveObject(event)
	local dt = getDeltaTime()
	if (paused ~= true) then
		for i = #foodsTable, 1, -1 do
			scrollSpeed = 2
			foodsTable[i].x = foodsTable[i].x - scrollSpeed * dt
			if (foodsTable[i].x < -(display.actualContentWidth)) then
				display.remove(foodsTable[i])
				table.remove(foodsTable, i)
				createObjects()
			end
		end
	end
end

local function moveBg(dt)
	bg1.y = bg1.y + scrollSpeed * dt
	bg2.y = bg2.y + scrollSpeed * dt

	if (bg1.y - display.contentHeight/2) > display.actualContentHeight  then
 		bg1:translate(0, -bg1.contentHeight * 2)
	end
	if (bg2.y - display.contentHeight/2) > display.actualContentHeight  then
 		bg2:translate(0, -bg2.contentHeight * 2)
	end
end

local function enterFrame(event)
	moveBg(getDeltaTime())
end

local function pause()
 --Will provide pause function
end

local function resume()
	--Will provide resume function
end

local function gameLoop()
	--Will provide the function for spawning objects randomly
	createObjects()
end

local function moveCollideds()
	local move = function()
		for i = 1, #collideds, 1 do
			collideds[i].x = character.x
			collideds[i].y = character.y
			collideds[i].isBodyActive = false
		end
	end

	timer.performWithDelay(100, move, 1)
end

local function onCollision(event)
	--Will provide code for collision events
	local obj1 = event.object1
	local obj2 = event.object2
	if (event.phase == "began") then
		if (obj1.myName == "character" and obj2.myName == "burger") then
			display.remove(obj2)
			for i = #foodsTable, 1, -1 do
				if (foodsTable[i] == obj2) then
					table.insert(collideds, obj2)
					table.remove(foodsTable, i)
					break
				end
			end
			score = score + 100
			scoreText.text = "Score: " .. score
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local background = display.newImageRect(backGroup, "background.jpg", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	character = display.newImageRect(mainGroup, "character.png", 400, 300)
	character.x = display.contentCenterX - 1000
	character.y = display.contentCenterY
	physics.addBody(character, "static", {radius = 30, isSensor=true})
	character.myName = "character"

	--Health is just text for prototype
	healthText = display.newText(uiGroup, "Health: " .. health, display.contentCenterX - (display.contentCenterX * 2), display.contentCenterY - 500, native.systemFont, 80)

	--Score is text for prototype
	scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX + (display.contentCenterX * 2), display.contentCenterY - 500, native.systemFont, 80)


	character:addEventListener("touch", dragCharacter)
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
		--Runtime:addEventListener("enterFrame", moveCollideds)
		Runtime:addEventListener("key", back)
		gameLoopTimer = timer.performWithDelay(3000, gameLoop, 0)
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


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
