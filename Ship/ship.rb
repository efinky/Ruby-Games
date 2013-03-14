#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'

$Height = 800
$Width = 640
#640, 480,

#
#	PowerUp Class
#
class PowerUp
	attr_reader :x, :y, :w, :h, :name
	def initialize(window)
		@x = rand*($Width - 40)
		@y = 0
		@w = 40
		@h = 40
		@images = ["laser_powerup.png", "shield.png"]
		@name = @images[rand*2]
		@image = Gosu::Image.new(window, @name, false)
	end
	
	def exists?
		@y < $Height
	end
	
	def pause(p)
		@pause = p
	end
	
	def draw
		@image.draw(@x, @y, 1)
		if !@pause
			@y = @y + 3
		end
	end

end
#
#	Asteroid Class
#
class Asteroid
	attr_reader :x, :y, :w, :h, :name
	def initialize(window)
		@x = rand*($Width - 40)
		@y = 0
		@vy = 1
		@w = 40
		@h = 40
		@images = ['asteroid.png', 'asteroid.png', 'asteroid.png', 'asteroid.png', 'smiles.png', 'smiles.png', 'pink.png', 'red.png']
		@name = @images[rand*8]
		@image = Gosu::Image.new(window, @name, false)
		
		@pause = false
	end
	
	def exists?
		@y < $Height
	end
	
	def pause(p)
		@pause = p
	end
	
	def draw #(level)
		@image.draw(@x, @y, 1)
		if !@pause
			if @name == "smiles.png"# and level >= 2
				@y = @y + 4
			elsif @name == "pink.png"# and level >= 3
				@y = @y + 4
				if @x > $Width - 40
					@x = @x - 4
				elsif @x < 0
					@x = @x + 4
				else
					@x = @x + rand*8 - rand*6
				end
			elsif @name == "red.png"
				@y = @y + @vy
				@vy += 0.1
			else
				@y = @y + 2
			end
		end
	end
end
#
#	Laser Class
#
class Laser
	attr_reader :x, :y, :w, :h
	def initialize(window, x, y, powerup=false)
		@x = x + 17
		@y = y - 7
		@w = 4
		@h = 15
		@image = Gosu::Image.new(window, 'laser.png', false)
		@image_powerup = Gosu::Image.new(window, 'blue_laser.png', false)
		@powerup = powerup
		@pause = false
	end
	
	def exists?
		@y > 0
	end
	
	def pause(p)
		@pause = p
	end
		
	def draw
		if @powerup
			@image_powerup.draw(@x, @y, 1)
		else
			@image.draw(@x, @y, 1)
		end
		if !@pause
			@y = @y - 7
		end
	end

end
#
#	Explosion Class
#
class Explosion
	def initialize(window, x, y)
		@x = x - 10
		@y = y
		@image = Gosu::Image.new(window, 'explosion.png', false)
		@timeout = Time.now + 0.5
		@pause = false
	end
	
	def exists?
		if @pause == false
			return @timeout >= Time.now
		else
			return true
		end
	end
	
	def pause(p)
		@pause = p
	end
	
	def draw
		@image.draw(@x, @y, 2)
	end
end
#
#	Ship Class
#
class Ship
	attr_reader :x, :y, :w, :h, :exists, :powerup_name
	def initialize(window)
		@x = $Width/2 - 20 #centers the ship
		@y = $Height - 60
		@w = 30
		@h = 31
		@image = Gosu::Image.new(window, 'ship.png', false)
		@image_shield = Gosu::Image.new(window, 'ship_shield.png', false)
		@image_laser = Gosu::Image.new(window, 'ship_laser.png', false)
		@image_both = Gosu::Image.new(window, 'ship_shield_laser.png', false)
		@pause = false
		@exists = true
		@powerup_name = ""
		@laser_timeout = Time.now
		
		
	end
	
	def move_left
		if @x > 0 and !@pause
			@x = @x - 10
		end
	end
	def move_right
		if @x < $Width - 30 and !@pause
			@x = @x + 10
		end
	end
	
	def destroy
		if @powerup_name == "shield.png"
			@powerup_name = ""
			return false
		elsif @powerup_name == "both"
			@powerup_name = "laser_powerup.png"
			return false
		else
			@exists = false
			return true
		end
	end
	
	def restart
		@x = $Width/2 - 15 #centers the ship
		@y = $Height - 40
		@exists = true
		@powerup_name = ""
		@laser_timeout = Time.now
	end
	def powerup(name)
		if @powerup_name == ""
			@powerup_name = name
		elsif name != @powerup_name
			@powerup_name = "both"
		end
		if name == "laser_powerup.png"
			@laser_timeout = Time.now + 5
		end
	end

	
	def pause(p)
		@pause = p
	end
	
	def draw
		if @powerup_name == "laser_powerup.png" or @powerup_name == "both"
			if @laser_timeout < Time.now
				if @powerup_name == "both"
					@powerup_name = "shield.png"
				else
					@powerup_name = ""
				end
			end	
		end
		if @powerup_name == "shield.png"
			@image_shield.draw(@x, @y, 1)
		elsif @powerup_name == "laser_powerup.png"
			@image_laser.draw(@x, @y, 1)
		elsif @powerup_name == "both"
			@image_both.draw(@x, @y, 1)
		else			
			@image.draw(@x, @y, 1)
		end
	end
end
#
#	Display Class
#
class Display
#$Height = 800
#$Width = 640
#width = 640, height = 480,
	def initialize(window)
		@line1 = Gosu::Font.new(window, 'courier', 25)
		@line2 = Gosu::Font.new(window, 'courier', 25)
		@line3 = Gosu::Font.new(window, 'courier', 25)
		@line4 = Gosu::Font.new(window, 'courier', 25)
	end
	
	def final_results(asteroids_missed, asteroids_hit, shots_fired)
		@line1.draw("YOU WIN!!!!!", 150, 300, 3)
		@line2.draw("Asteroids Missed: #{asteroids_missed}", 150, 330, 3)
		@line3.draw("Asteroids Hit: #{asteroids_hit}", 150, 360, 3)
		@line4.draw("Shots Fired: #{shots_fired}", 150, 390, 3)
	end
	
	def start_up
		@line1.draw("Welcome to ____________", 120, 300, 3)
		@line2.draw("Your goal is live for 2 minutes", 120, 330, 3)
		@line3.draw("don't let 10 asteroids get passed!", 120, 360, 3)
		@line4.draw("Good Luck! (press space to start)", 120, 390, 3)
	end
	def scores(asteroids_hit, asteroids_missed, time_left)
		@line1.draw("Hit: #{asteroids_hit}   Missed: #{asteroids_missed}   Time Left#{time_left}", 50, 780, 3)
	end

end
#
#	Main Window
#	WHERE STUFF HAPPENS
#
class MyWindow < Gosu::Window
	def initialize
		super($Width, $Height, false)
		
		#objects on screan
		@ship = Ship.new(self)
		@lasers = []
		@asteroids = []
		@explosions = []
		@powerups = []
		
		#timeing info
		@asteroid_delay = Time.now + 1
		@powerup_delay = Time.now + rand*1 + 1
		@game_time = Time.now + 120 #level 1 will last two minutes
		
		#scoring info
		@asteroids_missed = 0
		@asteroids_hit = 0
		@shots_fired = 0
		
		#game flow bools
		@pause = true
		@startup = true
		@game_done = false
		@win = false
		
		#fancy stuff
		@gameover = Gosu::Image.new(self, "gameover.png", false)
		@display = Display.new(self)
		
		#start the game paused so we can display the rules
		pause_game(@pause)
		
	end
	
	def button_down(id)
		case id
		#escape to close game
		when Gosu::KbEscape
			self.close
		when Gosu::KbSpace
			#space is used to start the game
			if @startup
				@pause = !@pause
				pause_game(@pause)
				@startup = false
			#once the game is started its used to fire
			elsif !@game_done and !@pause
				x = @ship.x
				y = @ship.y
				#fancy lasers for when you have the powerup
				if @ship.powerup_name == "laser_powerup.png" or @ship.powerup_name == "both"
					@lasers.push Laser.new(self, x-6, y+2, true)	
					@lasers.push Laser.new(self, x, y)	
					@lasers.push Laser.new(self, x+6, y+2, true)
				#regular lasers
				else
					@lasers.push Laser.new(self, x, y)	
				end
				@shots_fired += 1
			end
		#"p" to pause
		when Gosu::KbP
			if !@game_done
				@pause = !@pause
				pause_game(@pause)
			end
		#"r" to restart
		when Gosu::KbR
			restart_game
		end
	end
	
	#simple collision detection
	def are_touching?(obj1, obj2)
		if obj1.x > obj2.x - obj1.w and obj1.x < obj2.x + obj2.w and obj1.y > obj2.y - obj1.h and obj1.y < obj2.y + obj2.h
			return true
		else
			return false
		end
	end
	
	#update handles ships movement, creation of asteroids and powerups,
	#collision detection and handling, and end game conditions
	def update
		#ship movement
		if button_down?(Gosu::KbLeft)
			@ship.move_left
		elsif button_down?(Gosu::KbRight)
			@ship.move_right
		end
		
		#asteroid creation
		if @asteroid_delay < Time.now and !@game_done and !@pause
			@asteroids.push Asteroid.new(self)
			#delay till next asteroid
			@asteroid_delay = Time.now + rand*2 + 0.1
		end
		#powerup creation
		if @powerup_delay < Time.now and !@game_done and !@pause
			@powerups.push PowerUp.new(self)
			#delay till next powerup
			@powerup_delay = Time.now + 5
		end
		#collision detection for lasers
		@asteroids.each do |a|
			@lasers.each do |laser|
				if are_touching?(laser, a)
					@asteroids.delete(a)
					@explosions.push Explosion.new(self, laser.x, laser.y)
					@lasers.delete(laser)
					@asteroids_hit += 1
				end
			end
			#collision detection for the ship
			if are_touching?(a, @ship)
				@explosions.push Explosion.new(self, a.x+5, a.y)
				@asteroids.delete(a)
				if @ship.destroy
					@game_done = true
				end
			end
		end
		#collision detection for powerups
		@powerups.each do |p|
			if are_touching?(p, @ship)
				@powerups.delete(p)
				@ship.powerup(p.name)
			end
		end
		#game timer
		if @game_time < Time.now
			@game_done
			@win
		end
		#end game if you've missed to many asteroids
		if @asteroids_missed == 10
			@game_done = true
		end
	end
	
	#used to pause or unpause the game
	def pause_game(paused)
		@ship.pause(paused)
		@lasers.each do |laser|
			laser.pause(paused)
		end
		@asteroids.each do |a|
			a.pause(paused)
		end
		@explosions.each do |e|
			e.pause(paused)
		end
		@powerups.each do |p|
			p.pause(paused)
		end
	end

	# restarts the game and resests everything	
	def restart_game
		@asteroids.clear
		@explosions.clear
		@lasers.clear
		@ship.restart
		@asteroid_delay = Time.now + 1
		@powerups_delay = Time.now + 1
		@powerups.clear
		@pause = false
		pause_game(@pause)
		@asteroids_missed = 0
		@asteroids_hit = 0
		@shots_fired = 0
		@game_done = false
		@win = false
	end

	def draw
		if @startup
			@display.start_up
		#usual game play
		else
			#how many asteroids you've missed
			@display.scores(@asteroids_hit, @asteroids_missed, @game_time - Time.now)
			#is ship distroyed or not
			if @ship.exists
				@ship.draw
			end
			#track and draw lasers
			@lasers.each do |laser|
				laser.draw
				if !laser.exists?
					@lasers.delete(laser)
				end
			end
			#track and draw asteroids
			@asteroids.each do |a|
				a.draw
				if !a.exists?
					@asteroids.delete(a)
					@asteroids_missed += 1
				end
			end
			#track and draw powerups
			@powerups.each do |p|
				p.draw
				if !p.exists?
					@powerups.delete(p)
				end
			end
			#draw explosions
			@explosions.each do |e|
				e.draw
				if !e.exists?
					@explosions.delete(e)
				end
			end
			#do fancy for end of game
			if @game_done
				pause_game(true)
				if !@win
					@gameover.draw(150, 200, 3)
				else
					@display.final_results(@asteroids_missed, @asteroids_hit, @shots_fired)
				end
			end
		end
	end
end

MyWindow.new.show