
local level, display, gui, current_puzzle, puzzle_id, puzzles
local small_font, big_font
local screen_width, screen_height = love.graphics.getWidth, love.graphics.getHeight

function game.load()
	
	love.mouse.setVisible(false)
	small_font = love.graphics.newFont( 12 )
	big_font = love.graphics.newFont( 36 )
	
	level = Level(LevelData(), false)
	display = level:createEntity("TimeDisplay")
	display:setPos(0, 0)
	display:setTimer( 10 )
	
	puzzles = { "Puzzle1", "Puzzle1", "Puzzle1" }
	puzzle_id = 1
	
	level:getCamera():moveTo(screen_width()/2,screen_height()/2, 0)
	
	gui = GUI()
	gui:addDynamicElement(100, Vector(0,0), function()
		if not display:isActive() then
			love.graphics.setColor(0,0,0,200)
			love.graphics.rectangle( "fill", 0, 0, screen_width(), screen_height() )
			love.graphics.setColor(255,255,255,255)
			love.graphics.setFont(big_font)
			love.graphics.printf( "Defuse the bomb", 0, screen_height()/2-50, screen_width(), "center" )
			love.graphics.setFont(small_font)
			love.graphics.printf( "Press space to get started", 0, screen_height()/2+50, screen_width(), "center" )
		end
	end)
	
	input:addKeyReleaseCallback("restart", "r", function() love.load() end)
	input:addKeyReleaseCallback("pause", " ", function()
		if not display:isActive() then display:start()
		elseif (display:isPaused()) then display:continue()
		else display:pause()  end
	end)
	
	current_puzzle = level:createEntity(puzzles[puzzle_id])
	current_puzzle:setPos(65, 135)
	
	print("Game initialized")
	
end

function game.update( dt )
	
	gui:update( dt )
	level:update( dt )
	
end

function game.draw()
	
	--[[love.graphics.setColor(255,0,0,255)
	love.graphics.line(0,0,100,0)
	love.graphics.line(0,0,0,100)
	love.graphics.setColor(255,255,255,255)]]--5
	level:draw( dt )
	gui:draw()
	
end

function game.moveToNextPuzzle()
	
	puzzle_id = puzzle_id + 1
	
	if (puzzles[puzzle_id]) then
		current_puzzle = level:createEntity(puzzles[puzzle_id])
	else
		game.completed()
	end
	
end

function game.puzzleCompleted()

end

function game.explode()

end

function game.completed()

end

function game.getDisplay()

	return display

end
