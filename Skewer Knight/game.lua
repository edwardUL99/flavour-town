
local composer = require( "composer" )

local scene = composer.newScene()

local sheetInfo = require("spritesheet") --Introduces the functions required to grab sprites from sheet
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local physics = require( "physics" )
physics.start()
physics.setGravity(0,0)

--Tables and image sheet required for game -
local foodsTable = {}
local skewered = {}
local maxFoodsOnDisplay = 10 --Arbitrary set to 10 for now
local maxSkewered = 4 --Arbitrary, set to 4 for now
local imageSheet = graphics.newImageSheet("spritesheet.png", sheetInfo:getSheet())
-- ------------------


local gameLoopTimer
local scrollSpeed = 2 --Speed of background. Arbitrarily set to 2 for now

------------------
local health = 3
local score = 0
local healthText      --UI-related variables
local scoreText
local paused = false
local died = false
--------------------


--Graphics variables--
local character
--We want two of the same background to add scrolling effect.
--Does the background remain constant with character/foods moving
--or is it moving?
local bg1
local bg2
--------------------

-------------------
local motionx = 0
local motiony = 0	--Character movement variables
local speed = 2
-------------------

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
	composer.removeScene("game")
	composer.gotoScene("menu","fade",500)
end

local function createObjects()
	--Will provide code to randomly create certain objects
	local names = {"bread", "broccoli", "burger", "lettuce", "tomato"} --Will be randomly accessed
	local name = names[math.random(#names)]
	local newItem = display.newImageRect(mainGroup, imageSheet, sheetInfo:getFrameIndex(name))
	table.insert(foodsTable, newItem)
	newItem.myName = name
	physics.addBody(newItem, "dynamic", {radius=40, bounce=0.0})

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
	--Code to maybe add back button functionality to go to main menu
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
	if (paused ~= true) then 
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
	end
	
	return true
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
			foodsTable[i].y = foodsTable[i].y + scrollSpeed
			if (foodsTable[i].y > height + 100) then
				display.remove(potholesTable[i])
				table.remove(foodsTable, i)
				if (#foodsTable < maxFoodsOnDisplay) then
					createObjects()
				end
			end
		end
	end
end

--May not be needed?
local function moveBg(dt)
	--Code to move background if necessary.
	--Google how to do scrolling background
	--http://lomza.totem-soft.com/tutorial-scrollable-background-in-corona-sdk/
end

local function enterFrame(event)
	local dt = getDeltaTime()
	moveBg(dt)
end

local function pause()
 --Will provide pause function
end

local function isEqualTable(table1, table2)
 --To be used in checkCombination method to check if the second table is equal to the table of ideal food combination(2nd table must be in same order as first table)
 --table1 could be implemented as a 2D array of all arrays of ideal combinations, we'll see
 if (#table1 == #table2) then
  for i=1, #table2, 1 do
   if (table1[i] ~= table2[i]) then
    return false
   end
  end
 else 
  return false
 end
		
 return true
end

local function checkCombination(namesTable)
 --Will check a table with the food combination and return the score 
end 

local function store(objectsTable)
 --Will store the names of the objects in the table in an array and pass it to che checkCombination function
 local namesTable = {}
 for i = 1, #objectsTable, 1 do
   namesTable[i] = objectsTable[i].myName
 end
 
 return checkCombination(namesTable)
end

local function updateSkewer()
 --Will provide code to update the food contents on the skewer
end 

local function updateText()
 --Will ensure text is always updated 
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

	local background = display.newImageRect(backGroup, "background.jpg", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	character = display.newImageRect(mainGroup, "character.png", 400, 300)
	character.x = display.contentCenterX - 1000
	character.y = display.contentCenterY
	character.myName = "character"

	--Health is just text for prototype
	healthText = display.newText(uiGroup, "Health: " .. health, display.contentCenterX - 1000, display.contentCenterY - 500, native.systemFont, 80)

	--Score is text for prototype
	scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX + 1000, display.contentCenterY - 500, native.systemFont, 80)


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
		--Runtime:addEventListener("enterFrame", moveSprite)
		Runtime:addEventListener("key", keyPressed)
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
