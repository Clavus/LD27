
Puzzle4 = class("Puzzle4",Puzzle)

function Puzzle4:initialize()

	Puzzle.initialize(self)
	
	self._image = resource.getImage( FOLDER.ASSETS.."puzzle4.png", false )
	self._blink = resource.getImage( FOLDER.ASSETS.."armed_light.png", false )
	self._blinktime = 0
	
	self._snd_shift = resource.getSound(FOLDER.ASSETS.."sound/shift.wav","static")
	
	self._partsize = 60
	self._fieldw = 3
	self._fieldh = 3
	
	self._field = {
		{
			{ tcol = 1, trow = 1, img = resource.getImage( FOLDER.ASSETS.."pic_topleft.png", false ), obj = level:createEntity("ImagePart") },
			{ tcol = 2, trow = 1, img = resource.getImage( FOLDER.ASSETS.."pic_topmid.png", false ), obj = level:createEntity("ImagePart") },
			{ tcol = 3, trow = 1, img = resource.getImage( FOLDER.ASSETS.."pic_topright.png", false ), obj = level:createEntity("ImagePart") }
		},
		{
			--{ tcol = 1, fy = 2, img = resource.getImage( FOLDER.ASSETS.."pic_midleft.png", false ), obj = level:createEntity("ImagePart") }, -- this one we leave out
			
			{ tcol = 1, trow = 3, img = resource.getImage( FOLDER.ASSETS.."pic_bottomleft.png", false ), obj = level:createEntity("ImagePart") },
			{ empty = true },
			{ tcol = 3, trow = 3, img = resource.getImage( FOLDER.ASSETS.."pic_bottomright.png", false ), obj = level:createEntity("ImagePart") }
		},
		{
			{ tcol = 2, trow = 3, img = resource.getImage( FOLDER.ASSETS.."pic_bottommid.png", false ), obj = level:createEntity("ImagePart") },
			{ tcol = 3, trow = 2, img = resource.getImage( FOLDER.ASSETS.."pic_midright.png", false ), obj = level:createEntity("ImagePart") },
			{ tcol = 2, trow = 2, img = resource.getImage( FOLDER.ASSETS.."pic_midmid.png", false ), obj = level:createEntity("ImagePart") }
			
		}
		
	}
	
	for row, rowtab in ipairs( self._field ) do
		for col, part in ipairs( rowtab ) do
			if not part.empty then
				local x = (col-1) * self._partsize
				local y = (row-1) * self._partsize
				part.obj:setPos(x, y)
			end
		end
	end
	
	self._fieldx, self._fieldy = 351, 186
	
end

function Puzzle4:update( dt )
	
	Puzzle.update( self, dt )
	
	if (self._completed) then return end
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local clicked = false
	
	if not game.getDisplay():isPaused() then
	
		clicked = input:mouseIsPressed("l")
		self._blinktime = self._blinktime + dt*2
		
		local swx, swy, swtx, swty
		local swap = false
		local ix, iy = px + self._fieldx, py + self._fieldy
		
		local function checkFree( fieldt, x, y )
			if fieldt[y] and fieldt[y][x] and fieldt[y][x].empty then 
				return true, x, y
			end
			return false
		end
		
		for row, rowtab in ipairs( self._field ) do
			for col, part in ipairs( rowtab ) do
				if not part.empty then
					local tx, ty = part.obj:getPos()
					-- check if mouse hovering over this part
					if (mx >= ix+tx and mx < ix+tx+self._partsize and my >= iy+ty and my < iy+ty+self._partsize) then
						part.hover = true
						
						if (clicked) then
							-- check if we have a free space to move to
							swap, swtx, swty = checkFree(self._field, col, row-1)
							if not swap then swap, swtx, swty = checkFree(self._field, col, row+1) end
							if not swap then swap, swtx, swty = checkFree(self._field, col-1, row) end
							if not swap then swap, swtx, swty = checkFree(self._field, col+1, row) end
							
							if (swap) then
								swx = col
								swy = row
								break
							end
						end	
					else
						part.hover = false
					end
				end
			end
			if (swap) then break end
		end
		
		-- swap image parts
		if (swap) then
		
			playWav(self._snd_shift, 0.2)
			
			local part = self._field[swy][swx]
			self._field[swty][swtx] = part
			self._field[swy][swx] = { empty = true }
			local x = (swtx-1) * self._partsize
			local y = (swty-1) * self._partsize
			part.obj:goto(x, y)
			
			local succ = true
			
			-- check if we completed the puzzle
			for row, rowtab in ipairs( self._field ) do
				for col, part in ipairs( rowtab ) do
					if not part.empty then
						if part.trow ~= row or part.tcol ~= col then
							succ = false
						end
					end
				end
			end
			
			if (succ) then
				print("Completed puzzle 4")
				game.puzzleCompleted()
				self._completed = true
			end
			
		end		
		
	end
		
end

function Puzzle4:draw()
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local setColor = love.graphics.setColor
	local draw = love.graphics.draw
	
	-- draw puzzle
	draw(self._image, px, py)
	
	-- draw images
	local ix, iy = px + self._fieldx, py + self._fieldy
	for row, rowtab in ipairs( self._field ) do
		for col, part in ipairs( rowtab ) do
			if not part.empty then
				local tx, ty = part.obj:getPos()
				if (part.hover) then setColor(200,200,200,255)
				else setColor(255,255,255,255) end
				draw(part.img, ix+tx, iy+ty)
			end
		end
	end
	
	-- draw blinking light
	if ((math.floor(self._blinktime % 2) == 0 or self._explode) and not self._completed) then
		draw(self._blink, px+251, py+148)
	end
	
end

function Puzzle4:pointer()
	
	return "default"
	
end

-- image part
ImagePart = class("ImagePart", Entity)

function ImagePart:initialize()
	Entity.initialize(self)

	self._easingstartpos = Vector(0,0)
	self._targetpos = Vector(0,0)
	self._easingstart = 0
	self._duration = 0.1
end

function ImagePart:update( dt )
	local t = engine.currentTime() - self._easingstart
	if (t < self._duration) then
		self._pos.x = easing.inQuart(t, self._easingstartpos.x, self._targetpos.x-self._easingstartpos.x, self._duration)
		self._pos.y = easing.inQuart(t, self._easingstartpos.y, self._targetpos.y-self._easingstartpos.y, self._duration)
	else
		self._pos.x = self._targetpos.x
		self._pos.y = self._targetpos.y
	end
end

function ImagePart:goto( x, y )
	self._targetpos.x = x
	self._targetpos.y = y
	self._easingstartpos.x = self._pos.x
	self._easingstartpos.y = self._pos.y
	self._easingstart = engine.currentTime()
end

function ImagePart:setPos( x, y )
	Entity.setPos(self, x, y)
	self._targetpos.x = x
	self._targetpos.y = y
	self._easingstartpos.x = x
	self._easingstartpos.y = y
	self._easingstart = 0
end





