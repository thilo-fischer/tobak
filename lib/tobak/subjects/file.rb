#
# tobak is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# tobak is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with tobak.  If not, see <http://www.gnu.org/licenses/>.

require 'tobak/subjects/subject'

module Tobak::Subjects

  class File < Subject
    
    attr_reader :path
    
    def initialize(volume, path)
      @volume = volume
      @path = path
    end

    def path_on_volume
      unless @path_on_volume
        abs_path = File.abs_path(path)
        abs_vol_path = volume.abs_path_to_volume
        raise unless abs_path.start_with?(abs_vol_path)
        # note: volume.abs_path_to_volume ends with a File::SEPARATOR
        @path_on_volume = abs_path[abs_vol_path.length .. -1]
      end
      @path_on_volume 
    end # def path_on_volume
    
    def igore?
      # TODO ignore files exceeding size threshold
      # TODO ignore lists (similar to .gitignore)
      
      # Symlinks will not be resolved, but handled directly.
      # => Symlinks shall not be resolved, but handled directly as
      # symlinks. Thus they shall not be ignored even if the files
      # they link to would be ignored. As File.file? resoves symlinks,
      # take file into account if File.file? or File.symlink?
      return true unless File.symlink?(@path) or File.file?(@path)
      
      return true if meta.stat.dev != @volume.device_id
                         
      false
    end # def ignore?
    
    def checksum
      # FIXME compute checksum using Ruby libraries instead of using shasum command line tool
      @checksum ||= %x{shasum -b "#{@path}"}.split(/\s/)[0]
    end # def checksum

    def stat
      @stat ||= File.lstat(@path)
    end # def stat
    
    def meta
      {
        :checksum => checksum,
        :stat => stat,
        :path => path_on_volume,
      }
    end # def meta

    def integrate(repo)
      repo.add(self)
    end
    
  end # class SourceFile


end # module Tobak::Subjects
