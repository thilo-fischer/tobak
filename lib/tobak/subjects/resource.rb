# -*- coding: utf-8 -*-

# Copyright (c) 2016  Thilo Fischer.
#
# This file is part of tobak.
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

  class Resource < Subject
    attr_reader :name, :description
    def initialize(name, description = nil)
      @name = name
      @description = description
    end

    def prepare(session)
      @respath = session.repository.resource_path(self)
      FileUtils.mkdir(@respath) unless File.directory?(@respath)

      # FIXME @sesspath, @vol_dir etc. should be session specific
      
      @sesspath = File.join(@respath, session.tag)
      raise if File.directory?(@sesspath)
      FileUtils.mkdir(@sesspath)

      @vol_dir = File.join(@sessdir, 'volumes')
      FileUtils.mkdir(@vol_dir)

      meta_dir = File.join(@sessdir, 'meta')
      File.link(session.meta_file_path, File.join(meta_dir, session))
      File.open(File.join(meta_dir, 'resource')) do |f|
        f.puts(meta.to_yaml)
      end

      log_dir = File.join(@sessdir, 'log')
      File.link(session.log_file_path, File.join(log_dir, session))
      # FIXME logfiles general, warnings, errors, summary, ...
   end

    def meta
      {
        :name => @name,
        :description => @description,
      }
    end
  end

end # module Tobak::Subjects
