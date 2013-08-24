
TimeDisplay = class("TimeDisplay", Entity)

function TimeDisplay:initialize()
	
	Entity.initialize(self)
	
	self._time = 0
	self._paused = true
	self._active = false
	self._sprite = resource.getImage( FOLDER.ASSETS.."display.png", false )
	self._number = Sprite(SpriteData( FOLDER.ASSETS.."lcdnumbers.png", Vector(0,0), Vector(100,150), Vector(0,0), 10, 10, 1, true ))
	
end

function TimeDisplay:update( dt )
	
	if not self._paused then
		self._time = math.max(0, self._time - dt)
		if (self._time <= 0) then
			game.explode()
		end
	end
	
end

function TimeDisplay:draw()
	
	--[[
	local x, y = self:getPos()
	love.graphics.setColor(0,255,0)
	love.graphics.line(x, y, x+100, y)
	love.graphics.line(x, y, x, y+100)
	love.graphics.setColor(255,255,255)
	]]--
	
	love.graphics.draw(self._sprite, 0, 0)
	
	-- draw timer numbers
	local px, py = self:getPos()
	local sx, sy = 19, 16
	self._number:setCurrentFrame(math.floor(self._time/10)+1)
	self._number:draw(px+sx, py+sy, 0, 0.7, 0.7)
	sx = sx+70
	self._number:setCurrentFrame(math.floor(self._time%10)+1)
	self._number:draw(px+sx, py+sy, 0, 0.7, 0.7)
	sx = sx+70
	sy = 59
	self._number:setCurrentFrame(math.floor((self._time*10)%10)+1)
	self._number:draw(px+sx, py+sy, 0, 0.4, 0.4)
	sx = sx+40
	self._number:setCurrentFrame(math.floor((self._time*100)%10)+1)
	self._number:draw(px+sx, py+sy, 0, 0.4, 0.4)
	sx = sx+40
	self._number:setCurrentFrame(math.floor((self._time*1000)%10)+1)
	self._number:draw(px+sx, py+sy, 0, 0.4, 0.4)
	
end

function TimeDisplay:setTimer( secs )
	
	self._time = secs
	
end

function TimeDisplay:pause()

	if (self._active) then self._paused = true end

end

function TimeDisplay:start()

	self._paused = false
	self._active = true

end

function TimeDisplay:continue()
	
	if (self._active) then self._paused = false end
	
end

function TimeDisplay:isPaused()

	return self._paused

end

function TimeDisplay:isActive()
	
	return self._active
	
end