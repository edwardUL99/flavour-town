
local composer = require( "composer" )

local scene = composer.newScene()
local settings = require("settings")

local json = require("json")

local path = system.pathForFile("settings.json", system.DocumentsDirectory)
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local background
local leftKeyField
local downKeyField
local rightKeyField
local upKeyField
local pauseKeyField
local eatKeyField
local moveSpeedField
local volumeField
local mainLayer
local textInputs = {}

local function settingsTableLength()
	count = 0
	for w in pairs(settings) do
		if settings[w] then
			count = count + 1
		end
	end
	return count
end


local function goToMainMenu()
	composer.gotoScene("menu", "fade", 500)
end

local function loadSettings()
	local file = io.open(path, "r")

	print(file)

	if file then
		local contents = file:read("*a")
		io.close(file)
		settings = json.decode(contents)
	end
end

local function saveSettings()
	local file = io.open(path, "w")

	if file then
		file:write(json.encode(settings))
		io.close(file)
	end
end

local function textListener(event)
		local target = event.target
    if ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
 			local text = target.text
			print(target.myName)
			if (target.myName == "volume" or target.myName == "moveSpeed") then
				settings[target.myName] = text
			else
				settings[target.myName] = text
			end
			if text then
				target.placeholder = "" .. settings[target.myName]
			end
			print(settings[target.myName])
    end
end

local function removeFields()
	for i = 1, #textInputs do
		if textInputs[i] then
			display.remove(textInputs[i])
			textInputs[i] = nil
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
	mainLayer = display.newGroup()
	sceneGroup:insert(mainLayer)

	loadSettings()
	local background = display.newImageRect(mainLayer,"Images/background.jpg", display.actualContentWidth, display.actualContentHeight)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

			local upText = display.newText(mainLayer, "Move Up", display.contentCenterX - 500, display.contentCenterY - 300, native.systemFont, 50)
			upKeyField = native.newTextField(display.contentCenterX - 300, display.contentCenterY - 300, 150, 150)
			upKeyField.placeholder = settings["up"]
			upKeyField:setReturnKey("next")
			upKeyField.myName = "up"
			upKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs, upKeyField)

			local leftText = display.newText(mainLayer, "Move Left", display.contentCenterX - 500, display.contentCenterY - 100, native.systemFont, 50)
			leftKeyField = native.newTextField(display.contentCenterX - 300, display.contentCenterY - 100, 150, 150)
			leftKeyField.placeholder = settings["left"]
			leftKeyField.myName = "left"
			leftKeyField:setReturnKey("next")
			leftKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs, leftKeyField)

			local downText = display.newText(mainLayer, "Move Down", display.contentCenterX - 510, display.contentCenterY + 100, native.systemFont, 50)
			downKeyField = native.newTextField(display.contentCenterX - 300, display.contentCenterY + 100, 150, 150)
			downKeyField.placeholder = settings["down"]
			downKeyField.myName = "down"
			downKeyField:setReturnKey("next")
			downKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs, downKeyField)

			local rightText = display.newText(mainLayer, "Move Right", display.contentCenterX - 500, display.contentCenterY + 300, native.systemFont, 50)
			rightKeyField = native.newTextField(display.contentCenterX - 300, display.contentCenterY + 300, 150, 150)
			rightKeyField.placeholder = settings["right"]
			rightKeyField.myName = "right"
			rightKeyField:setReturnKey("next")
			rightKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs,rightKeyField)

			local eatText = display.newText(mainLayer, "Eat", display.contentCenterX - 500, display.contentCenterY + 500, native.systemFont, 50)
			eatKeyField = native.newTextField(display.contentCenterX - 300, display.contentCenterY + 500, 150, 150)
			eatKeyField.placeholder = settings["eat"]
			eatKeyField.myName = "eat"
			eatKeyField:setReturnKey("next")
			eatKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs,eatKeyField)

			local pauseText = display.newText(mainLayer, "Pause", display.contentCenterX + 500, display.contentCenterY - 300, native.systemFont, 50)
			pauseKeyField = native.newTextField(display.contentCenterX + 700, display.contentCenterY - 300, 150, 150)
			pauseKeyField.placeholder = settings["pause"]
			pauseKeyField.myName = "pause"
			pauseKeyField:setReturnKey("next")
			pauseKeyField:addEventListener("userInput", textListener)
			table.insert(textInputs,pauseKeyField)

			local moveText = display.newText(mainLayer, "Movement Speed", display.contentCenterX + 400, display.contentCenterY - 100, native.systemFont, 50)
			moveSpeedField = native.newTextField(display.contentCenterX + 700, display.contentCenterY - 100, 150, 150)
			moveSpeedField.placeholder = "" .. settings["moveSpeed"]
			moveSpeedField.myName = "moveSpeed"
			moveText.inputType = "number"
			moveSpeedField:setReturnKey("next")
			moveSpeedField:addEventListener("userInput", textListener)
			table.insert(textInputs,moveSpeedField)

			local volumeText = display.newText(mainLayer, "Volume", display.contentCenterX + 500, display.contentCenterY + 100, native.systemFont, 50)
			volumeField = native.newTextField(display.contentCenterX + 700, display.contentCenterY + 100, 150, 150)
			volumeField.placeholder = "" .. settings["volume"]
			volumeField.inputType = "number"
			volumeField.myName = "volume"
			volumeField:setReturnKey("next")
			volumeField:addEventListener("userInput", textListener)
			table.insert(textInputs,volumeField)

			local mainMenu = display.newText(mainLayer, "Menu", display.contentCenterX + 1000, display.contentCenterY + 500, native.systemFont, 50)
			mainMenu:addEventListener("tap", goToMainMenu)

			sceneGroup:insert(leftKeyField)
			sceneGroup:insert(upKeyField)
			sceneGroup:insert(rightKeyField)
			sceneGroup:insert(downKeyField)
			sceneGroup:insert(eatKeyField)
			sceneGroup:insert(pauseKeyField)
			sceneGroup:insert(moveSpeedField)
			sceneGroup:insert(volumeField)

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		saveSettings()
		composer.setVariable("settings", settings)
		removeFields()
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene("settings")
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	textInputs = nil
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
