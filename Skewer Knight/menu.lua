-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local json = require("json")
local filePath = system.pathForFile("firstLaunch.json", system.DocumentsDirectory)

--------------------------------------------

-- forward declarations and other locals
local playButton
local isFirstLaunch = {}

local function loadFirstLaunch()
	local file = io.open(filePath, "r")

	if file then
		local contents = file:read("*a")
		io.close(file)
		isFirstLaunch = json.decode(contents)
	end

  if (isFirstLaunch == nil or #isFirstLaunch == 0) then
    isFirstLaunch = {true}
  end
end

local function saveFirstLaunch()
	local file = io.open(filePath, "w")

	if file then
		file:write(json.encode(isFirstLaunch))
		io.close(file)
	end
end

local function goToTutorial()
  composer.gotoScene("tutorial", "fade", 500)
	
	return true
end 

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	playButton.emboss = false
	-- go to level1.lua scene
  if (isFirstLaunch[1] == true) then
    isFirstLaunch[1] = false
    saveFirstLaunch()
    goToTutorial()
  else 
    composer.removeScene("game")
    timer.performWithDelay(500, function() composer.gotoScene( "game", "fade", 500 ) end)
  end-- indicates successful touch
end

local function goToJournal()
	composer.removeScene("journal")
	timer.performWithDelay(50, function() composer.gotoScene("journal", "fade", 500) end)

	return true
end

function scene:create( event )
	local sceneGroup = self.view
  
	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	loadFirstLaunch()
	
	local background = display.newImageRect( "Images/background.jpg", display.actualContentWidth, display.actualContentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x = 0 + display.screenOriginX
	background.y = 0 + display.screenOriginY

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "Images/logo.png", 464, 82 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100

	-- create a widget button (which will load game.lua on release)
	local options =
	{
		label="Play",
		fontSize = 80,
		shape = "roundedRect",
		width=250,
		height=125,
		fillColor = { default = { 0.25, 0.25, 0.25, 1}, over = {0.5, 0.5, 0.5, 1} },
		strokeColor = { default = {1, 1, 1}, over = {1, 0, 0} },
		strokeWidth = 2
	}
  playButton = widget.newButton(options)
	playButton.x = display.contentCenterX
	playButton.y = display.contentHeight - 125

	--playBtn = display.newText("Play Now", display.contentCenterX, display.contentHeight - 125, native.systemFont, 55)
	--playBtn:setFillColor(0, 1, 0)

	local options1 =
  {
	label="Journal",
	fontSize = 80,
	shape = "roundedRect",
	width=260,
	height=125,
	fillColor = { default = { 0.25, 0.25, 0.25, 1}, over = {0.5, 0.5, 0.5, 1} },
	strokeColor = { default = {1, 1, 1}, over = {1, 0, 0} },
	strokeWidth = 2
  }
  local journalBtn = widget.newButton(options1)
  journalBtn.x = 1000
  journalBtn.y = display.contentHeight - 125
  

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playButton )
	sceneGroup:insert(journalBtn)

	playButton:addEventListener("tap", onPlayBtnRelease)
	journalBtn:addEventListener("tap", goToJournal)
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
    composer.removeScene("menu")
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playButton then
		playButton:removeSelf()	-- widgets must be manually removed
		playButton = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
