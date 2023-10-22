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

  eff_mode = false          -- If quarry should be in efficient mode (less movement and fuel used)
  hit_bedrock = false      -- If the turtle has finished it's mining operation

  -- Direction it starts facing will be treated as +x
  curr_dir = vector.new(1,0,0)
end

function read_vector(handle)
  local x = tonumber(handle.readLine())
  local y = tonumber(handle.readLine())
  local z = tonumber(handle.readLine())
  return vector.new(x,y,z)
end

function move_and_mine(move_dir)
  local has_block = true
  local data = nil

  if move_dir == vector.new(0,1,0) then
    -- Check block isn't in blacklist, then try mining and check if it worked
    repeat
      has_block, data = turtle.inspectUp()

      if has_block and not BLOCK_BLACKLIST[data.name] then
        if not turtle.digUp() then
          return false
        end
      end

      -- Handle events before sleeping
      sleep(0)
    until not turtle.detectUp()
    move_up()
  elseif move_dir == vector.new(0,-1,0) then
    -- Check block isn't in blacklist, then try mining and check if it worked
    repeat
      has_block, data = turtle.inspectDown()

      if has_block and not BLOCK_BLACKLIST[data.name] then
        if not turtle.digDown() then
          return false
        end
      end

      -- Handle events before sleeping
      sleep(0)
    until not turtle.detectDown()
    move_down()
  else
    turn_to_dir(move_dir)
    
    -- Check block isn't in blacklist, then try mining and check if it worked
    repeat
      has_block, data = turtle.inspect()

      if has_block and not BLOCK_BLACKLIST[data.name] then
        if not turtle.dig() then
          return false
        end
      end

      -- Handle events before sleeping
      sleep(0)
    until not turtle.detect()
    move_forward()
  end

  return true
end

function turn_to_dir(target_dir)
  local turn = 0
  local product = vector.new(curr_dir.x * target_dir.x, curr_dir.y * target_dir.y, curr_dir.z * target_dir.z)
  print('CURR')
  print(curr_dir)
  print('TARGET')
  print(target_dir)
  print('DOT')
  print(product)

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

  print(turn)

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

function move_forward()
  curr_coord = curr_coord + curr_dir
  turtle.forward()
end

function move_up()
  curr_coord = curr_coord + DIR['U']
  turtle.up()
end

function move_down()
  curr_coord = curr_coord + DIR['D']
  turtle.down()
end

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

-- Main Program
for i = 1, 10, 1 do
  move_and_mine(map_to_dir(curr_coord,x_size,z_size))
end