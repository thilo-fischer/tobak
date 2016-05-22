destination = ARG(--destination)
resource = ARG(--resource) || "misc"
timestamp = ARG(--timestamp) || strftime('%F_%R').gsub(':', '-')
volume = ARG(--volume) || ""

hashes_dir = "#{destination}/hashes"

target_dir = "#{destination}/#{resource}/#{timestamp}"
target_dir += "/#{volume}" unless volume.empty?

logfile = #{target_dir}.log

df -h
uname -a
whoami
$$
      >> #{target_dir}.meta

ARGV.each do |filename|
  raise "File not found" unless File.exist?(filename)
  checksum = ...(filename)
  hash_path = hashes_dir + filename
  unless File.exist?(hash_path)
    cp filename hash_path
  end
  ln hash_path "#{target_dir}/#{filename}"
  
  meta = 
    * checksum
	** filename (escape newline characters)
	*** timestamp
    ls -l filename
	
  meta >> "#{hash_path}.meta"
end
