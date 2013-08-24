
Puzzle = class("Puzzle", Entity)

function Puzzle:initialize()

	Entity.initialize(self)
	
	self._animstart = 0
	
end

function Puzzle:update( dt )
	
	local px, py = self:getPos()
	local t = engine.currentTime() - self._animstart
	if (self._leave) then
		px = easing.inOutElastic(t, puzzle_pos_x, -1600, 2, 50, 1)
	elseif (self._enter) then
		px = easing.inOutElastic(t, puzzle_pos_x+1600, -1600, 2, 50, 1)
	end
	self:setPos(px, py)
	
end

function Puzzle:pointer()
	
	return "default" -- alternatives: "default", "cutter"
	
end

function Puzzle:enterScreen()
	
	self._animstart = engine.currentTime()
	self._enter = true
	
end

function Puzzle:exitScreen()
	
	self._animstart = engine.currentTime()
	self._leave = true	
	
end