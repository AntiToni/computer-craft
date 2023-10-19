-- Parse commandline arguments
args = {...}
if #args ~= 2 then
  if #args == 0 then
    -- If no args then read from file
    local log_file = fs.open("quarry.log", "r")
    local line = log_file.readLine()

    -- Check if file is a real save
    if line ~= 'SAVE' then
      error('No log file and no arguments provided.', 0)
    end

    -- Read parameters of quarry size
    x_size = log_file.readLine()
    z_size = log_file.readLine()

    -- Read coordinates
    origin_coord = read_vector(log_file)
    shaft_coord = read_vector(log_file)
    curr_coord = read_vector(log_file)

    -- Read current direction
    local x_dir = log_file.readLine()
    local z_dir = log_file.readLine()
    curr_dir = vector.new(x_dir,0,z_dir)
  else
    error('Incorrect number of arguments.', 0)
  end
else
  -- If args provided, must be newly placed turtle
  x_size = tonumber(args[1])
  z_size = tonumber(args[2])

  -- Origin is starting position, shaft is corner of it's shaft, curr is current position
  origin_coord = vector.new(0,0,0)
  shaft_coord = vector.new(0,0,0)
  curr_coord = vector.new(0,0,0)

  -- Direction it starts facing will be treated as +x
  curr_dir = vector.new(1,0,0)
end

function read_vector(handle)
  local x = handle.readLine()
  local y = handle.readLine()
  local z = handle.readLine()
  return vector.new(x,y,z)
end

function move_and_mine(move_dir)

end

function turn_to_dir(target_dir)
  local turn = 0
  local product = curr_dir:dot(target_dir)

  -- Check if in correct rotation already
  if curr_dir.x ~= target_dir.x or curr_dir.z ~= target_dir.z then
    if product ~= vector.new(0,0,0) then
      -- Need to turn 180
      turn = 2
    else
      -- Must turn left or right
      local swap = vector.new(target_dir.z, target_dir.y, target_dir.x)
      local swap_product = curr_dir:dot(swap)

      turn = swap_product.x - swap_product.z
    end
  end

  -- Make turns
  while turn > 0 do
    turtle.turnRight()
    turn = turn - 1
  end
  while turn < 0 do
    turtle.turnLeft()
    turn = turn + 1
  end

  -- Update current direction
  curr_dir = vector.new(target_dir.x, 0, target_dir.z)
end

function map_to_dir(x, y, z, x_size, z_size)
  
end

-- Main Program
