require_relative "mars_rover"
require "test/unit"

class TestPosition < Test::Unit::TestCase

	def testInitialize
		pos = Position.new(5, 7)
		assert_equal 5, pos.x
		assert_equal 7, pos.y
	end

	def testNorth
		pos = Position.new(5, 7)
		pos.north
		assert_equal 5, pos.x
		assert_equal 7 + 1, pos.y
	end

	def testSouth
		pos = Position.new(5, 7)
		pos.south
		assert_equal 5, pos.x
		assert_equal 7 - 1, pos.y
	end

	def testEast
		pos = Position.new(5, 7)
		pos.east
		assert_equal 5 + 1, pos.x
		assert_equal 7, pos.y
	end

	def testWest
		pos = Position.new(5, 7)
		pos.west
		assert_equal 5 - 1, pos.x
		assert_equal 7, pos.y
	end
end

class TestGrid < Test::Unit::TestCase

	def testInitialize
		pos = Position.new(5, 7)
		grid = Grid.new(pos)
		assert_equal pos, grid.max_pos
	end

	def testIsValidForValidPoistion
		max_pos = Position.new(5, 5)
		grid = Grid.new(max_pos)
		pos = Position.new(4, 3)
		assert_true grid.is_valid?(pos)
	end

	def testIsNotValidForInvalidX
		max_pos = Position.new(5, 5)
		grid = Grid.new(max_pos)
		pos = Position.new(6, 3)
		assert_false grid.is_valid?(pos), "X greater than Grid should not be valid"
	end

	def testIsNotValidForInvalidY
		max_pos = Position.new(5, 5)
		grid = Grid.new(max_pos)
		pos = Position.new(4, 7)
		assert_false grid.is_valid?(pos), "X greater than Grid should not be valid"
	end	
end

class TestRover < Test::Unit::TestCase

	def testInitializeRover
		grid = Grid.new(Position.new(5, 5))
		rover = Rover.new(1,2,"N", grid)
		assert_equal 0, rover.angle, "Rover with heading north should be at 0 angle"
	end

	def testInitializeWithoutGridThrowsError
		assert_raise (ArgumentError) {rover = Rover.new(1,2,"N", [])}
	end

	def testMoveRoverWorksAsPerHeading
		grid = Grid.new(Position.new(5, 5))
		rover = Rover.new(1,2,"N", grid)
		exp_pos = Position.new(1,3)
		rover.move
		assert_equal exp_pos, rover.position, "Rover with North heading did not move as expected."
	end

	def testRotateLeftCorrectlyChangesAngle
		grid = Grid.new(Position.new(5, 5))
		rover = Rover.new(1,2,"N", grid)
		assert_equal 0, rover.angle, "Angle of North is 0"
		rover.rotate("L")
		assert_equal 270, rover.angle, "Angle after rotation Left from North should be 270"
		rover.rotate("L")
		assert_equal 180, rover.angle, "Angle after rotation Left from West should be 180"
		rover.rotate("L")
		assert_equal 90, rover.angle, "Angle after rotation Left from South should be 90"
		rover.rotate("L")
		assert_equal 0, rover.angle, "Angle after rotation Left from East should be 0"
	end

	def testRotateRightCorrectlyChangesAngle
		grid = Grid.new(Position.new(5, 5))
		rover = Rover.new(1,2,"N", grid)
		assert_equal 0, rover.angle, "Angle of North is 0"
		rover.rotate("R")
		assert_equal 90, rover.angle, "Angle after rotation Right from North should be 90"
		rover.rotate("R")
		assert_equal 180, rover.angle, "Angle after rotation Right from East should be 180"
		rover.rotate("R")
		assert_equal 270, rover.angle, "Angle after rotation Right from South should be 270"
		rover.rotate("R")
		assert_equal 0, rover.angle, "Angle after rotation Right from West should be 0"
	end

end