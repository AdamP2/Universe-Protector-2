-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
--Variables

local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )
 
math.randomseed( os.time() )

audio.reserveChannels( 1 ) 
--overall volume of the sound
audio.setVolume( 0.05, { channel=1 } )
-- Go to the menu screen
composer.gotoScene( "menu" )