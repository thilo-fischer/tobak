# Steps containing the word "shall" usually define steps that just
# observe and test current conditions. They usually don't have any
# side effects (appart from setting scenario-local variables to chain
# several of these steps). Thier typical applications is to be used in
# the `Then' part of the scenarios.
#
# Steps not containing the word "shall" usually define steps that take
# actions like setting up test conditions or calling the system under
# test. They usually have side effects (like files in the test
# directories being removed or created). Thier typical applications is
# to be used in the `Given' and `When' part of the scenarios.

Given(/^the testing repositories' root will be "([^"]*)"$/) do |repo_root|
  @repo_root = repo_root
  Dir.exist?(File.basename(@repo_root))
end

Given(/^a virtual resource "([^"]*)" can be found at "([^"]*)"$/) do |res_name, res_path|
  @resources[res_name] = res_path
  # TODO ensure res_path is a mountpoint
end

Given(/^the virtual resource has these volumes:$/) do |table|
  # table is a Cucumber::MultilineArgument::DataTable
  # TODO
end

Given(/^an empty test repository directory$/) do
  #Dir.entries(@repo_root).empty?
  if Dir.exist?(@repo_root)
    FileUtils.rm_r(@repo_root)
  end
  Dir.mkdir_p(@repo_root)
end

Given(/^a fresh target repository$/) do
  steps %Q(
    Given an empty test repository directory
    When I successfully run `tobak --destination="#{@destination}"`
  )
end

#Given(/^a clean recource directory "([^"]*)"$/) do |res_dir|
#  # strip the leading resource identifier from res_dir
#  @recent_resname = res_dir.slice!(/\w+\//)
#  @recent_resname.chop! # strip trailing '/'
#  path = File.join(@resources[res_name], res_dir)
#  
#end

Given(/^a clean recource directory "([^"]*)"$/) do |resname|
  @recent_resname = resname
  @recent_dir = @resources[@recent_resname]
  Dir.exist?(@recent_dir)
  Dir.entries(@recent_dir).empty?
end

Given(/^the directory contains$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  tabele.hashes.each do |row|
    path = File.join(@recent_dir, row[file_name])
      
    raise "must provide type info" unless row.key?("type")
      
    case row["type"]
    when /^file$/i, "f"
      
      File.open("path", "w") do |f|
        f.write(row["content"]) if row.key?("content")
      end
      
    when /^directory$/i, /^dir$/i, "f"
      
      Dir.mkdir_p(path)
      
      raise "`content' not supported for directories" if row.key?("content") and not row["content"].empty?
      
    else
      raise "unknown type: `#{row["type"]}'"
    end # type
  end # each row
end

Then(/^a file named "([^"]*)" shall exist$/) do |path|
  @recent_file = path
  #File.exist?(path)
  File.file?(path)
end

Then(/^the file shall contain "([^"]*)"$/) do |content|
  content == File.read(@recent_filename)  
end

Then(/^a directory named "([^"]*)" shall exist$/) do |path|
  @recent_dir = path
  Dir.exist?(path)
end

Then(/^these directories shall exist$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  tabele.hashes.all? do |row|
    path = File.join(@repo_root, row[dir_name])
    next false if not Dir.exist?(path)
    if row.key?("empty")
      case row["empty"]
      when ""
        nil
      when /^true$/i, "t"
        next false if not Dir.entries(path).empty?
      when /^false$/i, "f"
        next false if Dir.entries(path).empty?
      else
        raise
      end
    end
    # ...
  end
end

Then(/^the directory shall contain a file "([^"]*)"$/) do |filename|
  path = File.join(@recent_dir, filename)
  File.file?(path)
end

Then(/^the directory shall contain a symlink "([^"]*)" to "([^"]*)"$/) do |filename, target|
  path = File.join(@recent_dir, filename)
  return false unless File.symlink?(path)
  
  return true if File.readlink(path) == target
  return true if File.absolute_path(File.readlink(path), dirname(path)) == File.absolute_path(target)
  return true if File.realpath(File.readlink(path), dirname(path)) == File.realpath(target)

  false
end

Then(/^the directory shall contain$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  tabele.hashes.all? do |row|
    path = File.join(@recent_dir, row[element_name])
    next false if not File.exist?(path)
    if row.key?("type")
      
      case row["type"]
      when /^file$/i, "f"

        next false if File.ftype(path) != "file"

        if row.key?("empty")
          case row["empty"]
          when ""
            nil
          when /^true$/i, "t"
            next false if not File(path).zero?
          when /^false$/i, "f"
            next false if File(path).zero?
          else
            raise
          end
        end

        next false if row.key?("content") and File.read(path) != row["content"]

      when /^directory$/i, /^dir$/i, "f"

        next false if File.ftype(path) != "directory"

        if row.key?("empty")
          case row["empty"]
          when ""
            nil
          when /^true$/i, "t"
            next false if not Dir.entries(path).empty?
          when /^false$/i, "f"
            next false if Dir.entries(path).empty?
          else
            raise
          end
        end

        raise "`content' not supported for directories" if row.key?("content") and not row["content"].empty?

      else
        raise "unknown type: `#{row["type"]}'"
      end
    end
    # ...
  end
end

Then(/^the file shall be identical to "([^"]*)"$/) do |other_file|
  File.read(@recent_file) == File.read(other_file)
end
