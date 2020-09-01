
local composer = require( "composer" )

local scene = composer.newScene()


local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0 )

local sheetOptions =
{
    frames =
    {
        {   -- Rock 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- rock 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- Rock 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   --Warrior
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   --Spear
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}

local objectSheet = graphics.newImageSheet( "gameObjects.png", sheetOptions )

--Variables
local lives = 3
local score = 0
local died = false
 
local rocksTable = {}
 
local warrior
local gameLoopTimer
local livesText
local scoreText

local backGroup
local mainGroup
local uiGroup

local explosionSound
local fireSound
local musicTrack

--Updating score and Lives 
local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

-- Rock Creation and movement
local function createRock()
 
    local newRock = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
    table.insert( rocksTable, newRock )
    physics.addBody( newRock, "dynamic", { radius=40, bounce=0.8 } )
    newRock.myName = "rock"

    local whereFrom = math.random( 3 )
    -----Rocks starting points
    if ( whereFrom == 1 ) then

        newRock.x = -60
        newRock.y = math.random( 500 )
        newRock:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
    elseif ( whereFrom == 2 ) then

        newRock.x = math.random( display.contentWidth )
        newRock.y = -60
        newRock:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then

        newRock.x = display.contentWidth + 60
        newRock.y = math.random( 500 )
        newRock:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    newRock:applyTorque( math.random( -6,6 ) )
end

local function fireLaser()
    --Firing sound 
	audio.play( fireSound )
 
	local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
	physics.addBody( newLaser, "dynamic", { isSensor=true } )
	newLaser.isBullet = true
	newLaser.myName = "laser"

	newLaser.x = warrior.x
	newLaser.y = warrior.y
	newLaser:toBack()

	transition.to( newLaser, { y=-40, time=500,
	onComplete = function() display.remove( newLaser ) end
	} )
end
--function for moving the warrior
local function dragWarrior( event )
 
    local warrior = event.target
    local phase = event.phase
 
    if ( "began" == phase ) then

        display.currentStage:setFocus( warrior )

        warrior.touchOffsetX = event.x - warrior.x,100
    elseif ( "moved" == phase ) then
      
        warrior.x = event.x - warrior.touchOffsetX,100

    elseif ( "ended" == phase or "cancelled" == phase ) then
      
        display.currentStage:setFocus( nil )

    end

    return true

end

--Creating more rocks
local function gameLoop()
    

    createRock()

    for i = #rocksTable, 1, -1 do
        local thisRock = rocksTable[i]
 
        if ( thisRock.x < -100 or
             thisRock.x > display.contentWidth + 100 or
             thisRock.y < -100 or
             thisRock.y > display.contentHeight + 100 )
        then
            display.remove( thisRock )
            table.remove( rocksTable, i )
        end
 
    end
 
end

--Restore Warrior when he dies 
local function restoreWarrior()
 
    warrior.isBodyActive = false
    warrior.x = display.contentCenterX
    warrior.y = display.contentHeight - 100


    transition.to( warrior, { alpha=1, time=4000,
        onComplete = function()
            warrior.isBodyActive = true
            died = false
        end
    } )
end

--ending the game
local function endGame()
    composer.setVariable( "finalScore", score )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

--functiion for collision, eplosions, lasers , score increment and updating lives
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "laser" and obj2.myName == "rock" ) or
             ( obj1.myName == "rock" and obj2.myName == "laser" ) )
        then
            display.remove( obj1 )
			display.remove( obj2 )
			
			audio.play( explosionSound )

            for i = #rocksTable, 1, -1 do
                if ( rocksTable[i] == obj1 or rocksTable[i] == obj2 ) then
                    table.remove( rocksTable, i )
                    break
                end
            end

            score = score + 100
            scoreText.text = "Score: " .. score

            elseif ( ( obj1.myName == "warrior" and obj2.myName == "rock" ) or
            ( obj1.myName == "rock" and obj2.myName == "warrior" ) )
            then
                if ( died == false ) then
                    died = true
					
					audio.play( explosionSound )

                    lives = lives - 1
                    livesText.text = "Lives: " .. lives

                    if ( lives == 0 ) then
						display.remove( warrior )
						timer.performWithDelay( 2000, endGame )
                    else
                        warrior.alpha = 0
                        timer.performWithDelay( 1000, restoreWarrior )
                    end
                end
        end
        
    end
end

--go to menu form game which is also quit
local function gotoMenu()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

-- Scene event functions 

--craete scene
function scene:create( event )

	local sceneGroup = self.view
	
	physics.pause()

	backGroup = display.newGroup()  
    sceneGroup:insert( backGroup ) 
 
    mainGroup = display.newGroup()  
    sceneGroup:insert( mainGroup )  
 
    uiGroup = display.newGroup()    
	sceneGroup:insert( uiGroup )
	
	local background = display.newImageRect( backGroup, "background.jpg", 800, 1400 )
    background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	warrior = display.newImageRect( mainGroup, objectSheet, 4.5, 98, 79 )
    warrior.x = display.contentCenterX
    warrior.y = display.contentHeight - 100
    physics.addBody( warrior, { radius=40, isSensor=true } )
    warrior.myName = "warrior"
 
    livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )
	
	warrior:addEventListener( "tap", fireLaser )
	warrior:addEventListener( "touch", dragWarrior )

	local menuButton = display.newText( sceneGroup, "== Menu ==" ,display.contentCenterX, 40,display.contentCenterY, 60, native.systemFont, 40 )
    menuButton:setFillColor( 0.75, 0.78, 1 )
    menuButton:addEventListener( "tap", gotoMenu )
	
	explosionSound = audio.loadSound( "audio2/break.mp3" )
	fireSound = audio.loadSound( "audio2/Spear.wav" )
	musicTrack = audio.loadStream( "audio2/AFROBEAT INSTRUMENTAL - MAGICAL GIRL.wav")
end

--showing or running the scene
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

		physics.start()
        Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
		audio.play( musicTrack, { channel=1, loops=-1 } )
		
	end
end

--hide and stop scene and music
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()

		audio.stop( 1 )
		composer.removeScene( "game" )


	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view

	audio.dispose( explosionSound )
    audio.dispose( fireSound )
    audio.dispose( musicTrack )
	

end


--pause function when screen is tapped anywhere ecxept on menu button or on the warrior
function pause(event)
    if event.phase == "began" then
        if paused == false then
             physics.pause()
             paused = true
        elseif paused == true then
             physics.start()
             paused = false
        end
   end
end
paused = false

-- Scene event function listeners

Runtime:addEventListener("touch", pause)
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
