
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local background
local prevButton
local nextButton
local tutorialObjects = {}
local backLayer
local uiLayer

local function goToGame()
	composer.goToScene("game", "fade", 800)
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

	background = display.newImageRect(backLayer, "Images/tutorialBackground.png", display.actualContentWidth,display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	nextButton = display.newImageRect(uiLayer, "Images/next.png", 400, 200)
	nextButton.x = display.contentCenterX + 500
	nextButton.y = display.contentCenterY + 580

	prevButton = display.newImageRect(uiLayer, "Images/prev.png", 400, 220)
	prevButton.x = display.contentCenterX - 500
	prevButton.y = display.contentCenterY + 580
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
