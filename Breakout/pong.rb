require 'rubygems'
require 'gosu'
class Ball
	attr_reader :x, :y, :w, :h
	def initialize(window)
		@x = 200
		@y = 200
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
		@vx = rand*10 - 5
		@vy = rand*3 - 6
	end
	def stop
		@x = 20 + rand*780
		@y = 200 + rand*20
		@vx = 0
		@vy = 0
	end
	
end

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

class Brick
	attr_reader :x, :y, :w, :h
	def initialize(window, x, y)
		@x = x
		@y = y
		@w = 60
		@h = 20
		@image = Gosu::Image.new(window, "brick.png", false)
	end

	def draw
		@image.draw(@x, @y, 1)
	end

end


class GameWindow < Gosu::Window

	def initialize
		super 800, 600, false
		self.caption = ("Breakout")
		@ball = Ball.new(self)
		@paddle = Paddle.new(self)
		@lives = []
		(0..1).each do |d|
			@lives.push Life.new(self, d*25+5, 5)
		end
		@bricks = []
		(2..6).each do |rows|
			(0..8).each do |col|
				@bricks.push Brick.new(self, col * 80+40, rows * 30)
			end
		end
		@gameover = Gosu::Image.new(self, "gameover.png", false)
		@num_lives = 3
	end
	
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
		if button_down?(Gosu::KbSpace)
			@ball.start
		end
		if button_down?(Gosu::KbEscape)
			self.close
		end
		@bricks.each do |brick|
			if are_touching?(@ball, brick)
				@ball.reverse_y
				@bricks.delete brick
			end
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
		if @num_lives == 0
			@gameover.draw(200, 200, 2)
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
		