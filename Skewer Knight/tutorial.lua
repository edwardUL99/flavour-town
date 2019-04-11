
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local background
local prevButton
local nextButton
local tutorial
local tutorialObjects = {}
local previous = 1 --Stores the previously displayed object's index, tutorialObjects[1] will be the first displayed
local next = 2
local backLayer
local uiLayer

local function goToGame()
	composer.gotoScene("game", "fade", 800)
end

local function nextBanner()
	if (next <= #tutorialObjects) then
		tutorialObjects[previous].isVisible = false
		tutorialObjects[next].isVisible = true
		previous = next
		next = next + 1
	else
		goToGame()
	end
end

local function prevBanner()
	if (previous > 1) then
		local current = previous
		tutorialObjects[current].isVisible = false
		tutorialObjects[previous-1].isVisible = true
		previous = previous - 1
		next = next - 1
	end
end

local function keyPressed(event)
	local keyName = event.keyName
	if (event.phase == "down") then
		if (keyName == "right") then
			nextBanner()
		elseif (keyName == "left") then
			prevBanner()
		end
	elseif (event.phase == "up") then
		return false
	end
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

	background = display.newImageRect(backLayer, "Images/Tutorial/tutorialBackground.png", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	nextButton = display.newImageRect(uiLayer, "Images/Tutorial/next.png", 400, 200)
	nextButton.x = display.contentCenterX + 500
	nextButton.y = display.contentCenterY + 580

	local tutorial = display.newText(uiLayer, "Tutorial", display.contentCenterX - 50, display.contentCenterY + 580, native.systemFont, 80)

	prevButton = display.newImageRect(uiLayer, "Images/Tutorial/prev.png", 400, 220)
	prevButton.x = display.contentCenterX - 500
	prevButton.y = display.contentCenterY + 580

	tutorialObjects[1] = display.newImageRect(uiLayer, "Images/Tutorial/playerControl.png", 1000, 800)
	tutorialObjects[1].x = display.contentCenterX
	tutorialObjects[1].y = display.contentCenterY

	tutorialObjects[2] = display.newImageRect(uiLayer, "Images/Tutorial/healthScoreTut.png", 1000, 800)
	tutorialObjects[2].x = display.contentCenterX
	tutorialObjects[2].y = display.contentCenterY - 400
	tutorialObjects[2].isVisible = false

	tutorialObjects[3] = display.newImageRect(uiLayer, "Images/Tutorial/skewerTut.png", 800, 800)
	tutorialObjects[3].x = display.contentCenterX - 400
	tutorialObjects[3].y = display.contentCenterY - 300
	tutorialObjects[3].isVisible = false

	tutorialObjects[4] = display.newImageRect(uiLayer, "Images/Tutorial/bodyTut.png", 800, 800)
	tutorialObjects[4].x = display.contentCenterX - 750
	tutorialObjects[4].y = display.contentCenterY - 150
	tutorialObjects[4].isVisible = false

	tutorialObjects[5] = display.newImageRect(uiLayer, "Images/Tutorial/enemyObject.png", 800, 800)
	tutorialObjects[5].x = display.contentCenterX
	tutorialObjects[5].y = display.contentCenterY - 150
	tutorialObjects[5].isVisible = false

	tutorialObjects[6] = display.newImageRect(uiLayer, "Images/Tutorial/example.png", 800, 800)
	tutorialObjects[6].x = display.contentCenterX
	tutorialObjects[6].y = display.contentCenterY
	tutorialObjects[6].isVisible = false

	nextButton:addEventListener("tap", nextBanner)
	prevButton:addEventListener("tap", prevBanner)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
	Runtime:addEventListener("key", keyPressed)
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
		Runtime:removeEventListener("key", keyPressed)
		composer.removeScene("tutorial")
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
