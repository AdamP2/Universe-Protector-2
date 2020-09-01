
local composer = require( "composer" )

local scene = composer.newScene()

-------Variables
local musicTrack

--go to game
local function gotoGame()
	composer.gotoScene( "game", { time=800, effect="crossFade" } )
end

--go to highscores
local function gotoHighScores()
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

-- Scene event functions 

--craete scene
function scene:create( event )

	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "background_4.jpg", 800, 1400 )
    background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	local title = display.newImageRect( sceneGroup, "title-1.png", 500, 80 )
    title.x = display.contentCenterX
	title.y = 200
	
	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44 )
    playButton:setFillColor( 0.82, 0.86, 1 )
 
    local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, 810, native.systemFont, 44 )
	highScoresButton:setFillColor( 0.75, 0.78, 1 )
	
	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )
	musicTrack = audio.loadStream( "audio2/Zulu Loops .wav" )

end

--showing or running the scene
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
		audio.play( musicTrack, { channel=1, loops=-1 } )
	end
end

--hide and stop scene and music
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		

	elseif ( phase == "did" ) then
		audio.stop( 1 )
	end
end


--hide and stop scene and music
function scene:destroy( event )

	local sceneGroup = self.view
	audio.dispose( musicTrack )
end

-- Scene event function listeners
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene

