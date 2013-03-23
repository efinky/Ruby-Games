require 'rubygems'
require 'gosu'

#
#   Ball Class
#
class Ball
	attr_reader :x, :y, :w, :h
	def initialize(window)
		@x = 200
		@y = 240
		@vx = 0
		@vy = 0
		@w = 20
		@h = 20
		@image = Gosu::Image.new(window, "ball.png", false)
	end
	
	def move
		@x = @x + @vx
		@y = @y + @vy
		if (@x < 0)
			@vx = 5
		end
		if (@x > 780)
			@vx = -5
		end
		if @y < 0
			@vy = 5
		end
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end
	
	def reverse_y
		@vy = -1 * @vy
	end
	
	def start 
		seed = [-1, 1]
		#creates number between 4 and 8 or -4 ad -8
		@vx = 5 * seed[rand*2]
		#makes sure the ball speed is constant (combined valocity of 10)
		@vy = -5
	end
	def stop
		@x = 20 + rand*780
		@y = 200 + rand*20
		@vx = 0
		@vy = 0
	end
	
end
# ^ Ball
#
#   Life Class
#
class Life
	def initialize(window, x, y)
		@x = x
		@y = y
		@image = Gosu::Image.new(window, "ball.png", false)
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end

end
# ^ Life
#
#   Paddle Class
#
class Paddle
	attr_reader :x, :y, :w, :h
	def initialize(window)
		@x = 200
		@y = 550
		@w = 80
		@h = 15
		@image = Gosu::Image.new(window, "paddle.png", false)
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end
	
	def move_left
		if (@x > 0)
			@x = @x - 7
		end
	end
	def move_right
		if @x < 720
			@x = @x + 7
		end
	end
	
	
end
# ^ Paddle
#
#   Brick Class
#
class Brick
	attr_reader :x, :y, :w, :h, :color
	def initialize(window, x, y, color)
		@x = x
		@y = y
		@w = 60
		@h = 20
		@color = color
		#used for green bricks only
		@hits = 0
		@image = Gosu::Image.new(window, "#{@color}_brick.png", false)
	end
	
	def destroy
		if @color == "green"
			@hits += 1
			if @hits == 2
				return true
			else
				return false
			end
		elsif @color == "red"
			return true
		elsif @color == "blue"
			return false
		end
	end

	def draw
		@image.draw(@x, @y, 1)
	end

end
# ^ Brick
#
#   Main Class
#
class GameWindow < Gosu::Window

	def initialize
		super 800, 600, false
		self.caption = ("Breakout")
		#stuff that displays
		@ball = Ball.new(self)
		@paddle = Paddle.new(self)
		@lives = []
		@colors = []
		@bricks = []
		@gameover = Gosu::Image.new(self, "gameover.png", false)
		@level_text = Gosu::Font.new(self, 'courier', 25)
		@rules_text = Gosu::Font.new(self, 'courier', 25)
		@game_win = Gosu::Image.new(self, "win.png", false)

		@num_lives = 3
		@win = false
		@first_time = true
		@level = 1
		#used to display text for short duration
		@repeat = true
		start

		
	end
	#collision detection
	def are_touching?(obj1, obj2)
		if obj1.x > obj2.x - obj1.w and obj1.x < obj2.x + obj2.w and obj1.y > obj2.y - obj1.h and obj1.y < obj2.y + obj2.h
			return true
		else
			return false
		end
	end
	
	def death?
		if @ball.y > 600
			@ball.stop
			return true
		else
			return false
		end
	end
	
	def start
		#creates the lives to be displayed
		(0..1).each do |d|
			@lives.push Life.new(self, d*25+5, 5)
		end
		#creates list of colors to randomly draw from
		#level 1 all red
		#level 2 5 green
		#level 3 15 green
		#level 4 3 blue and 15 green
		#for level 4
		@bricks.clear
		@colors.clear
		num_green = 0
		num_blue = 0
		#initializing colors depending on level
		if @level == 2
			20.times do @colors.push "red" end
			5.times do @colors.push "green" end
		end
		if @level >= 3
			5.times do @colors.push "red" end
			5.times do @colors.push "green" end
		end
		if @level == 4
			2.times do @colors.push "blue" end
		end
		length = @colors.length
		
		#creates the two rows of bricks
		(2..6).each do |rows|
			(0..8).each do |col|
			
				if @level == 4 
					color = @colors[rand*length]
					if color == "blue" 
						num_blue+=1
						if num_blue > 3
							color = "green"
						end
					end
					if color == "green" 
						num_green+=1
						if num_green > 15
							color = "red"
						end
					end
				elsif @level == 3
					color = @colors[rand*length]
					if color == "green" 
						num_green+=1
						if num_green > 15
							color = "red"
						end
					end
				elsif @level == 2
					color = @colors[rand*length]
					if color == "green" 
						num_green+=1
						if num_green > 5
							color = "red"
						end	
					end
				else
					color = "red"
				end
				@bricks.push Brick.new(self, col * 80+40, rows * 30, color)
			end
		end
	
	end
	
	#handles movement, collision and win conditions
	def update
		if button_down?(Gosu::KbLeft)
			@paddle.move_left
		end
		if button_down?(Gosu::KbRight)
			@paddle.move_right
		end
		@ball.move
		if are_touching?(@ball, @paddle)
			@ball.reverse_y
		end
		if button_down?(Gosu::KbSpace) #and @first_time
			@first_time = false
			@ball.start
		end
		if button_down?(Gosu::KbEscape)
			self.close
		end
		@win = true
		#collsion detection... bugs everyonce in a while... not sure why...
		@bricks.each do |brick|
			#if one of these color of bricks is left then we still haven't won
			if brick.color == "red" or brick.color == "green"
				@win = false
			end
			if are_touching?(@ball, brick)
				@ball.reverse_y
				if brick.destroy
					@bricks.delete brick
				end
			end
		end
		if @win
			@ball.stop
		end
		
		if @num_lives == 0 
			if button_down?(Gosu::KbSpace)
				self.close
			end
		end
		if death?
			@num_lives -= 1
			@lives.pop
		end
	end
	
	def draw
		
		@paddle.draw
		@bricks.each do |brick|
			brick.draw
		end
		if @first_time
			@level_text.draw("Level 1", 250, 200, 2)
			@rules_text.draw("Red Bricks: 1 hit", 250, 230, 2)
		end
		if @num_lives == 0 
			@gameover.draw(200, 200, 2)
		elsif @win
			#if you beaten the final level
			if @level == 4
				@game_win.draw(200, 200, 2)
			else
				if @repeat
					@level_text.draw("Level #{@level + 1}", 250, 200, 2)
					#for levels 2 or 3 (@level has not been incremented yet)
					if @level == 1 or @level == 2
						@rules_text.draw("Red Bricks: 1 hit, Green Bricks: 2 hits", 200, 230, 2)
					#for level 4 (@level has not been incremented yet)
					elsif @level == 3
						@rules_text.draw("Red Bricks: 1 hit, Green Bricks: 2 hits, Blue Bricks: Invulnerable", 200, 230, 2)
					end
					@repeat = false
				else
					@level += 1
					sleep(2)
					start
					@win = false
					@repeat = true
				end
			end
		else
			@ball.draw
		end
		@lives.each do |life|
			life.draw
		end
	end
	
end


window = GameWindow.new
window.show
		