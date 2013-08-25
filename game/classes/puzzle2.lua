
Puzzle2 = class("Puzzle2",Puzzle)

function Puzzle2:initialize()

	Puzzle.initialize(self)
	
	self._image = resource.getImage( FOLDER.ASSETS.."puzzle2.png", false )
	self._blink = resource.getImage( FOLDER.ASSETS.."armed_light.png", false )
	self._blinktime = 0
	
	self._snd_select = resource.getSound(FOLDER.ASSETS.."sound/mswp_select.wav","static")
	self._snd_mark = resource.getSound(FOLDER.ASSETS.."sound/mswp_mark.wav","static")
	
	self._tile_img = resource.getImage( FOLDER.ASSETS.."minesweeper_tile.png", false )
	self._mark_img = resource.getImage( FOLDER.ASSETS.."mark.png", false )
	self._mine_img = resource.getImage( FOLDER.ASSETS.."mine.png", false )
	self._smiley = Sprite( SpriteData(FOLDER.ASSETS.."smileys.png", Vector(0,0), Vector(32, 32), Vector(16, 16), 4, 4, 0, false ) )
	self._number = Sprite( SpriteData(FOLDER.ASSETS.."minesweeper_numbers.png", Vector(0,0), Vector(20, 20), Vector(10, 10), 4, 4, 0, false ) )
	
	self._wtiles = 11
	self._htiles = 7
	self._tilesize = 20
	self._tiles = {}
	
	self._bombcounter = 0
	self._maxbombs = 7
	self._marks = 0
	
	-- construct the tiles
	for row = 1, self._htiles do
		local row_tiles = {}
		for col = 1, self._wtiles do
			table.insert(row_tiles, { px = (col-1)*self._tilesize, py = (row-1)*self._tilesize, primed = false, selected = false, marked = false, bomb = false })
		end
		table.insert(self._tiles, row_tiles)
	end
	
	-- define bomb locations (amount should equal self._maxbombs)
	self._tiles[3][3].bomb = true
	self._tiles[3][4].bomb = true
	self._tiles[4][5].bomb = true
	self._tiles[5][5].bomb = true
	self._tiles[6][5].bomb = true
	
	self._tiles[4][6].bomb = true
	self._tiles[2][6].bomb = true
	
	-- count the number of adjacent bombs and store this info in the tiles
	for row, tab in ipairs( self._tiles ) do
		for col, tile in ipairs( tab ) do
		
			tile.number = 0
			if not tile.bomb then
				local adj_bombs = 0
				if (row-1 > 0) then
					if (col-1 > 0 and self._tiles[row-1][col-1].bomb) then adj_bombs = adj_bombs + 1 end
					if (col+1 <= self._wtiles and self._tiles[row-1][col+1].bomb) then adj_bombs = adj_bombs + 1 end
					if (self._tiles[row-1][col].bomb) then adj_bombs = adj_bombs + 1 end
				end
				if (row+1 <= self._htiles) then
					if (col-1 > 0 and self._tiles[row+1][col-1].bomb) then adj_bombs = adj_bombs + 1 end
					if (col+1 <= self._wtiles and self._tiles[row+1][col+1].bomb) then adj_bombs = adj_bombs + 1 end
					if (self._tiles[row+1][col].bomb) then adj_bombs = adj_bombs + 1 end
				end
				if (col-1 > 0 and self._tiles[row][col-1].bomb) then adj_bombs = adj_bombs + 1 end
				if (col+1 <= self._wtiles and self._tiles[row][col+1].bomb) then adj_bombs = adj_bombs + 1 end
				
				tile.number = adj_bombs
			end
			
		end
	end	
	
end

function Puzzle2:update( dt )
	
	Puzzle.update( self, dt )
	
	local px, py = self:getPos()
	self._fieldx = px + 340
	self._fieldy = py + 220
	
	if (self._completed) then return end
	
	local mx, my = love.mouse.getPosition()
	local mldown = false
	local mlreleased = false
	local mrclicked = false
	
	if not game.getDisplay():isPaused() then
	
		mlreleased = input:mouseIsReleased("l")
		mldown = input:mouseIsDown("l")
		mrclicked = input:mouseIsPressed("r")
		self._blinktime = self._blinktime + dt*2
		
	end
	
	local has_primed = false
	-- check what tiles we're pressing
	--if (mx > self._fieldx and mx < self._fieldx+self._tilesize*self._wtiles) and
	--	(my > self._fieldy and my < self._fieldy+self._tilesize*self._htiles) then
		
	for row, tab in ipairs( self._tiles ) do
		for col, tile in ipairs( tab ) do
			
			if (mx > self._fieldx+tile.px and mx < self._fieldx+tile.px+self._tilesize) and
				(my > self._fieldy+tile.py and my < self._fieldy+tile.py+self._tilesize) then
				
				if not (tile.selected) then -- not selected
					if not tile.marked then -- not marked
						
						if (mlreleased) then -- selecting tile
							tile.primed = false
							tile.selected = true
							if (tile.bomb) then
								self._smiley:setCurrentFrame(4)
								self._explode = true
								game.explode()
							else
								playWav( self._snd_select, 0.25 )
								self:propagateSelection(row, col)
							end
						elseif (mldown) then -- primed
							tile.primed = true
						end
						
					end
					
					if (mrclicked and not tile.primed) then
						-- toggle mark
						playWav( self._snd_mark, 0.25 )
						if (tile.marked) then
							tile.marked = false
							self._marks = self._marks - 1
							if (tile.bomb) then self._bombcounter = self._bombcounter - 1 end
						else
							tile.marked = true
							self._marks = self._marks + 1
							if (tile.bomb) then self._bombcounter = self._bombcounter + 1 end
						end
						if (self._bombcounter == self._maxbombs and self._marks == self._maxbombs) then
							print("Completed puzzle 2")
							self._completed = true
							self._smiley:setCurrentFrame(3)
							game.puzzleCompleted()
						end
					end
					
					if (tile.primed) then
						has_primed = true
					end
					
				end
			else
				tile.primed = false
			end
			
		end
	end
	
	if not self._completed and not self._explode then
		if has_primed then
			self._smiley:setCurrentFrame(2)
		else
			self._smiley:setCurrentFrame(1)
		end
	end
	
end

local valid = function( tile )
	return tile ~= nil and not tile.selected and not tile.bomb
end
local select = function( tile, r, c, pz )
	tile.selected = true
	tile.primed = false
	if (tile.number == 0) then
		pz:propagateSelection(r, c)
	end
end
	
function Puzzle2:propagateSelection(row, col)

	local tile
	-- man minesweeper is harder than it looks
	if (row-1 > 0) then
		if (col-1 > 0) then
			tile = self._tiles[row-1][col-1]
			if valid(tile) then select(tile, row-1, col-1, self) end
		end	
		if (col+1 <= self._wtiles) then
			tile = self._tiles[row-1][col+1]
			if valid(tile) then select(tile, row-1, col+1, self) end
		end
		tile = self._tiles[row-1][col]
		if valid(tile) then select(tile, row-1, col, self) end
	end
	if (row+1 <= self._htiles) then
		if (col-1 > 0) then
			tile = self._tiles[row+1][col-1]
			if valid(tile) then select(tile, row+1, col-1, self) end
		end	
		if (col+1 <= self._wtiles) then
			tile = self._tiles[row+1][col+1]
			if valid(tile) then select(tile, row+1, col+1, self) end
		end
		tile = self._tiles[row+1][col]
		if valid(tile) then select(tile, row+1, col, self) end
	end
	if (col-1 > 0) then
		tile = self._tiles[row][col-1]
		if valid(tile) then select(tile, row, col-1, self) end
	end	
	if (col+1 <= self._wtiles) then
		tile = self._tiles[row][col+1]
		if valid(tile) then select(tile, row, col+1, self) end
	end

end

function Puzzle2:draw()
	
	local px, py = self:getPos()
	local mx, my = love.mouse.getPosition()
	local setColor = love.graphics.setColor
	local draw = love.graphics.draw
	
	-- draw puzzle
	draw(self._image, px, py)
	
	-- draw tiles
	for row, tab in ipairs( self._tiles ) do
		for col, tile in ipairs( tab ) do
			setColor(255,255,255,255)
			local tx, ty = self._fieldx+tile.px, self._fieldy+tile.py
			if not tile.primed and not tile.selected then
				draw(self._tile_img, tx, ty)
				
				if (tile.marked) then
					draw(self._mark_img, tx, ty)
				end
			end
			
			if (tile.bomb and tile.selected) then
				setColor(255,0,0,200)
				love.graphics.rectangle("fill",tx,ty,self._tilesize,self._tilesize)
				setColor(255,255,255,255)
				draw(self._mine_img, tx, ty)
			elseif (tile.selected and tile.number > 0) then
				self._number:setCurrentFrame(math.min(4,tile.number))
				self._number:draw(tx+self._tilesize/2, ty+self._tilesize/2)
			end
			
		end
	end
	
	setColor(255,255,255,255)
	self._smiley:draw(px + 450, py + 202)
	
	-- draw blinking light
	if ((math.floor(self._blinktime % 2) == 0 or self._explode) and not self._completed) then
		draw(self._blink, px+251, py+148)
	end
	
end

function Puzzle2:pointer()
	
	return "default"
	
end
