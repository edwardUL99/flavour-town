local composer = require( "composer" ) --This is very IMPORTANT
local scene = composer.newScene()
local sheetInfo = require("Images.spritesheet") --Introduces the functions required to grab sprites from sheet
local objects = require("objects")
local physics = require( "physics" )
--local json = require("json")
--local filePath = system.pathForFile("tables.json", system.DocumentsDirectory)

physics.start()

physics.setGravity(0,0)
local imageSheet = graphics.newImageSheet("Images/spritesheet.png", sheetInfo:getSheet())
----------------------------------------------------------------------------
--VARIABLES BELOW
----------------------------------------------------------------------------
---UI related variables--
local health = 3
local score = 0
local pointsDoubled = false
local lives = {}
local scoreText
--------------------
--Basic Game Variables--
local paused = false
local died = false
local gameLoopTimer
local timerPowerUp
local gameLoopCycle = 2000 --Time between each game loop
local gameLoopCount = 0
local runtime = 0
--------------------
--Arrays & tables--
local looseFoodsTable = {}
local foodCombos = {}
local spawnRate = 1
local onSkewerArray = {}
local foodsToMove = {}
local maxOnSkewer = 3
local foodCombinations = {}
local amountOfCombos = 5 --Decide later
-----------------------
--Audio--
local hurtAudio = audio.loadSound("Oof.mp3")
local eatAudio = audio.loadSound("OmNomNom.wav")
--------------------
--Graphics variables--
local heartXPos = -800
local heartYPos = 150
local heartArrayPos = 0
local player
local playerShape = {-200,111,  -41,111,   -41,-89,   -200,-89}
local skewerShape = {-40,50,  240,50,  240,31,  -40,31}
local pauseButton
local playButton
local pauseText
local eatButton
local menuButton
local journalButton
local bg1
local bg2 --two SCROLLING backgrounds, to make it look like player is moving)
local bgImage2 = {type = "image", filename ="Images/background.jpg"}
local foodScrollSpeed = 15
local bgScrollSpeed = 5
--local skewerOffset = 0
--------------------
--Boundaries variables--
local leftBound = -(display.viewableContentWidth)
local rightBound = display.actualContentWidth - display.contentWidth
local topBound = 250
local bottomBound = display.actualContentHeight
--------------------
--Providing variables for displayGroups to be used later--
local backLayer
local mainLayer
local uiLayer
--------------------
------------------- (I don't know if we're still using these, but I saw they were deleted.
local motionx = 0     --Keeping them here just in case that was by accident) (Aidan)
local motiony = 0	--Character movement variables
local speed = 20
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
	if (not paused and player ~= nil) then
		for i = #foodsToMove, 1, -1 do
			foodsToMove[i].x = player.x + (75*(i-1))
			foodsToMove[i].y = player.y --+ skewerOffset
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
	--composer.removeScene("game")
	composer.setVariable("scene", "menu")
	composer.setVariable("fromScene", "game")
  composer.setVariable("score", score)
	composer.gotoScene("loading","fade",500)

	return true
end

local function goToJournal()
	composer.setVariable("scene", "journal")
	composer.setVariable("fromScene", "game")
	composer.setVariable("score", score)
	composer.gotoScene("loading", "fade", 500)

	return true
end

local function checkBounds()
	if (player ~= nil) then
    if (player.x > rightBound) then
      player.x = rightBound - 30
    elseif (player.x < leftBound) then
      player.x = leftBound + 70
    end

    if (player.y < topBound) then
      player.y = topBound + 30
    elseif (player.y > bottomBound) then
      player.y = bottomBound - 30
    end
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

local function moveSprite(event)
----Will be used when joystick is added
if(player == nil)then
	return
end
	player.x = player.x + motionx
	player.y = player.y + motiony
end

local function enterFrame(event)
	local dt = getDeltaTime();
	if (not paused) then
		moveBg(dt)
		trackPlayer()
    checkBounds()
    moveSprite()
		for i = #looseFoodsTable, 1, -1 do
			looseFoodsTable[i].x = looseFoodsTable[i].x - foodScrollSpeed * dt
			if (looseFoodsTable[i].x < -(display.actualContentWidth)) then
				table.remove(looseFoodsTable, i)
        display.remove(looseFoodsTable[i])
			end
		end
	end
end

--(*Mightn't need if using new checkCombination method)
local function isEqualArray(table1, table2)
	--Since the score value is only stored at end of each combination table, we can ignore it and check the names only
	if (#table1 == #table2) then
		for i = 1, #table1 do
			if (table1[i] ~= table2[i]) then
				return false
			end
		end
		return true
	elseif (#table1 == 4 and #table2 == 3) then
    for i = 1, #table2 do
      if (table1[i] ~= table2[i]) then
        return false
      end
    end
    return true
  end
	return false
end

local function isDefCombo(combo)
  for i = 1, #foodCombinations do
    if (isEqualArray(foodCombinations[i], combo)) then
      return true
    end
  end
  return false
end

--(*Mightn't need if using new checkCombination method)
local function createCombinationsTable()
	for i = 1, amountOfCombos do --Creating 2D array
		foodCombinations[i] = {}
	end
	--The score values for each combination is in the last position i.e #foodCombinations[i] where i is some number 1-5
	--[[foodCombinations[1] = {"bread", "bread", "bread", 500}
	foodCombinations[2] = {"broccoli", "broccoli", "broccoli", 50}
	foodCombinations[3] = {"burger", "burger", "burger", 1000}
	foodCombinations[4] = {"lettuce", "lettuce", "lettuce", -100}
	foodCombinations[5] = {"tomato", "tomato", "tomato", 200}]]--

  foodCombinations[1] = {"sushi", "sushi", "sushi", 500}
	foodCombinations[2] = {"cheese", "cheese", "cheese", 50}
	foodCombinations[3] = {"bacon", "bacon", "bacon", 1000}
	foodCombinations[4] = {"broccoli", "broccoli", "broccoli", -100}
	foodCombinations[5] = {"tomato", "tomato", "tomato", 200}
  foodCombinations[6] = {"carrot", "carrot", "carrot", 100}

  composer.setVariable("defCombos", foodCombinations)
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

local function checkCombinationDefault(namesTable)
	--[[local foodScores = {
		["bread"] = 125,
		["burger"] = 250,
		["broccoli"] = 25,
		["lettuce"] = -25,
		["tomato"] = 50,
	} ]]--
  local foodScores = {
    ["bacon"] = 250,
    ["broccoli"] = 25,
    ["carrot"] = 75,
    ["cheese"] = 80,
    ["sushi"] = 150,
    ["tomato"] = 50,
  }
	local sum = 0
	for i = 1, #namesTable do
		sum = sum + foodScores[namesTable[i]]
	end
	return sum
end


local function checkCombination(namesTable)
	for i = 1, #foodCombinations do
		if (isEqualArray(foodCombinations[i], namesTable)) then
			return foodCombinations[i][#foodCombinations[i]]
    end
	end
	return checkCombinationDefault(namesTable)
end

local function addHeart()
  if (health <= 3) then
    heartXPos = heartXPos + 100
    heartArrayPos = heartArrayPos + 1
    lives[heartArrayPos] = display.newImageRect(uiLayer,"Images/heart.png",200,200)
    lives[heartArrayPos].x = heartXPos
    lives[heartArrayPos].y = heartYPos
  end
end

local function removeHeart()
	if (health == 2) then
      display.remove(lives[3])
      heartXPos = heartXPos - 100
      heartArrayPos = 2
   elseif(health == 1) then
      display.remove(lives[2])
      heartXPos = heartXPos - 100
      heartArrayPos = 1
   elseif ( health == 0) then
     display.remove(lives[1])
     heartXPos = heartXPos - 100
     heartArrayPos = 0
   end
end

local function onComplete()
  local overText = display.newText(uiLayer, "x2 Points multiplier over", player.x+300, player.y, native.systemFont, 80)
  timer.performWithDelay(2000, function() transition.fadeOut(overText, {time = 500}) end)
end

local function checkPowerUp()
	if(isEqualArray(onSkewerArray,{"tomato","tomato","tomato"}))then
		if(health<3)then
			local healthNewText = display.newText(uiLayer, "+1 Health", player.x+100, player.y, native.systemFont, 80)
			timer.performWithDelay(2000, function() transition.fadeOut(healthNewText, {time = 500}) end, 1)
			health = health + 1
			addHeart()

		end
	elseif(isEqualArray(onSkewerArray,{"bacon","bacon","bacon"}))then
		if(skewerOffset ~= 0)then -- prevents player from increasing in size more than once
			return
		end
		print("Extra chunky")
		transition.scaleBy(player, {xScale = 1, yScale = 1})
		--skewerOffset = skewerOffset + 50
		local playerShapeXL = {2*-200,2*111,  2*-41,2*111,   2*-41,2*-89,   2*-200,2*-89}
		local skewerShapeXL = {2*-40,2*50,  2*240,2*50,  2*240,2*31,  2*-40,2*31}
		physics.removeBody(player)
		physics.addBody(player,"kinematic", {shape = playerShapeXL, isSensor = true},
														{shape = skewerShapeXL, isSensor = true})
		--reduces body shape back to normal
		timerPowerUp = timer.performWithDelay(10000, function()
			if(player ~= nil) then
				transition.scaleBy(player, {xScale = -1, yScale = -1})
				physics.removeBody(player)
				--skewerOffset = skewerOffset - 50
				physics.addBody(player,"kinematic", {shape = playerShape, isSensor = true},
																{shape = skewerShape, isSensor = true})
			end
		end)
	elseif(isEqualArray(onSkewerArray, {"broccoli","broccoli","broccoli"}))then
		print("Go green")
		player:setFillColor(0, 1, 0.2)
	elseif (isEqualArray(onSkewerArray, {"sushi", "sushi", "sushi"})) then
    pointsDoubled = true
    local doubledText = display.newText(uiLayer, "x2 Points multiplier", player.x+100, player.y, native.systemFont, 80)
    timer.performWithDelay(2000, function() transition.fadeOut(doubledText, {time = 500}) end, 1)
    timerPowerUp = timer.performWithDelay(10000, function() pointsDoubled = false
                                                            onComplete()
                                                  end)
  end
end

local function updateText()
 scoreText.text = "Score: " .. score
end

local function eatSkewer(event)
	if(#onSkewerArray>0)then

    if (isDefCombo(onSkewerArray)) then
      table.insert(foodCombos, onSkewerArray)
      composer.setVariable("skewerArray", foodCombos)
    end

		audio.play(eatAudio)
		unTrackPlayer()

    checkPowerUp()

    local points = checkCombination(onSkewerArray)

    if (pointsDoubled) then
      points = points * 2
    end

		score = score + points
		local pointsText = display.newText(uiLayer, "+".. points, player.x + 200, player.y + 100, display.systemFont, 60)
		timer.performWithDelay(2000, function() transition.fadeOut(pointsText, {time = 500}) end, 1)
		scoreText.text = "Score: " .. score

		--	updateSkewer()
			onSkewerArray = {}
			if (points < 0 and health > 0) then
				health = health - 1
			end
			updateText()
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
 if gameLoopTimer then
  timer.pause(gameLoopTimer)
 end

 if timerPowerUp then
 	timer.pause(timerPowerUp)
 end
 paused = true
 pauseText.isVisible = true
 pauseButton.isVisible = false
 playButton.isVisible = true
 eatButton.isVisible = false
 menuButton.isVisible = true
 journalButton.isVisible = true
end

local function resume()
  if gameLoopTimer then
    timer.resume(gameLoopTimer)
  end

	if timerPowerUp then
		timer.resume(timerPowerUp)
	end
	paused = false
	pauseText.isVisible = false
	playButton.isVisible = false
	pauseButton.isVisible = true
	eatButton.isVisible = true
	menuButton.isVisible = false
	journalButton.isVisible = false
end

local function gameLoop()
  gameLoopCount = gameLoopCount + 1
	for i = 1, spawnRate do
  	table.insert(looseFoodsTable, objects:createObjects(mainLayer, rightBound, bottomBound, topBound))
	end

  if (gameLoopCount % 15 == 0 and gameLoopCycle > 100) then
    gameLoopCycle = gameLoopCycle - 100
    timer.cancel(gameLoopTimer)
    gameLoopTimer = timer.performWithDelay(gameLoopCycle, gameLoop, 0)
  end

  if (gameLoopCount % 25 == 0 and spawnRate < 4) then
		spawnRate = spawnRate + 1
	end

	if(foodScrollSpeed < 30)then
		foodScrollSpeed = foodScrollSpeed + 0.5
	end

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

-- Will be used if we switch to Windows and use arrow keys
local function arrowPressed(event)
	if (event.phase == "down") then
		if (event.keyName == "left" or event.keyName =="a") then
			motionx = -speed
		elseif (event.keyName == "right" or event.keyName =="d") then
			motionx = speed
		elseif (event.keyName == "down"or event.keyName =="s") then
			motiony = speed
		elseif (event.keyName == "up"or event.keyName =="w") then
			motiony = -speed
		end
	end
	if (event.phase == "up" and activeButton == nil) then
		motionx = 0
		motiony = 0
	end
	return false
end

local function indexOf(table, object)
	for i = 1, #table do
		if (table[i] == object) then
			return i
		end
	end
	return -1
end

local function isFood(object)
	if (object.myName == "cheese"
			or object.myName == "sushi"
			or object.myName == "broccoli"
			or object.myName == "carrot"
			or object.myName == "tomato"
			or object.myName == "bacon") then
				return true
	end
	return false
end

local function onCollision(event) --(*Is lettuce considered an enemy food? I'll assume it is for now)
	if (event.phase == "began" and player ~= nil) then
		local collidedObject = event.object2
		if (collidedObject.myName == "player") then
			collidedObject = event.object1
		end

    --print(collidedObject.myName)

    --print(event.object1.myName)
    --print(event.object2.myName)

    if (event.element1 == 1 and (event.object1.myName == "player" or event.object2.myName == "player")) then --event.element1 == 1, when the body of the player collides with the food
      print("Body Collided")
      health = health - 1
      --Changes colour of player to red, then changes it back after 500ms
      player:setFillColor(1, 0.2, 0.2)
      timer.performWithDelay(500, function() if (player ~= nil) then player:setFillColor(1, 1, 1) end end, 1)
      audio.play(hurtAudio)
      updateText()
		removeHeart()

      if (indexOf(looseFoodsTable, collidedObject) ~= -1) then
        table.remove(looseFoodsTable, indexOf(looseFoodsTable, collidedObject))
         display.remove(collidedObject)
      end

      --player dies
      if (health < 1) then
        player.alpha = 0
        timer.performWithDelay(50, function() player.isBodyActive = false end)
        unTrackPlayer()
        timer.performWithDelay(2000, goToMainMenu)
      end

      print(isFood(event.object2))
    elseif ((event.object1.myName == "player" and isFood(event.object2))) then
      print("Things stabbed!")
      table.remove(looseFoodsTable, indexOf(looseFoodsTable, collidedObject))
      table.insert(onSkewerArray, collidedObject.myName)
      timer.performWithDelay(50, function()
                                collidedObject.isBodyActive = false
                                table.insert(foodsToMove, collidedObject) end)
    else
      print(collidedObject.myName)
      table.remove(looseFoodsTable, indexOf(looseFoodsTable, collidedObject))
    end
    if (#onSkewerArray == maxOnSkewer) then
      table.remove(looseFoodsTable, indexOf(looseFoodsTable, collidedObject))
      print(collidedObject.myName)
      timer.performWithDelay(50, function()
                                 collidedObject.isBodyActive = false
																 table.insert(foodsToMove, collidedObject)
                                 eatSkewer()
                               end)
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

  player = display.newImageRect(mainLayer, "Images/player.png", 480, 222)
	player.x = display.contentCenterX - 1000
	player.y = display.contentCenterY
	physics.addBody(player, "static",   {shape = playerShape, isSensor=true},
                                       {shape = skewerShape, isSensor=true})
	player.myName = "player"

  for i = 1, 3 do
    addHeart()
  end

	--Score is text for prototype
	scoreText = display.newText(uiLayer, "Score: " .. score, display.contentCenterX + 900, display.contentCenterY - 500, native.systemFont, 80)

	pauseButton = display.newImageRect(uiLayer, "Images/pause.png", 200, 200)
	pauseButton.x = rightBound - 200
	pauseButton.y = bottomBound - 100
	pauseButton.isVisible = true

	playButton = display.newImageRect(uiLayer, "Images/play.png", 200, 200)
	playButton.x = rightBound - 200
	playButton.y = bottomBound - 100
	playButton.isVisible = false

	pauseText = display.newText(uiLayer, "Paused", 100, 100, display.systemFont, 60)
	pauseText.isVisible = false

	eatButton = display.newImageRect(uiLayer, "Images/eatButton.png", 200, 200)
  eatButton.x = leftBound + 100
  eatButton.y = bottomBound - 100
	menuButton = display.newText(uiLayer, "Menu", leftBound + 100, bottomBound - 100, display.systemFont, 80)
	menuButton.isVisible = false

	journalButton = display.newText(uiLayer, "Journal", leftBound + 400, bottomBound - 100, display.systemFont, 80)
	journalButton.isVisible = false

	player:addEventListener("touch", dragPlayer)
	player:addEventListener("tap", eatSkewer)
	pauseButton:addEventListener("tap", pause)
	menuButton:addEventListener("tap", goToMainMenu)
	playButton:addEventListener("tap", resume)
	eatButton:addEventListener("tap", eatSkewer)
	journalButton:addEventListener("tap", goToJournal)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
    print("Scene shown")
		physics.start()
    Runtime:addEventListener("collision", onCollision)
		Runtime:addEventListener("enterFrame", enterFrame)
		Runtime:addEventListener("key", keyPressed)
		Runtime:addEventListener("key", arrowPressed)
		gameLoopTimer = timer.performWithDelay(gameLoopCycle, gameLoop, 0)
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    Runtime:removeEventListener("enterFrame", enterFrame)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    print("hidden")

    composer.removeScene("game")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
  print("removed")
  Runtime:removeEventListener("collision",onCollision)
  Runtime:removeEventListener("key", keyPressed)
  audio.dispose(eatAudio)
  audio.dispose(hurtAudio)
  physics.pause()
	timer.cancel(gameLoopTimer)

  if timerPowerUp then
    timer.cancel(timerPowerUp)
  end
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
