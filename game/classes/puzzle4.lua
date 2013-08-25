
Puzzle4 = class("Puzzle4",Puzzle)

function Puzzle4:initialize()

	Puzzle.initialize(self)
	
	self._image = resource.getImage( FOLDER.ASSETS.."puzzle3.png", false )
	self._blink = resource.getImage( FOLDER.ASSETS.."armed_light.png", false )
	self._blinktime = 0
	
	self._keypadbtn = Sprite( SpriteData(FOLDER.ASSETS.."keypad_buttons.png", Vector(0,0), Vector(34,34), Vector(0, 0), 2, 2, 0, false ) )
	self._keypadnum = Sprite( SpriteData(FOLDER.ASSETS.."keypad_numbers.png", Vector(0,0), Vector(34, 34), Vector(0, 0), 11, 11, 0, false ) )
	
	self._snd_buttonselect = resource.getSound(FOLDER.ASSETS.."sound/button_select.wav","static")
	self._snd_buttonbad = resource.getSound(FOLDER.ASSETS.."sound/button_bad.wav","static")
	
end

function Puzzle4:update( dt )
	
	if (self._completed) then return end
	
	Puzzle.update( self, dt )
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local clicked = false
	
	if not game.getDisplay():isPaused() then
	
		clicked = input:mouseIsPressed("l")
		self._blinktime = self._blinktime + dt*2
		
	
	end
		
end

function Puzzle4:draw()
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local setColor = love.graphics.setColor
	local draw = love.graphics.draw
	
	-- draw puzzle
	draw(self._image, px, py)
	
	-- draw blinking light
	if ((math.floor(self._blinktime % 2) == 0 or self._explode) and not self._completed) then
		draw(self._blink, px+251, py+148)
	end
	
end

function Puzzle4:pointer()
	
	return "default"
	
end
