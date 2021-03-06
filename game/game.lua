
local display, gui, current_puzzle, puzzle_id, puzzles
local small_font, big_font, huge_font
local bkg_img, wirecutter
local snd_explosion, snd_puzzcomplete, snd_victory
local screenWidth, screenHeight = love.graphics.getWidth, love.graphics.getHeight

puzzle_pos_x = 65
puzzle_pos_y = 135

function game.load()
	
	small_font = love.graphics.newFont( 12 )
	big_font = love.graphics.newFont( 36 )
	prettybig_font = love.graphics.newFont( 64 )
	huge_font = love.graphics.newFont( 128 )
	
	snd_explosion = resource.getSound(FOLDER.ASSETS.."sound/explosion.ogg","static")
	snd_victory = resource.getSound(FOLDER.ASSETS.."sound/victory.ogg","static")
	snd_puzzcomplete = resource.getSound(FOLDER.ASSETS.."sound/puzzle_finished.wav","static")
	
	bkg_img = resource.getImage( FOLDER.ASSETS.."background.jpg", "repeat" )
	wirecutter = { open = resource.getImage( FOLDER.ASSETS.."wirecutter.png", false ),
			closed = resource.getImage( FOLDER.ASSETS.."wirecutter_closed.png", false ) }
						
	level = Level(LevelData(), false)
	display = level:createEntity("TimeDisplay")
	display:setPos(0, 0)
	display:setTimer( 10 )
	
	puzzles = { "Puzzle1", "Puzzle2", "Puzzle3", "Puzzle4" }
	puzzle_id = 1
	
	level:getCamera():moveTo(screenWidth()/2,screenHeight()/2, 0)
	
	gui = GUI()
	gui:addDynamicElement(100, Vector(0,0), function()
		if not display:isActive() then
			love.graphics.setColor(0,0,0,200)
			love.graphics.rectangle( "fill", 0, 0, screenWidth(), screenHeight() )
			love.graphics.setColor(255,255,255,255)
			love.graphics.setFont(big_font)
			love.graphics.printf( "Four bombs", 0, screenHeight()/2-50, screenWidth(), "center" )
			love.graphics.setFont(small_font)
			love.graphics.printf( "Press space to get started", 0, screenHeight()/2+50, screenWidth(), "center" )
		end
	end)
	
	input:addKeyReleaseCallback("restart", "r", function() love.load() end)
	input:addKeyReleaseCallback("pause", " ", function()
		if not display:isActive() then display:start() end
		--elseif (display:isPaused()) then display:continue()
		--else display:pause()  end
	end)
	
	current_puzzle = level:createEntity(puzzles[puzzle_id])
	current_puzzle:setPos(puzzle_pos_x, puzzle_pos_y)
	game.startPuzzle()
	
	print("Game initialized")
	
end

function game.update( dt )
	
	gui:update( dt )
	level:update( dt )
	
end

function game.draw()
	
	--[[love.graphics.setColor(255,0,0,255)
	love.graphics.line(0,0,100,0)
	love.graphics.line(0,0,0,100)]]--
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bkg_img, 0, 0)
	level:draw( dt )
	gui:draw()
	
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor(255,255,255,255)
	if (current_puzzle:pointer() == "cutter") then
		if (input:mouseIsDown("l") or input:mouseIsDown("r")) then
			love.graphics.draw(wirecutter.closed, mx, my)
		else
			love.graphics.draw(wirecutter.open, mx, my)
		end
	end
	
end

function game.moveToNextPuzzle()
	
	gui:removeElement("cleared_message")

	current_puzzle:exitScreen()
	current_puzzle = level:createEntity(puzzles[puzzle_id])
	current_puzzle:setPos(puzzle_pos_x+1600, puzzle_pos_y)
	current_puzzle:enterScreen()
	
	timer.simple(2, function()
		game.startPuzzle()
	end)
	
end

function game.startPuzzle()
	
	love.mouse.setVisible(current_puzzle:pointer() == "default")
	gui:addDynamicElement(100, Vector(0,0), function()
		if display:isActive() then
			love.graphics.setColor(200,200,200,255)
			love.graphics.setFont(huge_font)
			love.graphics.printf( current_puzzle:message(), screenHeight()/2+10, 5, screenWidth(), "left" )
		end
	end, "puzzle_message")
	display:continue() 
	
end

function game.puzzleCompleted()
	
	display:pause()
	puzzle_id = puzzle_id + 1
	
	gui:removeElement("puzzle_message")
	
	if (puzzles[puzzle_id]) then
		playWav(snd_puzzcomplete, 1)
		
		gui:addDynamicElement(100, Vector(0,0), function()
			love.graphics.setColor(0,0,0,200)
			love.graphics.rectangle( "fill", 0, screenHeight()/2-10, screenWidth(), 160 )
			love.graphics.setColor(255,255,255,255)
			love.graphics.setFont(huge_font)
			love.graphics.printf( "CLEARED", 0, screenHeight()/2, screenWidth(), "center" )
		end, "cleared_message")
		
		timer.simple(1, game.moveToNextPuzzle)
	else
		game.completed()
	end
	
end

function game.explode()
	
	display:pause()
	
	snd_explosion:play()
	
	local explode_start = engine.currentTime()
	gui:addDynamicElement(100, Vector(0,0), function()
		love.graphics.setColor(255,255,255,math.min(255, (engine.currentTime()-explode_start)*300))
		love.graphics.rectangle( "fill", 0, 0, screenWidth(), screenHeight() )
		
		if (explode_start < engine.currentTime() - 1) then
			love.graphics.setColor(0,0,0,255)
			love.graphics.setFont(small_font)
			love.graphics.printf( "Press r to restart", 0, screenHeight()/2, screenWidth(), "center" )
		end
	end)

end

function game.completed()
	
	snd_victory:play()
	
	gui:addDynamicElement(100, Vector(0,0), function()
		love.graphics.setColor(0,0,0,200)
		love.graphics.rectangle( "fill", 0, screenHeight()/2-60, screenWidth(), 120 )
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(prettybig_font)
		love.graphics.printf( "YOU SAVED EVERYONE", 0, screenHeight()/2-50, screenWidth(), "center" )
		love.graphics.setFont(small_font)
		love.graphics.printf( "Thanks for playing", 0, screenHeight()/2+30, screenWidth(), "center" )
	end, "game_completed")
		
end

function game.getDisplay()

	return display

end

-- function to deal with wav bug
function playWav( snd, t )
	snd:play()
	timer.simple(t, function() snd:stop() end)
end