require_relative "mars_rover"

grid_pos = Readline.readline("Grid> ", true);
grid_x, grid_y = grid_pos.split(/ /)
grid = Grid.new(Position.new(grid_x.to_i, grid_y.to_i))

rovers = Array.new
while buf = Readline.readline("Rover Position> ", true) do
	buf = buf.chomp
	if (buf.empty?)
		break
	end
	moves = Readline.readline("Rover Moves> ", true)
	moves = moves.chomp
	if (moves.empty?)
		raise ArgumentError, "Need to enter moves for Rover"
	end
	rover = Rover.create_rover(buf, grid)
	rovers << [rover, moves]
end

rovers.each do |rover, moves|
	puts "Starting to Move Rover @ #{rover.to_str}"
	moves_arr = moves.split(//)
	moves_arr.each do |m|
		if (m == "M")
			rover.move()
		else
			rover.rotate(m)
		end
	end
	puts "#{rover.position.x} #{rover.position.y} #{rover.heading}"
end