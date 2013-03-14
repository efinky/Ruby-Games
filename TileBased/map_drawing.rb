require 'rubygems'
require 'gosu'


class Character
	attr_reader :x, :y
	def initialize (window, x, y)
		@x = x
		@y = y
		#face = current way walking
		@face = Hash["n",0,"e",1,"s",2,"w",3]
		@current_face = "n"
		@images = []  #add all four directional images
		@images[0] = Gosu::Image.new(window, "warrior.base.111.png", true)
		@images[1] = Gosu::Image.new(window, "warrior.base.131.png", true)
		@images[2] = Gosu::Image.new(window, "warrior.base.151.png", true)
		@images[3] = Gosu::Image.new(window, "warrior.base.171.png", true)
	end
	
	def move_up(move)
		if (@y > 0) and move == true
			@y = @y - 32
		end
		@current_face = "n"
	end
	def move_down(move)
		if (@y < 448) and move == true
			@y = @y + 32
		end
		@current_face = "s"
	end
	def move_left(move)
		if (@x > 0) and move == true
			@x = @x - 32
		end
		@current_face = "w"
	end
	def move_right(move)
		if (@x < 608) and move == true
			@x = @x + 32
		end
		@current_face = "e"
	end
	
	def move_upL(move)
		if (@y > 0) and (@x > 0) and move == true
			@y = @y - 32
			@x = @x - 32
		end
		@current_face = "w"
	end
	def move_upR(move)
		if (@y > 0) and (@x < 608) and move == true
			@y = @y - 32
			@x = @x + 32
		end
		@current_face = "e"
	end
	def move_downL(move)
		if (@y < 448) and (@x > 0) and move == true
			@y = @y + 32
			@x = @x - 32
		end
		@current_face = "w"
	end
	def move_downR(move)
		if (@y < 448) and (@x < 608) and move == true
			@y = @y + 32
			@x = @x + 32
		end
		@current_face = "e"
	end
	
	def draw
		@images[@face[@current_face]].draw(@x, @y, 1)
	end


end

class Map
	attr_reader :tiles
	def initialize(window, width, height)
		@tileTypes = ["woods.png", "grass.png", "grass.png"]
		@tiles = []
		tempRow = []
		height.times do
			tempRow = []
			width.times do
				tempRow.push Tile.new(window, @tileTypes[rand*2])	
			end
			@tiles.push tempRow
		end
	end
	
	def draw
		@tiles.each do |row|
			row.each do |tile|
				tile.image.draw(@tiles.index(row) *32, row.index(tile)*32, 0)
			end
		end
	end
end

class Tile
	attr_reader :name, :image
	def initialize (window, name)
		@name = name
		@image = Gosu::Image.new(window, @name, true)
	end
end

class MyWindow < Gosu::Window
	def initialize
		super(640, 480, false)
		self.caption = ("Look its a map!")
		@pause = Time.new
		@map = Map.new(self, 15, 20)
		x = 1
		y = 1
		#puts player on grass
		if isForest?(x,y)
			[0,2].each do |x1|
				[0,2].each do |y1|
					if !isForest?(x1, y1)
						x = x1
						y = y1
						break
					end
				end
			end		
		end
		@player = Character.new(self, x*32, y*32)
		
	end
	
	def isForest? (x, y)
		@map.tiles[x][y].name == "woods.png"
	end
	
	def validMove?(x1, y1)
		x = x1/32
		y = y1/32
		
		return !isForest?(x, y)
	end
	
	def update
		#makes it so the character only moves every .1 seconds at most
		newTime = Time.new
		if button_down?(Gosu::KbDown) or button_down?(Gosu::KbNumpad2)
			if (@pause <= newTime) 
				if validMove?(@player.x, @player.y + 32)
					@player.move_down(true)
				else
					@player.move_down(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbUp) or button_down?(Gosu::KbNumpad8)
			if (@pause <= newTime)
				if validMove?(@player.x, @player.y - 32)
					@player.move_up(true)
				else
					@player.move_up(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbLeft) or button_down?(Gosu::KbNumpad4)
			if (@pause <= newTime)
				if validMove?(@player.x - 32, @player.y)
					@player.move_left(true)
				else
					@player.move_left(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbRight) or button_down?(Gosu::KbNumpad6)
			if (@pause <= newTime)
				if validMove?(@player.x + 32, @player.y)
					@player.move_right(true)
				else
					@player.move_right(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbNumpad7)
			if (@pause <= newTime)
				if validMove?(@player.x - 32, @player.y - 32)
					@player.move_upL(true)
				else
					@player.move_upL(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbNumpad9)
			if (@pause <= newTime)
				if validMove?(@player.x + 32, @player.y - 32)
					@player.move_upR(true)
				else
					@player.move_upR(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbNumpad1)
			if (@pause <= newTime)
				if validMove?(@player.x - 32, @player.y + 32)
					@player.move_downL(true)
				else
					@player.move_downL(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbNumpad3)
			if (@pause <= newTime)
				if validMove?(@player.x + 32, @player.y + 32)
					@player.move_downR(true)
				else
					@player.move_downR(false)
				end
				@pause = newTime + 0.1
			end
		elsif button_down?(Gosu::KbEscape) or button_down?(Gosu::KbSpace)
			self.close
		end
	
	end
	
	

	def draw
		@player.draw
		@map.draw
	end
end

MyWindow.new.show