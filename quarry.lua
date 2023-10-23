-- Global constants
DIR = {
  E = vector.new(1,0,0), S = vector.new(0,0,1), 
  W = vector.new(-1,0,0), N = vector.new(0,0,-1), 
  U = vector.new(0,1,0), D = vector.new(0,-1,0)
}

BLOCK_BLACKLIST = {
  ["computercraft:turtle_normal"] = true,
  ["computercraft:turtle_advanced"] = true,
  ["minecraft:chest"] = true
}

-- Parse commandline arguments
args = {...}
if #args < 2 then
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
    progress_coord = read_vector(log_file)
    curr_coord = read_vector(log_file)

    -- Load booleans
    stringtoboolean={ ["true"]=true, ["false"]=false }
    eff_mode = stringtoboolean[log_file.readLine()]
    hit_bedrock = stringtoboolean[log_file.readLine()]

    -- Read current direction
    local x_dir = tonumber(log_file.readLine())
    local z_dir = tonumber(log_file.readLine())
    curr_dir = vector.new(x_dir,0,z_dir)
  else
    error('Incorrect number of arguments.', 0)
  end
else
  -- If args provided, must be newly placed turtle
  x_size = tonumber(args[1])
  z_size = tonumber(args[2])

  -- Important global coords
  origin_coord = vector.new(0,0,0)        -- Start position of turtle
  shaft_coord = vector.new(0,0,0)         -- Coords of corner of turtle's shaft
  progress_coord = vector.new(0,0,0)      -- Max progress turtle has made in shaft
  curr_coord = vector.new(0,0,0)          -- Current location of turtle

  eff_mode = true          -- If quarry should be in efficient mode (less movement and fuel used)
  hit_bedrock = false      -- If the turtle has finished it's mining operation

  for key, value in pairs(args) do
    if value == '-e' then
      eff_mode = false
    end
  end

  -- Direction it starts facing will be treated as +x
  curr_dir = vector.new(1,0,0)
end

-- Reads a vector from the handle (x,y,z on seperate lines)
function read_vector(handle)
  local x = tonumber(handle.readLine())
  local y = tonumber(handle.readLine())
  local z = tonumber(handle.readLine())
  return vector.new(x,y,z)
end

-- Turn to target_dir, mine and then move there
-- Returns true if success
function move_and_mine(target_dir)
  if target_dir == vector.new(0,1,0) then
    if not mine_up() then
      -- If cannot mine block, return error
      return false
    end
    move_up()
  elseif target_dir == vector.new(0,-1,0) then
    if not mine_down() then
      -- If cannot mine block, return error
      return false
    end
    move_down()
  else
    turn_to_dir(target_dir)
    if not mine_forward() then
      -- If cannot mine block, return error
      return false
    end
    move_forward()
  end

  return true
end

-- Turn to the target_dir
function turn_to_dir(target_dir)
  local turn = 0
  local product = vector.new(curr_dir.x * target_dir.x, curr_dir.y * target_dir.y, curr_dir.z * target_dir.z)

  -- Check if in correct rotation already
  if (curr_dir.x ~= target_dir.x) or (curr_dir.z ~= target_dir.z) then
    if product ~= vector.new(0,0,0) then
      -- Need to turn 180
      turn = 2
    else
      -- Must turn left or right
      local swap = vector.new(target_dir.z, target_dir.y, target_dir.x)
      local swap_product = vector.new(curr_dir.x * swap.x, curr_dir.y * swap.y, curr_dir.z * swap.z)

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

-- Try mining forwards, return true if success
function mine_forward()
  -- Check block isn't in blacklist, then try mining and check if it worked
  repeat
    local has_block, data = turtle.inspect()

    if has_block and not BLOCK_BLACKLIST[data.name] then
      if not turtle.dig() then
        return false
      end
    end

    -- Handle events before sleeping
    sleep(0)
  until not turtle.detect()

  return true
end

-- Try mining upwards, return true if success
function mine_up()
  -- Check block isn't in blacklist, then try mining and check if it worked
  repeat
    local has_block, data = turtle.inspectUp()

    if has_block and not BLOCK_BLACKLIST[data.name] then
      if not turtle.digUp() then
        return false
      end
    end

    -- Handle events before sleeping
    sleep(0)
  until not turtle.detectUp()

  return true
end

-- Try mining downwards, return true if success
function mine_down()
  -- Check block isn't in blacklist, then try mining and check if it worked
  repeat
    local has_block, data = turtle.inspectDown()

    if has_block and not BLOCK_BLACKLIST[data.name] then
      if not turtle.digDown() then
        return false
      end
    end

    -- Handle events before sleeping
    sleep(0)
  until not turtle.detectDown()

  return true
end

-- Try to move forward (and update coords)
function move_forward()
  if turtle.forward() then
    curr_coord = curr_coord + curr_dir
    return true
  end
    return false
end

-- Try to move up (and update coords)
function move_up()
  if turtle.up() then
    curr_coord = curr_coord + DIR['U']
    return true
  end
    return false
end

-- Try to move down (and update coords)
function move_down()
  if turtle.down() then
    curr_coord = curr_coord + DIR['D']
    return true
  end
    return false
end

-- Attempt to mine and move to target_coord
-- Return true if success, false if hit unbreakable block
function move_to_coord(target_coord)
  local diff_vector = target_coord:sub(curr_coord)
  local x_dir = diff_vector.x > 0 and vector.new(1,0,0) or vector.new(-1,0,0)
  local y_dir = diff_vector.y > 0 and vector.new(0,1,0) or vector.new(0,-1,0)
  local z_dir = diff_vector.z > 0 and vector.new(0,0,1) or vector.new(0,0,-1)

  for i = 1, math.abs(diff_vector.x), 1 do
    if not move_and_mine(x_dir) then
      return false
    end
  end

  for i = 1, math.abs(diff_vector.z), 1 do
    if not move_and_mine(z_dir) then
      return false
    end
  end

  for i = 1, math.abs(diff_vector.y), 1 do
    if not move_and_mine(y_dir) then
      return false
    end
  end

  return true
end

-- Maps each position in the shaft to the direction the turtle should move next
-- If turtle in efficient mode changes mapping to every 3rd line
function map_to_dir(coord, x_size, z_size)
  local x = coord.x + 1
  local z = coord.z + 1
  local layer = coord.y

  if eff_mode then
    layer = (coord.y - 1) / 3
    -- If not a main level, move down to a valid main level
    if (coord.y - 1) % 3 ~= 0 then return vector.new(0,-1,0) end
  end

  local layer_even = layer % 2 == 0
  local z_even
  if layer_even then
    z_even = z % 2 ~= 0
  else
    z_even = z % 2 == 0
  end
  local z_size_even = z_size % 2 == 0

  local dir = vector.new(1,0,0)

  -- Reverse direction every second column, also add sideways moves
  if z_even then
    dir = vector.new(-1,0,0)
    if x == 1 then
      dir = vector.new(0,0,1)
    end
  elseif x == x_size then
    dir = vector.new(0,0,1)
  end

  -- End tile check
  if layer_even then
      -- Flip direction of arrow if even y
      dir.z = dir.z * -1
      if x == 1 and z == 1 then
          dir = vector.new(0,-1,0)
      end
  elseif z == z_size and ((z_size_even and x == 1) or (not z_size_even and x == x_size)) then
    dir = vector.new(0,-1,0)
  end

  return dir
end

-- Main function for digging shaft
function dig_shaft()
  -- Continue digging until hit_bedrock
  while not hit_bedrock do
    hit_bedrock = hit_bedrock or not move_and_mine(map_to_dir(curr_coord,x_size,z_size))

    if eff_mode then
      if not mine_up() then
        hit_bedrock = true
        -- When you hit bedrock, move back to previous position
        -- This prevents getting stuck under bedrock
        turn_to_dir(vector.new(-1*curr_dir.x,curr_dir.y,-1*curr_dir.z))
        move_forward()
      end

      hit_bedrock = hit_bedrock or not mine_down()
    end
  end

  -- Move up 2 to clear bedrock
  move_up()
  move_up()

  move_to_coord(shaft_coord)
end

-- Main Program
dig_shaft()
turn_to_dir(DIR['E'])