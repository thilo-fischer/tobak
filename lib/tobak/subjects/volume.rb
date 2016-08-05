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

  class Volume < Subjects
    
    attr_reader :name, :description

    def initialize(name, path, root = nil, description = nil)
      @name = name
      @path = Tobak::Helper.with_final_separator(path)
      @root = root || real_path
      @description = description
    end # def initialize

    def prepare(resource_session)
      raise unless real_path.start_with?(@root) # TODO check if @root is mount point of @path
      
      vol_dir = resource_session.volume_dir(@name)

      @content_dir = File.join(vol_dir, 'content')
      FileUtils.mkdir(@content_dir)
      @cmeta_dir = File.join(vol_dir, 'cmeta')
      FileUtils.mkdir(@cmeta_dir)
      
      File.open(File.join(vol_dir, 'meta')) do |f|
        f.puts(meta.to_yaml)
      end

      log_dir = File.join(vol_dir, 'log')
      # TODO logfiles general, integrated, ignored, warnings, errors, summary, ...
    end # def prepare
    
    def meta
      {
        :name => @name,
        :description => @description,
        :path => @path,
        :real_path => real_path,
        :mountpoint => @root,
        :device_id => device_id,
        :file_system => nil, # TODO
        :df => %x{df "#{@path}"}, # TODO
        :df_h => %x{df -h "#{@path}"}, # TODO
        # ... => TODO
      }
    end # def meta
    
    def device_id
      @device_id ||= File.stat(File.join(@path, ".")).dev
    end # def device_id

    #def abs_path_to_volume
    #  @abs_path_to_volume ||= File.abs_path(@path_to_volume)
    #end # abs_path_to_volume
    
    def real_path
      @real_path ||= File.real_path(@path)
    end # real_path
    
  end # class SourceVolume

end # module Tobak::Subjects
