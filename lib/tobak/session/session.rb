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

require 'singleton'

#require 'tobak/session/logging'
#require 'tobak/session/options'
require 'tobak/ui/cmdlineparser'

##
# Things related to the currently running program instance.
module Tobak::Session

  class Session

    include Singleton

    def run
      @cmdlineparser = Tobak::Ui::CommandLineParser.new
      @cmdlineparser.parse
      puts @cmdlineparser.inspect

    #destination = ARG(--destination)
    #resource = ARG(--resource) || "misc"
    #timestamp = ARG(--timestamp) || strftime('%F_%R').gsub(':', '-')
    #volume = ARG(--volume) || ""
    #
    #hashes_dir = "#{destination}/hashes"
    #
    #target_dir = "#{destination}/#{resource}/#{timestamp}"
    #target_dir += "/#{volume}" unless volume.empty?
    #
    #logfile = #{target_dir}.log
    #
    #  df -h
    #uname -a
    #whoami
    #$$
    #>> #{target_dir}.meta
    #
    #ARGV.each do |filename|
    #  raise "File not found" unless File.exist?(filename)
    #  checksum = ...(filename)
    #  hash_path = hashes_dir + filename
    #  unless File.exist?(hash_path)
    #    cp filename hash_path
    #  end
    #  ln hash_path "#{target_dir}/#{filename}"
    #  
    #  meta = 
    #    * checksum
    #  ** filename (escape newline characters)
    #  *** timestamp
    #  ls -l filename
    #  
    #  meta >> "#{hash_path}.meta"
    #end

    end # def run
    
  end # class Session
      
end # module Tobak
