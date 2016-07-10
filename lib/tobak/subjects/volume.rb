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

    def initialize(resource, path_to_volume, name, description = nil)
      @resource = resource
      @path_to_volume = Tobak.Helper.with_final_separator(path_to_volume)
      @name = name
      @description = description
    end # def initialize

    def device_id
      @device_id ||= File.stat(File.join(@path_to_volume, ".")).dev
    end # def device_id

    def abs_path_to_volume
      @abs_path_to_volume ||= File.abs_path(@path_to_volume)
    end # abs_path_to_volume
    
  end # class SourceVolume

end # module Tobak::Subjects
