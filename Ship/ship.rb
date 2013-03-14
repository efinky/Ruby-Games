#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'

$Height = 800
$Width = 640
#640, 480,
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
				@x = @x + rand*8 - rand*6
			elsif @name == "red.png"
				@y = @y + @vy
				@vy += 0.1
			else
				@y = @y + 2
			end
		end
	end
end

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

class Ship
	attr_reader :x, :y, :w, :h, :exists, :powerup_name
	def initialize(window)
		@x = $Width- 100 #centers the ship
		@y = $Height - 40
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
class Display
	def initialize(window)
		@line1 = Gosu::Font.new(window, 'courier', 20)
		@line2 = Gosu::Font.new(window, 'courier', 20)
		@line3 = Gosu::Font.new(window, 'courier', 20)
		@line4 = Gosu::Font.new(window, 'courier', 20)
	end
	
	def final_results(asteroids_missed, asteroids_hit, shots_fired)
		@line1.draw("YOU WIN!!!!!", 150, 200, 3)
		@line2.draw("Asteroids Missed: #{asteroids_missed}", 150, 220, 3)
		@line3.draw("Asteroids Hit: #{asteroids_hit}", 150, 240, 3)
		@line4.draw("Shots Fired: #{shots_fired}", 150, 260, 3)
	end
	
	def scores(asteroids_missed)
		@line1.draw("Asteroids Missed: #{asteroids_missed}", 380, 460, 3)
	end
	
	def start_up
		@line1.draw("Welcome to ____________", 120, 200, 3)
		@line2.draw("Your goal is to shoot 20 asteroids", 120, 220, 3)
		@line3.draw("before 10 get past", 120, 240, 3)
		@line4.draw("Good Luck! (press space to start)", 120, 260, 3)
	end

end
class MyWindow < Gosu::Window
	def initialize
		super($Width, $Height, false)
		@ship = Ship.new(self)
		@lasers = []
		@asteroids = []
		@asteroid_delay = Time.now + 1
		@explosions = []
		@powerups = []
		@powerup_delay = Time.now + rand*1 + 1
		@game_done = false
		@win = false
		@gameover = Gosu::Image.new(self, "gameover.png", false)
		@asteroids_missed = 0
		@asteroids_hit = 0
		@shots_fired = 0
		@pause = true
		@startup = true
		@display = Display.new(self)
		
		@level = 1
		pause_game(@pause)
	end
	
	def button_down(id)
		case id
		when Gosu::KbEscape
			self.close
		when Gosu::KbSpace
			if @startup
				@pause = !@pause
				pause_game(@pause)
				@startup = false
			elsif !@game_done and !@pause
				if @ship.powerup_name == "laser_powerup.png" or @ship.powerup_name == "both" 
					@lasers.push Laser.new(self, @ship.x-6, @ship.y+2, true)	
					@lasers.push Laser.new(self, @ship.x, @ship.y)	
					@lasers.push Laser.new(self, @ship.x+6, @ship.y+2, true)	
				else
					@lasers.push Laser.new(self, @ship.x, @ship.y)	
				end
				@shots_fired += 1
			end
		when Gosu::KbP
			if !@game_done
				@pause = !@pause
				pause_game(@pause)
			end
		when Gosu::KbR
			restart_game
		end
	end
	
	def are_touching?(obj1, obj2)
		if obj1.x > obj2.x - obj1.w and obj1.x < obj2.x + obj2.w and obj1.y > obj2.y - obj1.h and obj1.y < obj2.y + obj2.h
			return true
		else
			return false
		end
	end
	
	def update
		if button_down?(Gosu::KbLeft)
			@ship.move_left
		elsif button_down?(Gosu::KbRight)
			@ship.move_right
		end
		
		if @asteroid_delay < Time.now and !@game_done and !@pause
			@asteroids.push Asteroid.new(self)
			@asteroid_delay = Time.now + rand*2 + 0.1
		end
		if @powerup_delay < Time.now and !@game_done and !@pause
			@powerups.push PowerUp.new(self)
			@powerup_delay = Time.now + 5
		end
		@asteroids.each do |a|
			@lasers.each do |laser|
				if are_touching?(laser, a)
					@asteroids.delete(a)
					@explosions.push Explosion.new(self, laser.x, laser.y)
					@lasers.delete(laser)
					@asteroids_hit += 1
				end
			end
			if are_touching?(a, @ship)
				@explosions.push Explosion.new(self, a.x+5, a.y)
				@asteroids.delete(a)
				if @ship.destroy
					@game_done = true
				end
			end
		end
		@powerups.each do |p|
			if are_touching?(p, @ship)
				@powerups.delete(p)
				@ship.powerup(p.name)
			end
		end
		if @asteroids_hit == 20
			@game_done = true
			@win = true
		end
		if @asteroids_missed == 10
			@game_done
		end
	end
	
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
		else
			@display.scores(@asteroids_missed)
			if @ship.exists
				@ship.draw
			end
			@lasers.each do |laser|
				laser.draw
				if !laser.exists?
					@lasers.delete(laser)
				end
			end
			@asteroids.each do |a|
				a.draw
				if !a.exists?
					@asteroids.delete(a)
					@asteroids_missed += 1
				end
			end
			@powerups.each do |p|
				p.draw
				if !p.exists?
					@powerups.delete(p)
				end
			end
			@explosions.each do |e|
				e.draw
				if !e.exists?
					@explosions.delete(e)
				end
			end
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