require "readline"


MOVE_MESSAGES = {}
MOVE_MESSAGES[:N] = :north
MOVE_MESSAGES[:S] = :south
MOVE_MESSAGES[:E] = :east
MOVE_MESSAGES[:W] = :west

HEADING_ANGLE = {}
HEADING_ANGLE[:N] = 0
HEADING_ANGLE[:E] = 90
HEADING_ANGLE[:S] = 180
HEADING_ANGLE[:W] = 270

class Position
	attr_reader :x
	attr_reader :y

	def initialize(x, y)
		@x = x
		@y = y
	end

	def north
		@y += 1
		return self
	end

	def south
		@y -= 1
		return self
	end

	def east
		@x += 1
		return self
	end

	def west
		@x -= 1
		return self
	end

	def to_str
		"Position:: (#{@x}, #{@y})"
	end

	def eql?(other)
		other.instance_of?(self.class) && other.x == self.x && other.y == self.y
	end

	def ==(other)
		self.eql?(other)
    end
end

class Grid
	attr_reader :max_pos

	def initialize(position)
		@max_pos = position if (position.is_a?(Position))
	end

	def is_valid?(position)
		valid = true
		if (position.x < 0 || position.x > @max_pos.x)
			valid = false
		end

		if (position.y < 0 || position.y > @max_pos.y)
			valid = false
		end

		valid
	end

	def to_str
		"Grid :: (0, 0) to (#{@max_pos.x}, #{@max_pos.y})"
	end

end

class Rover
	attr_reader   :position
	attr_reader   :grid
	attr_accessor :heading
	attr_reader   :angle

	def initialize(x, y, heading, grid)
		if (!grid.is_a?(Grid)) 
			raise ArgumentError, "4th argument should be a Grid"
		end
		@grid = grid
		@position = Position.new(x.to_i, y.to_i)
		@heading = heading
		@angle = HEADING_ANGLE[@heading.to_sym]
	end

	def move
		move_msg = MOVE_MESSAGES[@heading.to_sym]
		new_position = @position
		@position.__send__(move_msg)
		if ( ! @grid.is_valid?(new_position) )
			raise "Move is invalid. Position #{new_position.inspect} cannot be made."
		end
		@position = new_position
	end

	def rotate(rotation)
		if (rotation == "L")
			@angle -= 90
		elsif (rotation == "R")
			@angle += 90
		end

		if (@angle < 0)
			@angle += 360
		end

		if (@angle >= 360)
			@angle -= 360
		end
		
		new_hdg = HEADING_ANGLE.invert[@angle]
		Rover.is_heading_valid?(new_hdg.to_s)
		@heading = new_hdg
	end

	def to_str
		"Rover #{@position.to_str}, Heading:: #{@heading}, Angle:: #{angle}"
	end

	def self.create_rover(buf, grid)
		x, y, hdg = buf.split(/ /)
		if ( ! self.is_heading_valid?(hdg) )
			raise "Input Error, Heading #{hdg} is not a valid heading"
		end
		return Rover.new(x.to_i, y.to_i, hdg, grid)
	end

	def self.is_heading_valid?(heading)
		MOVE_MESSAGES.has_key?(heading.to_sym)
	end

end
