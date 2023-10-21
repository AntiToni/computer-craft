args = {...}
if #args ~= 1 and #args ~= 2 and #args ~= 4 then
  error('Incorrect number of arguments.', 0)
end

shell.run('delete', args[1])
shell.run('pastebin get', 'VDCFXjGQ', args[1])

if args[2] == '-r' then
  if #args == 4 then
    shell.run(args[1], args[3], args[4])
  else
   shell.run(args[1])
  end
end