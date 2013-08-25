
Puzzle3 = class("Puzzle3",Puzzle)

function Puzzle3:initialize()

	Puzzle.initialize(self)
	
	self._image = resource.getImage( FOLDER.ASSETS.."puzzle3.png", false )
	self._blink = resource.getImage( FOLDER.ASSETS.."armed_light.png", false )
	self._blinktime = 0
	
	self._keypadbtn = Sprite( SpriteData(FOLDER.ASSETS.."keypad_buttons.png", Vector(0,0), Vector(34,34), Vector(0, 0), 2, 2, 0, false ) )
	self._keypadnum = Sprite( SpriteData(FOLDER.ASSETS.."keypad_numbers.png", Vector(0,0), Vector(34, 34), Vector(0, 0), 11, 11, 0, false ) )
	
	self._snd_buttonselect = resource.getSound(FOLDER.ASSETS.."sound/button_select.wav","static")
	self._snd_buttonbad = resource.getSound(FOLDER.ASSETS.."sound/button_bad.wav","static")
	
	self._kpadx, self._kpady = 393, 236
	self._lcdx, self._lcdy = 362, 196
	
	self._entered = { -1, -1, -1, -1 }
	self._answer = { 0, 8, 6, 1 }
	self._font = love.graphics.newFont( 24 )
	self._enterpointer = 1
	
	self._buttons = {
		{ enter = 1, numframe = 3, x = self._kpadx, y = self._kpady },
		{ enter = 2, numframe = 4, x = self._kpadx+35, y = self._kpady },
		{ enter = 3, numframe = 5, x = self._kpadx+70, y = self._kpady },
		{ enter = 4, numframe = 6, x = self._kpadx, y = self._kpady+35 },
		{ enter = 5, numframe = 7, x = self._kpadx+35, y = self._kpady+35 },
		{ enter = 6, numframe = 8, x = self._kpadx+70, y = self._kpady+35 },
		{ enter = 7, numframe = 9, x = self._kpadx, y = self._kpady+70 },
		{ enter = 8, numframe = 10, x = self._kpadx+35, y = self._kpady+70 },
		{ enter = 9, numframe = 11, x = self._kpadx+70, y = self._kpady+70 },
		{ enter = -1, numframe = 1, x = self._kpadx, y = self._kpady+105 },
		{ enter = 0, numframe = 2, x = self._kpadx+35, y = self._kpady+105 },
		{ enter = -10, numframe = -1, x = self._kpadx+70, y = self._kpady+105 }
	}
	
end

function Puzzle3:update( dt )
	
	Puzzle.update( self, dt )
	
	if (self._completed) then return end
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local clicked = false
	
	if not game.getDisplay():isPaused() then
	
		clicked = input:mouseIsPressed("l")
		self._blinktime = self._blinktime + dt*2
		
		if (mx >= px+self._kpadx and mx < px+self._kpadx+105 and
			my >= py+self._kpady and my < py+self._kpady+140) then
			
			if (clicked) then
				for k, v in ipairs( self._buttons ) do
					local btn = v
					if (mx >= px+btn.x and mx < px+btn.x+35 and my >= py+btn.y and my < py+btn.y+35 and btn.enter ~= -10) then
					
						btn.pressed = true
						timer.simple(0.2, function() btn.pressed = false end)
						
						if (btn.enter == -1) then -- reset
							for i, j in ipairs( self._entered ) do self._entered[i] = -1 end
							self._enterpointer = 1
							playWav(self._snd_buttonselect, 0.3)
						elseif (self._enterpointer <= #self._entered) then
							self._entered[self._enterpointer] = btn.enter
							self._enterpointer = self._enterpointer + 1
							
							if (self._enterpointer > #self._entered) then
								local succ = true
								for i, j in ipairs( self._entered ) do
									if (j ~= self._answer[i]) then succ = false end
								end
								
								if (succ) then
									print("Completed puzzle 3")
									game.puzzleCompleted()
									self._completed = true
								else
									playWav(self._snd_buttonbad, 0.3)
								end
							else
								playWav(self._snd_buttonselect, 0.3)
							end
						else
							playWav(self._snd_buttonbad, 0.3)
						end
					end
					
				end
			end
			
		end
	
	end
		
end

function Puzzle3:draw()
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local setColor = love.graphics.setColor
	local draw = love.graphics.draw
	
	-- draw puzzle
	draw(self._image, px, py)
	
	-- draw keypad
	for k, btn in ipairs( self._buttons ) do
		
		local bx, by = px + btn.x, py + btn.y
		
		setColor(255,255,255,255)
		if (btn.pressed) then
			self._keypadbtn:setCurrentFrame(2)
			self._keypadbtn:draw(bx, by)
			setColor(255,255,255,200)
		else
			self._keypadbtn:setCurrentFrame(1)
			self._keypadbtn:draw(bx, by)
		end
		
		if (btn.numframe > 0) then
			self._keypadnum:setCurrentFrame(btn.numframe)
			self._keypadnum:draw(bx, by)
		end
		
	end	
	
	-- draw lcd
	local lx, ly = 0, self._lcdy
	
	setColor(0,255,0,200)
	love.graphics.setFont(self._font)
	for k, v in ipairs( self._entered ) do
		lx = self._lcdx + (k-1) * 20
		if (v == -1) then
			love.graphics.printf( ".", px+lx, py+ly, 100, "center" )
		else
			love.graphics.printf( tostring(v), px+lx, py+ly, 100, "center" )
		end
	end
	setColor(255,255,255,255)
	
	-- draw blinking light
	if ((math.floor(self._blinktime % 2) == 0 or self._explode) and not self._completed) then
		draw(self._blink, px+251, py+148)
	end
	
end

function Puzzle3:pointer()
	
	return "default"
	
end
