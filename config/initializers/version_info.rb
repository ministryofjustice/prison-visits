VERSION_INFO = \
begin
  JSON.parse(File.read('META'))
rescue Errno::ENOENT
  {}
end
