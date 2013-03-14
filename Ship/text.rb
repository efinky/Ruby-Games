#!/usr/bin/env ruby
require 'rubygems'
require 'gosu'

class MyWindow < Gosu::Window
	def initialize
		super(640, 480, false)

		@text = Gosu::Font.new(self, 'script', 40)
	end

	def draw
		@text.draw("Greetings!!!!", 100, 100, 1)
	end
end

MyWindow.new.show