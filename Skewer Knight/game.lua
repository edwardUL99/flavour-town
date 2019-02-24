
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()
physics.setGravity(0,0)

local foodsTable = {}
local gameLoopTimer
local scrollSpeed --Speed of background
local health
local score
local healthText
local scoreText
local paused = false
local died = false
local height = display.contentHeight
local character
--We want two of the same background to add scrolling effect.
--Does the background remain constant with character/foods moving
--or is it moving?
local bg1
local bg2
local motionx = 0
local motiony = 0
local speed = 2

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
end

local function addScrollableBg()
	local bgImage = {type="image",filename="background.png"}
	--Code to add first background image
	--Code to add second background image
end

local function keyPressed(event)
	--Need to add code to add boundaries
	if (event.phase = "down" and paused ~= true) then
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
	return true
end

local function moveSprite(event)
	character.x = character.x + motionx
	character.y = character.y + motiony
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
	if (paused ~= true) then
		for i = #foodsTable, 1, -1 do
			foodsTable[i].y - foodsTable[i].y + scrollSpeed
			if (foodsTable[i].y > height + 100) then
				display.remove(potholesTable[i])
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
end

local function onCollision(event)
	--Will provide code for collision events
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


	character:addEventListener("key", keyPressed)
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
		Runtime:addEventListener("enterFrame", enterFrame)
		Runtime:addEventListener("enterFrame", moveObject)
		Runtime:addEventListener("enterFrame", moveSprite)
		--gameLoopTimer = timer.performWithDelay(2000, gameLoop, 0)
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
