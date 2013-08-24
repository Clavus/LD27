
Puzzle1 = class("Puzzle1",Puzzle)

function Puzzle1:initialize()

	Puzzle.initialize(self)
	
	self._image = resource.getImage( FOLDER.ASSETS.."puzzle1.png", false )
	self._blink = resource.getImage( FOLDER.ASSETS.."armed_light.png", false )
	self._blinktime = 0
	
	self._wires = {
		{ default = resource.getImage( FOLDER.ASSETS.."wire_red.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_red_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_blue.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_blue_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_green.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_green_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_orange.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_orange_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_purple.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_purple_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_pink.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_pink_cut.png", false ) },
		{ default = resource.getImage( FOLDER.ASSETS.."wire_brown.png", false ),
		cut = resource.getImage( FOLDER.ASSETS.."wire_brown_cut.png", false ) }
	}
	
	
end

function Puzzle1:update( dt )
	
	Puzzle.update( self, dt )
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local clicked = false
	
	if not game.getDisplay():isPaused() then
	
		clicked = input:mouseIsPressed("l")
		self._blinktime = self._blinktime + dt*2
		
		for k, wire in pairs(self._wires) do
			local tx = px+238+56*(k-1)+5
			if (my > py+103 and my < py+223 and mx > tx and mx < tx+46) then
				wire.hover = true
				if (clicked) then
					wire.iscut = true
					if (k == 4) then -- orange
						print("Completed puzzle 1")
						self._completed = true
						game.puzzleCompleted()
					else
						self._explode = true
						game.explode()
					end
				end
			else
				wire.hover = false
			end
		end
	
	end
		
end

function Puzzle1:draw()
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local setColor = love.graphics.setColor
	local draw = love.graphics.draw
	
	-- draw wires
	for k, wire in pairs(self._wires) do
		local graphic = wire.default
		if (wire.iscut) then
			graphic = wire.cut
		elseif (wire.hover) then
			setColor(255,255,255,150)
		end
		
		draw(graphic, px+238+56*(k-1), py+103)
		setColor(255,255,255,255)
		
	end
	
	-- draw puzzle
	draw(self._image, px, py)
	
	-- draw blinking light
	if ((math.floor(self._blinktime % 2) == 0 or self._explode) and not self._completed) then
		draw(self._blink, px+251, py+243)
	end
	
end

function Puzzle1:pointer()
	
	return "cutter"
	
end
