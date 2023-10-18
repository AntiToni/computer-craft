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
    curr_coord = read_vector(log_file)

    -- Read current direction
    local x_dir = log_file.readLine()
    local z_dir = log_file.readLine()

    direction = {x = x_dir, z = z_dir}
  end
    
  error('Incorrect number of arguments.', 0)
end

function read_vector(handle)
  local x = handle.readLine()
  local y = handle.readLine()
  local z = handle.readLine()
  return vector:new(x,y,z)
end