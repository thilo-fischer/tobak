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

#require 'tobak/session/logging'
#require 'tobak/session/options'
require 'tobak/ui/cmdlineparser'

##
# Things related to the currently running program instance.
module Tobak::Session  

  # FIXME move to appropriate package and file
  class Session

    attr_reader :repository, :commandline, :starttime
    
    def initialize(repository, commandline, starttime = Time.new, tag = nil)
      @repository = repository
      @commandline = commandline
      @starttime = starttime
      @tag = tag || starttime_str
      setup
    end

    def starttime_str
      @starttime.strftime('%F_%R').gsub(':', '-')
    end

    def setup
      @meta_file_path = @repo.session_meta_path(@tag)
      if File.exist?(@meta_file_path)
        alt_tag_counter = 1
        while (File.exist?(@meta_file_path + "_" + alt_tag_counter.to_s))
          alt_tag_counter += 1
        end
        @tag = @tag + "_" + alt_tag_counter.to_s
        @meta_file_path = @repo.session_meta_path(@tag)
      end

      File.open(@meta_file_path, "a") do |f|
        f.puts(meta.to_yaml)
      end

      @log_file_path = @repo.session_log_path(@tag)
      raise if File.exist?(@log_file_path)
      @log_file = File.open(@log_file_path, "a")

      @log_file.puts("Session started at #{@starttime}.")
    end

    def teardown
      @log_file.puts("Session finished at #{Time.new}.")
      @log_file.close
    end
    
    def meta
      # TODO move some information from meta to log?
      {
        :tag => @tag,
        :starttime => @starttime,
        :commandline => @commandline,
        :user => %x{whoami},
        :pid => Process.pid,
        :host => %x{hostname} + ": " + %x{uname -a}
      }
    end
    
  end # class Session
      
end # module Tobak::Session
