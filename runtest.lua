args = {...}
if #args ~= 2 then
  error('Incorrect number of arguments.', 0)
end

shell.run('delete', args[2])
shell.run('pastebin get', args[1], args[2])
shell.run(args[2])