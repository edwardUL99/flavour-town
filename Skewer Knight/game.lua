local composer = require( "composer" ) --This is very IMPORTANT
local scene = composer.newScene()
local objects = require("objects")
local options = require("settings")
local settings = composer.getVariable("settings")
local physics = require( "physics" )
local powerUps = require("powerUps")

physics.start()
physics.setGravity(0,0)
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
local hurtAudio = audio.loadSound("Oof.wav")
local eatAudio = audio.loadSound("OmNomNom.wav")
local pickupAudio = audio.loadSound("pickup.wav")
local powerUpAudio = audio.loadSound("powerup.wav")
local powerUpOver = audio.loadSound("powerupover.wav")
--------------------
--Graphics variables--
local heartXPos = -800
local heartYPos = 150
local heartArrayPos = 0
local player
local skewerShape = {-40,50,  240,50,  240,31,  -40,31}
local playerShape = {-200,111,  -41,111,   -41,-89,   -200,-89}
local pauseButton
local playButton
local pauseText
local exitButton
local muteButton
local muted = false
local soundButton
local eatButton
local menuButton
local journalButton
local displayObjects = {}
local bg1
local bg2 --two SCROLLING backgrounds, to make it look like player is moving)
local bgImage2 = {type = "image", filename ="Images/background.jpg"}
local foodScrollSpeed = 15
local bgScrollSpeed = 5
local skewerOffset = 0
local powerUpState = false --to prevent the player from getting more than one power up
local afterIncrease = false
--------------------
--Boundaries variables--
local leftBound = -(display.viewableContentWidth) + 100
local rightBound = display.actualContentWidth - display.contentWidth - 300
local topBound = 250
local bottomBound = display.actualContentHeight - 100
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
			foodsToMove[i].y = player.y + skewerOffset
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
      player.x = rightBound
    elseif (player.x < leftBound) then
      player.x = leftBound
    elseif (player.y < topBound) then
      player.y = topBound
    elseif (player.y > bottomBound) then
      player.y = bottomBound
    end
  end

  if (#foodsToMove > 0) then
    for i = 1, #foodsToMove do
      if (foodsToMove[i].y < topBound) then
        foodsToMove[i].y = topBound + 30
      elseif (foodsToMove[i].x < leftBound) then
        foodsToMove[i].x = leftBound + (80*(i-1))
      elseif (foodsToMove[i].x > rightBound) then
        foodsToMove[i].x = rightBound - 30
      end
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
      if (not (player.y < topBound)) then
        player.x = event.x - player.touchOffsetX
        player.y = event.y - player.touchOffsetY
      end
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
        local foodToRemove = looseFoodsTable[i]
				table.remove(looseFoodsTable, i)
        display.remove(foodToRemove)
			end
		end
	end
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

local function tableCopy(table)
	local copy = {}
	for i = 1, #table do
		copy[i] = table[i]
	end
	return copy
end

--(*Mightn't need if using new checkCombination method)
local function isEqualArray(table1, table2)
	--Since the score value is only stored at end of each combination table, we can ignore it and check the names only
	local tempTable1 = tableCopy(table1)
	local tempTable2 = tableCopy(table2)

	table.remove(tempTable1, 4)
	table.sort(tempTable1)
	table.sort(tempTable2)

	print(#tempTable1)
	print(#tempTable2)
	--if both tables are same but different order the table.sort will fix that
	if (#tempTable1 == #tempTable2) then
		for i = 1, #tempTable1 do
			if (tempTable1[i] ~= tempTable2[i]) then
				return false
			end
		end
		return true
	end
	return false
end

local function comboIndex(combo)
  for i = 1, #foodCombinations do
    if (isEqualArray(foodCombinations[i], combo)) then
      return i
    end
  end
  return nil
end

--(*Mightn't need if using new checkCombination method)
local function createCombinationsTable()
	foodCombinations[1] = {"bacon", "lettuce", "tomato", 800}
	foodCombinations[2] = {"bread", "cheese", "burger", 950}
	foodCombinations[3] = {"bacon", "bacon", "bacon", 1000}
	foodCombinations[4] = {"bacon", "cheese",  "tomato", 600}
  foodCombinations[5] = {"carrot", "tomato", "lettuce", 500}
	foodCombinations[6] = {"bacon", "cheese", "sushi", 750}
	foodCombinations[7] = {"bread", "bacon", "burger", 1000}
	foodCombinations[8] = {"bread", "tomato", "bacon", 650}
	foodCombinations[9] = {"bread", "lettuce", "burger", 850}
	foodCombinations[10] = {"bread", "tomato", "burger", 900}
	foodCombinations[11] = {"sushi", "carrot", "tomato", 400}
	foodCombinations[12] = {"sushi", "bacon", "burger", 900}
end

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
    ["broccoli"] = -10,
    ["carrot"] = 75,
    ["cheese"] = 80,
    ["sushi"] = 150,
    ["tomato"] = 50,
		["burger"] = 100,
		["lettuce"] = 40,
		["bread"] = 55
  }
	local sum = 0
	for i = 1, #namesTable do
		sum = sum + foodScores[namesTable[i]]
	end
	return sum
end


local function checkCombination(namesTable)
	if comboIndex(namesTable) ~= nil then
		return foodCombinations[comboIndex(namesTable)][#foodCombinations[comboIndex(namesTable)]]
	else
		return checkCombinationDefault(namesTable)
	end
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
	display.remove(lives[heartArrayPos])
	table.remove(lives, heartArrayPos)
	heartArrayPos = heartArrayPos - 1
	heartXPos = heartXPos - 100
end

local function onComplete()
  if player then
    local overText = display.newText(uiLayer, "x2 Points multiplier over", player.x+300, player.y, native.systemFont, 80)
  end
  timer.performWithDelay(2000, function() transition.fadeOut(overText, {time = 500}) end)
	timerPowerUp = nil
	audio.play(powerUpOver)
end

local function checkPowerUp()
	if(powerUpState)then
		return
	end
	if(isEqualArray(onSkewerArray,{"tomato","tomato","tomato"}))then
		audio.play(powerUpAudio)
		if(health<3)then
			local healthNewText = display.newText(uiLayer, "+1 Health", player.x+100, player.y, native.systemFont, 80)
			timer.performWithDelay(2000, function() transition.fadeOut(healthNewText, {time = 500}) end, 1)
			health = health + 1
			addHeart()

		end
	elseif(isEqualArray(onSkewerArray,{"bacon","bacon","bacon"}))then
		audio.play(powerUpAudio)
		skewerOffset = powerUps.baconSizeIncrease(player, skewerOffset)
		powerUpState = true
		afterIncrease = false
		--reduces body shape back to normal
		timerPowerUp = timer.performWithDelay(10000, function()
			skewerOffset = powerUps.baconSizeShrink(player, skewerOffset, skewerShape, playerShape)
			powerUpState = false
			afterIncrease = true
			timerPowerUp = nil
			audio.play(powerUpOver)
		end)
	elseif(isEqualArray(onSkewerArray, {"broccoli","broccoli","broccoli"}))then
		player:setFillColor(0, 1, 0.2)
		audio.play(hurtAudio)
		health = health - 3
		for i = #lives, 1, -1 do
			removeHeart()
		end
	  player.alpha = 0
	  timer.performWithDelay(50, function() player.isBodyActive = false end)
		unTrackPlayer()
	 	timer.performWithDelay(2000, goToJournal)

	elseif (isEqualArray(onSkewerArray, {"sushi", "sushi", "sushi"})) then
		audio.play(powerUpAudio)
	   pointsDoubled = true
	   local doubledText = display.newText(uiLayer, "x2 Points multiplier", player.x+100, player.y, native.systemFont, 80)
	   timer.performWithDelay(2000, function() transition.fadeOut(doubledText, {time = 500}) end, 1)
	   timerPowerUp = timer.performWithDelay(10000, function() pointsDoubled = false
	                                                            onComplete()
	                                                  end)
	elseif(isEqualArray(onSkewerArray, {"tomato", "lettuce", "carrot"})) then
		audio.play(powerUpAudio)
		local smallText = display.newText(uiLayer, "Evasiveness increased!", player.x+100, player.y, native.systemFont, 80)
		powerUpState = true
		transition.fadeOut(smallText, {time = 1000})
		powerUps.evasivenessShrink(player)
		timerPowerUp = timer.performWithDelay(10000, function()
			powerUps.evasivenessRevert(player, skewerShape, playerShape)
			powerUpState = false
			timerPowerUp = nil
			audio.play(powerUpOver)
		end)
  end
end

local function eatSkewer(event)
	if(#onSkewerArray>0)then
    local points = checkCombination(onSkewerArray)
		printTable(onSkewerArray)

		if comboIndex(onSkewerArray) then
			local comboText = display.newText(uiLayer, "Food Combo!", player.x + 100, player.y - 100, native.systemFont, 50)
			timer.performWithDelay(2000, function() transition.fadeOut(comboText, {time = 500}) end)
		end

    if (pointsDoubled) then
      points = points * 2
    end
		local sign = "+"
		if (points < 0) then sign = "" end
    score = score + points
		local pointsText = display.newText(uiLayer, sign .. points .. " " .. "points", player.x + 200, player.y + 100, native.systemFont, 60)
		timer.performWithDelay(2000, function() transition.fadeOut(pointsText, {time = 500}) end)
		scoreText.text = "Score: " .. score

    local indexComboTable = comboIndex(onSkewerArray)
    if (indexComboTable ~= nil) then
			printTable(foodCombinations[indexComboTable])
      table.insert(foodCombos, foodCombinations[indexComboTable])
      composer.setVariable("skewerArray", foodCombos)
    end

		audio.play(eatAudio)
		timer.performWithDelay(500, function() audio.play(eatAudio) end)
		unTrackPlayer()

  	checkPowerUp()
		onSkewerArray = {}
  end
end

local function back(event)
	if (event.phase == "down") then
		if (event.keyName == "back") then
			goToMainMenu()
		end
	end

	if (event.phase == "up") then
		return true
	end
end

local function exit()
	os.exit()
end

local function mute()
  if (muted) then
    muted = false
    audio.setVolume(settings["volume"] * 10 / 100)
    muteButton.text = "Mute"
  else
    audio.setVolume(0)
    muted = true
    muteButton.text = "Unmute"
  end
end

local function makeObjectsVisible(visible)
	for i = 1, #displayObjects do
		displayObjects[i].isVisible = visible
	end
end

local function pause()
 paused = true
 if gameLoopTimer then
  timer.pause(gameLoopTimer)
 end

 if timerPowerUp then
 	timer.pause(timerPowerUp)
 end
 playButton.isVisible = true
 pauseButton.isVisible = false
 eatButton.isVisible = false
 makeObjectsVisible(true)
end

local function resume()
	paused = false
  if gameLoopTimer then
    timer.resume(gameLoopTimer)
  end

	if timerPowerUp then
		timer.resume(timerPowerUp)
	end
	playButton.isVisible = false
	pauseButton.isVisible = true
	eatButton.isVisible = true
	makeObjectsVisible(false)
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

end

local function keyPressed(event)
	if (event.phase == "down") then
		if (event.keyName == "left" or event.keyName == settings["left"]) then
			motionx = -speed
		elseif (event.keyName == "right" or event.keyName == settings["right"]) then
			motionx = speed
		elseif (event.keyName == "down"or event.keyName == settings["down"]) then
			motiony = speed
		elseif (event.keyName == "up"or event.keyName == settings["up"]) then
			motiony = -speed
		elseif (event.keyName == "m" and (not paused)) then
			mute()
		elseif (event.keyName == "m" and paused) then
			goToMainMenu()
		elseif (event.keyName == "j" and paused) then
			goToJournal()
		elseif (event.keyName == "e" and paused) then
			exit()
		elseif (event.keyName == settings["eat"] and paused == false) then
			eatSkewer()
		elseif (event.keyName == settings["pause"]) then
			if not paused then
				pause()
			else
				resume()
			end
		end
	elseif (event.phase == "up" ) then
		motionx = 0
		motiony = 0
	end
	return false
end

local function isFood(object)
	if (objects:foodObject(object) ~= nil) then
		return true
	else
		return false
	end
end

local function removeObjectFromTable(object)
	for i = #looseFoodsTable, 1, -1 do
		if (looseFoodsTable[i] == object) then
			table.remove(looseFoodsTable, i)
		end
	end
end

local function playerHit (self,event)
	print("event.selfElement is " .. event.selfElement)
end



local function onCollision(event)
	if (event.phase == "began" and player ~= nil) then
		local collidedObject = event.object2
		if (collidedObject.myName == "player") then
			collidedObject = event.object1
		end

		if (event.object1.myName ~= "player") then
			local temp = event.object1
			event.object1 = event.object2
			event.object2 = temp
		end
		local numberToCompare = 2

		if (afterIncrease == true) then
			numberToCompare  = 1
		end

    if ((event.object1.myName == "player" and event.element1 == 2)
	 	or (event.object1.myName == "player" and event.element2 == numberToCompare)) then --event.element1 == 1, when the body of the player collides with the food
			print("Collision on body")
      health = health - 1
      --Changes colour of player to red, then changes it back after 500ms
      player:setFillColor(1, 0.2, 0.2)
      timer.performWithDelay(500, function() if (player ~= nil) then player:setFillColor(1, 1, 1) end end, 1)
      audio.play(hurtAudio)
			removeHeart()

    	removeObjectFromTable(collidedObject)
      display.remove(collidedObject)

      --player dies
      if (health < 1) then
        player.alpha = 0
        timer.performWithDelay(50, function() player.isBodyActive = false end)
        unTrackPlayer()
        timer.performWithDelay(2000, goToJournal)
      end

	elseif (event.object1.myName == "player") then
			audio.play(pickupAudio)
  		removeObjectFromTable(collidedObject)
      table.insert(onSkewerArray, collidedObject.myName)
      timer.performWithDelay(50, function()
                                collidedObject.isBodyActive = false
                                table.insert(foodsToMove, collidedObject) end)

  	  if (#onSkewerArray >= maxOnSkewer) then
				removeObjectFromTable(collidedObject)
        timer.performWithDelay(50, function()
                                 collidedObject.isBodyActive = false
																 table.insert(foodsToMove, collidedObject)
								eatSkewer()
                               end)
		  end
		end
  end
end
----------------------------------------------------------------------------
-- Scene event functions
----------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	physics.pause()

	if (settings == nil) then
		settings = options.load()
		speed = settings["moveSpeed"]
	end
	speed = settings["moveSpeed"]
	audio.setVolume(settings["volume"] * 10 / 100)

	backLayer = display.newGroup()
	sceneGroup:insert(backLayer)

  mainLayer = display.newGroup()
	sceneGroup:insert(mainLayer)

	uiLayer = display.newGroup()
	sceneGroup:insert(uiLayer)

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
	physics.addBody(player, "static",  {shape = skewerShape, isSensor=true},{shape = playerShape, isSensor=true})
	player.myName = "player"

  for i = 1, 3 do
    addHeart()
  end

  player.preCollision = playerHit
  player:addEventListener("preCollision")

	--Score is text for prototype
	scoreText = display.newText(uiLayer, "Score: " .. score, display.contentCenterX + 900, display.contentCenterY - 500, native.systemFont, 80)

	pauseButton = display.newImageRect(uiLayer, "Images/pause.png", 200, 200)
	pauseButton.x = rightBound
	pauseButton.y = bottomBound - 100
	pauseButton.isVisible = true

  muteButton = display.newText (uiLayer,"Mute", leftBound + 800, bottomBound, native.systemFont, 80)
	muteButton.isVisible = false
	table.insert(displayObjects, muteButton)
  muteButton:addEventListener("tap", mute)

	playButton = display.newImageRect(uiLayer, "Images/play.png", 200, 200)
	playButton.x = rightBound
	playButton.y = bottomBound - 100
	playButton.isVisible = false

	pauseText = display.newText(uiLayer, "Paused", 100, 100, display.systemFont, 60)
	pauseText.isVisible = false
	table.insert(displayObjects, pauseText)

	eatButton = display.newImageRect(uiLayer, "Images/eatButton.png", 200, 200)
  eatButton.x = leftBound + 100
  eatButton.y = bottomBound - 100
	menuButton = display.newText(uiLayer, "Menu", leftBound , bottomBound, display.systemFont, 80)
	table.insert(displayObjects, menuButton)
	menuButton.isVisible = false

  exitButton = display.newText(uiLayer, "Exit", leftBound + 1200, bottomBound, display.systemFont, 80)
	exitButton.isVisible=false
	table.insert(displayObjects, exitButton)

	journalButton = display.newText(uiLayer, "Journal", leftBound + 400, bottomBound, display.systemFont, 80)
	journalButton.isVisible = false
	table.insert(displayObjects, journalButton)

	player:addEventListener("touch", dragPlayer)
	player:addEventListener("tap", eatSkewer)
	pauseButton:addEventListener("tap", pause)
	menuButton:addEventListener("tap", goToMainMenu)
  exitButton:addEventListener("tap", exit)
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
		createCombinationsTable()
    print("Scene shown")
		physics.start()
    Runtime:addEventListener("collision", onCollision)
		Runtime:addEventListener("enterFrame", enterFrame)
		Runtime:addEventListener("key", back)
		Runtime:addEventListener("key", keyPressed)
		gameLoopTimer = timer.performWithDelay(gameLoopCycle, gameLoop, 0)
	end
end


-- hide()
function scene:hide(event)

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		if gameLoopTimer then
			timer.cancel(gameLoopTimer)
		end

		if timerPowerUp then
      timer.cancel(timerPowerUp)
    end

    Runtime:removeEventListener("enterFrame", enterFrame)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    print("hidden")
		Runtime:removeEventListener("collision",onCollision)
		Runtime:removeEventListener("key", keyPressed)
		Runtime:addEventListener("key", back)
		audio.dispose(eatAudio)
		audio.dispose(hurtAudio)
		audio.dispose(powerUpAudio)
		audio.dispose(pickupAudio)
		audio.dispose(powerUpOver)
		physics.pause()
    composer.removeScene("game")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	print("removed")
	player = nil
	foodCombinations = nil
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
