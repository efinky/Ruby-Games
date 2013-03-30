#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'
include Math

##### buildings, 
#### pause in asteroid gen between levels ##### DONE
##### fix pause time so it doesn't gliche ##### DONE
#change time displayed to overall time played...  #### DONE

#do we want levels to be a specific time? or some sort of goal?

#screen dimensions
$Height = 800
$Width = 640
#time per each level in seconds
$TimeLimit = 45
#number of asteroids you can't let past per level
$AsteroidDeath = 20
#length of laser powerup
$LaserPowerup = 13
$StartingLevel = 2
$MaxLevel = 12
$Cheat = true

#####################################################################
#	Lives Class
#####################################################################
class Lives
	def initialize(window, dx)
		@image = Gosu::Image.new(window, "ship.png", false)
		@w = @image.width
		@h = @image.height
		@x = $Width - dx - 40
		@y = 10
	end
	
	def draw
		@image.draw(@x, @y, 1)
	end

end
# ^Lives

#####################################################################
#	PowerUp Class
#####################################################################
class PowerUp
	attr_reader :x, :y, :w, :h, :laser, :is_shield
	def initialize(window, level)
		@is_shield = false
		@laser = ""
		@images = ["powerup_shield.png", "powerup_blue.png", "powerup_missle.png", "powerup_green.png"]
		if level <= 5
			@name = @images[rand*level-1]
		else
			@name = @images[rand*4]
		end
		# if level == 5
			# @name = @images[rand*4]
		# elsif level == 4
			# @name = @images[rand*level]
		# else
			# @name = @images[rand*level]
		# end
		if @name == "powerup_blue.png" 
			@laser = "b"
		elsif @name == "powerup_green.png"
			@laser = "g"
		elsif @name == "powerup_missle.png"
			@laser = "m"
		else
			@is_shield = true
		end
		@image = Gosu::Image.new(window, @name, false)
		@w = @image.width
		@h = @image.height
		@x = rand*($Width - @w)
		@y = @h
		
	end
	
	def exists?
		@y < $Height - @h - 10
	end
	
	def pause(p)
		@pause = p
	end
	
	def draw
		@image.draw(@x, @y, 1)
		if !@pause
			@y = @y + 5
		end
	end

end
# ^PowerUp

#####################################################################
#	Asteroid Class
#####################################################################
class Asteroid
	attr_reader :x, :y, :w, :h, :name, :destroyed, :tracked
	def initialize(window, level)
			
		@level = level
		if @level < 10
			@vy = 1
		else
			@vy = 3
		end
		
		
		@images = ['asteroid.png', 'smiles.png', 'pink.png', 'red.png', 'purple.png', 'asteroid_tiny.png']
		if level <= @images.length
			@name = @images[rand*(@images.length - (@images.length - level))]
		else
			@name = @images[rand*@images.length]
		end
		@image = Gosu::Image.new(window, @name, false)
		if @level < 8
			@purple_teleport = Time.now + rand*1.0 + 0.5
		elsif @level < 12 
			@purple_teleport = Time.now + rand*1.0 + 0.1
		else
			@purple_teleport = Time.now + rand*1.0
		end
		@destroyed = false
		@tracked = false
		@pause = false
		
		@w = @image.width
		@h = @image.height
		@y = @h
		@x = rand*($Width - @w)
		
		@line2 = Gosu::Font.new(window, 'courier', 25)
	end
	
	def exists?
		if @y < $Height - 50
			@destroyed = false
			return true
		else
			@destroyed = true
			return false
		end
	end
	
	def track(tracked)
		@tracked = tracked
		
	end
	
	def hit
		@destroyed = true
	end
	
	def pause(p)
		@pause = p
	end
	
	def draw 
		@image.draw(@x, @y, 1)
		if !@pause
			#level 2
			if @name == "smiles.png"
				@y = @y + 4
			#level 3
			elsif @name == "pink.png"
				@y = @y + 4
				if @x > $Width - @w
					@x = @x - 8
				elsif @x < 0
					@x = @x + 8
				else
					if @level < 6
						@x = @x + rand*7 - rand*7
					elsif @level < 9
						@x = @x + rand*12 - rand*12
					elsif @level < 12
						@x = @x + rand*18 - rand*18
					else
						@x = @x + rand*22 - rand*22
					end
				end
			#at level 4
			elsif @name == "red.png"
				@y = @y + @vy
				if @level < 10
					@vy += 0.1
				else
					@vy += 0.25
				end
			#at level 5
			elsif @name == "purple.png"
				@y = @y + 4
				if @purple_teleport < Time.now
					@x = rand*($Width - @w) + @w
					if @level < 8
						@purple_teleport = Time.now + rand*1.0 + 0.5
					elsif @level < 12
						@purple_teleport = Time.now + rand*1.0 + 0.1
					else
						@purple_teleport = Time.now + rand*1.0
					end
				end
			else
				@y = @y + 2
			end
		end
	end
end
# ^Asteroid

#####################################################################
#	Building Class
#####################################################################
class Building
	attr_reader :x, :y, :w, :h
	def initialize(window, current_x, image)
		@images = ["building_big.png", "building_medium.png", "building_small.png", "building_tiny.png"]
		@image = Gosu::Image.new(window, @images[image], false)
		@w = @image.width
		@h = @image.height
		@x = current_x - @w - (rand*5 + 5)
		@y = $Height - @h
	end
	
	def draw
		@image.draw(@x, @y, 0)
	end

end
# ^ Buildings

#####################################################################
#	Laser Class
#####################################################################
class Laser
	attr_reader :x, :y, :w, :h
	def initialize(window, x, y, powerup = -1, direction = 0)
		@x = x + 13
		@y = y - 7
		#normal orange lasers
		if powerup == -1
			@image = Gosu::Image.new(window, 'laser.png', false)
		#blue lasers
		elsif powerup == 0
			@image = Gosu::Image.new(window, 'blue_laser.png', false)
		#green lasers
		else powerup == 1
			@image = Gosu::Image.new(window, 'green_laser.png', false)
		end
		@w = @image.width
		@h = @image.height
		@direction = direction
		@pause = false
	end
	
	def exists?
		@y > 0
	end
	
	def pause(p)
		@pause = p
	end
		
	def draw
		@image.draw(@x, @y, 1)
		if !@pause
			@y = @y - 7
			@x -= @direction
		end
	end

end
# ^Laser

#####################################################################
#	Missle Class
#####################################################################
class Missle
	attr_reader :x, :y, :w, :h, :tracking
	def initialize(window, x, y)
		@x = x
		@y = y
		@w = 40
		@h = 40
		@speed = 10
		@pause = false
		@tracking = false
		@asteroid = nil
		@angle = 0
		@image = Gosu::Image.new(window, "missle.png", false)
		@font = Gosu::Font.new(window, "courier", 25)
	
	end
	
	def exists?
		@y > 0
	end
	
	def pause(p)
		@pause = p
	end
	
	def destroyed
		if @asteroid != nil
			@asteroid.track(false)
		end
	end
	
	def track(asteroid)
		if asteroid != nil
			@asteroid = asteroid
			@tracking = true
		end
	end
	
	def draw
		if !@pause
		
			#keeps track of direction missle is going
			x_movement = 0
			y_movement = 0
			#keep the program from crashing if there isn't an asteroid yet
			if @asteroid != nil
				#determine velocity first
				d_x = (@x - (@asteroid.x+(@asteroid.w/2))).abs
				d_y = (@y - (@asteroid.y+(@asteroid.h/2))).abs
		
				vy = @speed * (Math.sin(Math.atan(d_y.to_f/d_x.to_f)))
				vx = @speed * (Math.sin(Math.atan(d_x.to_f/d_y.to_f)))
				angle_right = ((Math.atan(d_x.to_f/d_y.to_f) * 180)/PI)
				angle_left = ((Math.atan(d_y.to_f/d_x.to_f) * 180)/PI)
				#if asteroid destroyed continue forward till a new asteroid is assigned
				if @asteroid.destroyed
					@tracking = false
					#missle is going up
					y_movement = -1
					@y -= @speed
					@angle = 0
				#if the asteroid is not destroyed track it
				else
					@tracking = true
					if @asteroid.x > @x + (@asteroid.w/4)
						@x += vx
						@angle = angle_right
						#missle is going to the right
						x_movement = 1
					elsif @asteroid.x < @x - (@asteroid.w/4)
						#missle is going to the left
						@angle = angle_left + 270
						x_movement = -1
						@x -= vx
					end
					#if we are in paralell with the asteroid
					if @asteroid.y >= @y + (@asteroid.h/2) and @asteroid.y <= @y - (@asteroid.h/2) 
						
					#if we are above the asteroid
					elsif @asteroid.y > @y
						@y += vy
						if (x_movement == 1)
							@angle = 90 + angle_left
						elsif x_movement == -1
							@angle = angle_right + 180
						else
							@angle == 180
						end
						#missle is going down
						y_movement = 1
					#if nothing else, missle must go up
					else
						@y -= vy
						#missle is going up
						y_movement = -1
					end
				end
			else
				tracking = false
				@y -= @speed
				@angle = 0
				#missle is going up
				y_movement = -1
			end
		end
		@image.draw_rot(@x, @y, 1, @angle)
	end
end
# ^ Missle

#####################################################################
#	Explosion Class
#####################################################################
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
# ^Explosion

#####################################################################
#	Ship Class
#####################################################################
class Ship
	attr_reader :x, :y, :w, :h, :exists, :lasers
	def initialize(window)
		@x = $Width/2 - 15 #centers the ship
		@y = $Height - 100
		@w = 30
		@h = 31
		@window = window
		
		@image = Gosu::Image.new(window, 'ship.png', false)
		@image_shield = Gosu::Image.new(window, 'ship_shield.png', false)
		@image_shield_green = Gosu::Image.new(window, 'ship_shield_green.png', false)
		@image_shield_blue = Gosu::Image.new(window, 'ship_shield_blue.png', false)
		@image_blue = Gosu::Image.new(window, 'ship_blue.png', false)
		@image_green = Gosu::Image.new(window, 'ship_green.png', false)
		@display_num_missles = Gosu::Font.new(window, 'courier', 20)
		@display_num_shields = Gosu::Font.new(window, 'courier', 20)
		@image_p_missles = Gosu::Image.new(window, 'missle.png', false)
		@image_p_shields = Gosu::Image.new(window, 'shields.png', false)
		@missles = 0
		@shields = 0

		@pause = false
		@exists = true
		
		@lasers = ""
		@laser_timeout = Time.now
		@lives = []
		@lives.push Lives.new(window, 50)
		@lives.push Lives.new(window, 0)	
		
	end
	#controls left movement
	def move_left
		if @x > 0 and !@pause
			@x = @x - 10
		end
	end
	#controls right movement
	def move_right
		if @x < $Width - 30 and !@pause
			@x = @x + 10
		end
	end
	
	#handles and returns whether or not the ship is destroyed
	#returns -1 if destroyed, 0 if shield protected and 1 if loss of life
	def destroy()
		#if it has a shield remove shield but don't destroy ship or remove a life
		if @shields > 0
			@shields -= 1
			return 0
		#removes a life and checks to see if it was the last one left
		elsif @lives.pop == nil
			@exists = false
			return -1
		#else life was 'pop'ed on the last check so just return 1
		else
			return 1
		end
	end
	
	def missle_fired?
		if @missles > 0
			@missles -= 1
			return true
		else
			return false
		end
	end
	
	#handles restarting for the ship
	def restart
		@x = $Width/2 - 15 #centers the ship
		@y = $Height - 100
		@exists = true
		@powerup_name = ""
		@laser_timeout = Time.now
		@shields = 0
		@missles = 0
	end
	
	#accepts the powerups and sets their name
	def powerup(laser, is_shield)
		
		if is_shield
			@shields += 1
		elsif laser == "m"
			3.times do
				@missles += 1
			end
		
		else
			#reloads the laser energy
			@laser_timeout = Time.now + $LaserPowerup
			
			#green is the highest you can't upgrade from there
			if @lasers != "g"
				@lasers = laser
			end
		end
	end

	#used to pause or unpause the ship
	def pause(p)
		@pause = p
	end
	
	def draw
		#used to update which powerups the ship currently has
		if @lasers != ""
			#if time runs out, remove laser powerup
			if @laser_timeout < Time.now
				@lasers = ""
			end	
		end
		#draws the appropriate ship depending on which powerup it currently has
		if @shields > 0
			if @lasers == "b"
				@image_shield_blue.draw(@x, @y, 1)
			elsif @lasers == "g"
				@image_shield_green.draw(@x, @y, 1)
			else
				@image_shield.draw(@x, @y, 1)
			end
		elsif @lasers == "b"
			@image_blue.draw(@x, @y, 1)
		elsif @lasers == "g"
			@image_green.draw(@x, @y, 1)
		#else just draws the normal ship
		else			
			@image.draw(@x, @y, 1)
		end
		#displays number of lives left
		@lives.each do |life|
			life.draw
		end
		#displays number of shields collected
		#displays number of missles
		if @shields > 0
			@display_num_shields.draw("X #{@shields}",$Width - 70, $Height - 40, 1)
			@image_p_shields.draw($Width - 100, $Height - 40, 1)
		end
		if @missles > 0
			@display_num_missles.draw("X #{@missles}", 30, $Height - 50, 1)
			@image_p_missles.draw(10, $Height - 60, 1)
		end
		
	end
end
# ^Ship

#####################################################################
#	Display Class
#####################################################################
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
	
	#final results
	def final_results(asteroids_missed, asteroids_hit, asteroids_hit_missles, missles_fired, shots_fired)
		#calculates accuracy
		if (shots_fired != 0)
			accuracy = (asteroids_hit.to_f/shots_fired.to_f) * 100
		else
			accuracy = 0
		end
		
		@line1.draw("Asteroids Missed: #{asteroids_missed}", 80, 300, 3)
		@line2.draw("Asteroids hit by Lasers:#{asteroids_hit}", 80, 330, 3)
		@line3.draw("Asteroids hit by Missles:#{asteroids_hit_missles}", 80, 360, 3)
		@line4.draw("Shots Fired:#{shots_fired}  Missles:#{missles_fired}  Accuracy:%#{accuracy.to_i}", 80, 390, 3)
	end
	
	#startup message
	def start_up
		@line1.draw("Welcome to THISGAME", 80, 300, 3)
		@line2.draw("IF you complete all #{$MaxLevel} levels you win!", 80, 330, 3)
		@line3.draw("don't let #{$AsteroidDeath} asteroids get passed!", 80, 360, 3)
		@line4.draw("Good Luck! (press space to start)", 80, 390, 3)
	end
	
	def level(new_level)
		@line1.draw("Level #{new_level}.", 250, 400, 3)
	end
	
	#scores displayed during runtime
	def scores(asteroids_hit, asteroids_missed, time_left, levels)
		@line1.draw("Hit: #{asteroids_hit} Missed: #{asteroids_missed} Level #{levels} Time: #{time_left.strftime("%M:%S")}", 10, 10, 3)
		#### maybe add a counter so that you can have more than 2 lives?
	end

end
# ^Display

#####################################################################
#	Main Window
#	WHERE STUFF HAPPENS
#####################################################################
class MyWindow < Gosu::Window
	def initialize
		super($Width, $Height, false)
		self.caption = ("THISGAME")
		#objects on screan
		@ship = Ship.new(self)
		@lasers = []
		@missles = []
		@asteroids = []
		@explosions = []
		@powerups = []
		@buildings = []
		#create 4 big buildings
		current_x = $Width - 100
		while current_x > 100
			@buildings.push Building.new(self, current_x, rand*4)
			current_x = (@buildings.last.x)
		end
		#create 2 medium buildings
		
		#create 3 small buildings
		
		#create 4 tiny buildings
		
		@level = $StartingLevel
		
		#timeing info
		@asteroid_delay = Time.now + 1
		@powerup_delay = Time.now + rand*1 + 1
		@level_time = Time.now + $TimeLimit # + however many seconds you want the game to last
		@display_new_level_timer = Time.now
		@paused_time = 0
		@start_time = Time.now
		@total_time_played = 0
		
		#scoring info
		@asteroids_missed = 0
		@asteroids_hit = 0
		@asteroids_hit_missles = 0
		@shots_fired = 0
		@missles_fired = 0
		
		#game flow bools
		@pause = true
		@startup = true
		@game_done = false
		@win = false
		@sleep_clear = 0
		
		#fancy stuff
		@gameover = Gosu::Image.new(self, "gameover.png", false)
		@win_image = Gosu::Image.new(self, "win.png", false)
		@display = Display.new(self)
		
		#start the game paused so we can display the rules
		pause_game(@pause)
		
	end
	
	#simple collision detection
	def are_touching?(obj1, obj2)
		if obj1.x > obj2.x - obj1.w and obj1.x < obj2.x + obj2.w and obj1.y > obj2.y - obj1.h and obj1.y < obj2.y + obj2.h
			return true
		else
			return false
		end
	end
	
	#used to pause or unpause the game
	def pause_game(paused)
		@ship.pause(paused)
		if paused
			@paused_time = Time.now
		else
			@level_time = Time.now + (@level_time - @paused_time)
			@start_time = @start_time + (Time.now() - @paused_time)
		end
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
		@missles.each do |missle|
			missle.pause(paused)
		end
	end

	# restarts the game and resets everything	
	def restart_game
		clear_screen
		pause_game(@pause)
		@asteroids_missed = 0
		@asteroids_hit = 0
		@asteroids_hit_missles = 0
		@shots_fired = 0
		@missles_fired = 0
		@pause = false
		@game_done = false
		@win = false
		@level = $StartingLevel
		@level_time = Time.now + $TimeLimit
	end
	def next_level
		#don't reset the ship when you clear
		clear_screen(false)
		#pause_game(@pause)
		#@pause = false
		@game_done = false
		@win = false
		###################################### still track total missed ####################
		#@asteroids_missed = 0
		@level_time = Time.now + $TimeLimit
	end
	
	def clear_screen(totally_clear = true)
		@asteroids.clear
		@explosions.clear
		@lasers.clear
		@missles.clear
		if totally_clear
			@ship.restart
		end
		@powerups.clear
		@asteroid_delay = Time.now + 1
		@powerups_delay = Time.now + 1
	end
	
	
	#space, escape, r, p
	def button_down(id)
		case id
		#escape to close game
		when Gosu::KbEscape
			self.close
		when Gosu::KbSpace#, Gosu::KbUp
			#space is used to start the game
			if @startup
				@pause = !@pause
				pause_game(@pause)
				@startup = false
				@level_time = Time.now + $TimeLimit 
			#once the game is started its used to fire
			elsif !@game_done and !@pause
				x = @ship.x
				y = @ship.y
				#fancy lasers for when you have the powerup
				if @ship.lasers == "b"
					@lasers.push Laser.new(self, x-12, y+2, 0)	
					#@lasers.push Laser.new(self, x, y)	
					@lasers.push Laser.new(self, x+12, y+2, 0)
				#even fancy lasers you can't get till level 3
				elsif @ship.lasers == "g"
					@lasers.push Laser.new(self, x-12, y+2, 1, 1)	
					@lasers.push Laser.new(self, x, y, 1, 0)	
					@lasers.push Laser.new(self, x+12, y+2, 1, -1)
				#regular lasers
				else
					@lasers.push Laser.new(self, x, y)	
				end
				@shots_fired += 1
			end
		when Gosu::KbUp
			if !@game_done and !@pause
				if @ship.missle_fired?
					@missles.push Missle.new(self, @ship.x, @ship.y)
					@missles_fired += 1
				end
			end
		when Gosu::KbM
			if $Cheat
				3.times do
					@ship.powerup("m", false)
				end
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
	
	#update handles ships movement, creation of asteroids and powerups,
	#collision detection and handling, and end game conditions
	def update
		#ship movement
		if button_down?(Gosu::KbLeft)
			@ship.move_left
		elsif button_down?(Gosu::KbRight)
			@ship.move_right
		end
		#missle tracking
		if @missles.length > 0
			@missles.each do |missle|
				if !missle.tracking
					asteroid = nil
					@asteroids.each do |a|
						if a.tracked == false
							if asteroid == nil
								asteroid = a
							else
								if asteroid.y - missle.y < a.y - missle.y
									asteroid = a
								end
							end
						end
					end
					if asteroid != nil
						asteroid.track(true)
						missle.track(asteroid)
					end
				end
			end
		end
		#asteroid creation
		
		if @asteroid_delay < Time.now and !@game_done and !@pause and @level_time - 7 >= Time.now
			@asteroids.push Asteroid.new(self, @level)
			#delay till next asteroid
			@asteroid_delay = Time.now + rand*2 + 0.1
		end
		#powerup creation
		if @level != 1
			if @powerup_delay < Time.now and !@game_done and !@pause
				@powerups.push PowerUp.new(self, @level)
				#delay till next powerup
				@powerup_delay = Time.now + 5
			end
		end
		#collision detection for asteroids
		@asteroids.each do |a|
			#collision detection for lasers
			@lasers.each do |laser|
				if are_touching?(laser, a)
					a.hit
					@asteroids.delete(a)
					@explosions.push Explosion.new(self, laser.x, laser.y)
					@lasers.delete(laser)
					@asteroids_hit += 1
				end
			end
			#collision detection for missles
			@missles.each do |missle|
				if are_touching?(missle, a)
					a.hit
					@asteroids.delete(a)
					@explosions.push Explosion.new(self, a.x, a.y)
					missle.destroyed
					@missles.delete(missle)
					@asteroids_hit_missles += 1
				end
			end
			#collision detection for the ship
			if are_touching?(a, @ship)
				@explosions.push Explosion.new(self, a.x+5, a.y)
				a.hit
				@asteroids.delete(a)
				check = @ship.destroy
				#game over, all lives lost, and ship destroyed
				if check == -1
					@explosions.push Explosion.new(self, @ship.x+5, @ship.y)
					@game_done = true
				#loss of life
				elsif check == 1
					@explosions.push Explosion.new(self, @ship.x+5, @ship.y)
					#creates a delay so you can see that you lost a life
					@sleep_clear = 1
				end
				#if check == 0 then ship simply lost shield powerup
			end
			#collision detection for buildings
			@buildings.each do |b|
				if are_touching?(a, b)
					@buildings.delete(b)
					#@asteroids.delete(a)
					@explosions.push Explosion.new(self, a.x+5, a.y)
				end
			end
		end
		#collision detection for powerups
		@powerups.each do |p|
			if are_touching?(p, @ship)
				@powerups.delete(p)
				@ship.powerup(p.laser, p.is_shield)
			end
		end
		#game timer
		if @level_time < Time.now and !@pause and !@game_done
			if @level == $MaxLevel
				@game_done = true
				@win = true
			else
				@level += 1
				#restarts the timer for the next level
				@level_time = Time.now + $TimeLimit
				next_level
				@display_new_level_timer = Time.now + 1
			end
				
		end
		#end game if you've missed too many asteroids
		if @asteroids_missed == $AsteroidDeath
			@game_done = true
		end
		if @buildings.empty?
			@game_done = true
		end
		if !@pause
			@total_time_played = Time.now - @start_time
		end
	end

	def draw
		#startup display
		if @startup
			@display.start_up
		#continue with usual game play after startup
		else
			#only display this while the game is currently running
			if !@game_done
			#how many asteroids you've missed, how many you've hit, and how much time's left
			@display.scores(@asteroids_hit + @asteroids_hit_missles, @asteroids_missed, Time.at(@total_time_played), @level)
			#if the game is done -> do fancy
			else
				pause_game(true)
				if !@win
					@gameover.draw(150, 100, 3)
					@display.final_results(@asteroids_missed, @asteroids_hit, @asteroids_hit_missles, @missles_fired, @shots_fired)
				else
					@win_image.draw(150, 100, 3)
					@display.final_results(@asteroids_missed, @asteroids_hit, @asteroids_hit_missles, @missles_fired, @shots_fired)
				end
			end
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
			@missles.each do |missle|
				if !missle.exists?
					@missles.delete(missle)
				else
					missle.draw
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
			#draw buildings
			@buildings.each do |b|
				b.draw
			end
			
			#draw explosions
			@explosions.each do |e|
				e.draw
				if !e.exists?
					@explosions.delete(e)
				end
			end
			#displayed when change of levels
			if @display_new_level_timer > Time.now
				@display.level(@level)
			end
			#adds a delay so that you can see that you died before it continues
			if @sleep_clear > 0
				if @sleep_clear == 1
					@sleep_clear += 1
				elsif @sleep_clear == 2
					@sleep_clear = 0
					sleep(0.5)
					clear_screen
				end
			end
		end
	end
end

MyWindow.new.show