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

require 'optparse'

#require 'tobak/session/options'

##
# User Interface Implementation
module Tobak::Ui

  class Resource
    attr_accessor :name, :root, :comment, :volumes, :path
    def initialize
      @volumes = [ Volume.new ]
    end
  end

  class Volume
    attr_accessor :name, :root, :comment, :path
  end

  ##
  # Parses the command line arguments passed to the tobak program at invocation
  class CommandLineParser

    # XXX query options through explicit getter methods instead of direct hash access
    attr_reader :destination, :resources, :options, :arguments

    def initialize
      @destination = nil
      @options = {}
      @resources = [ Resource.new ]
    end
    

    def parse
      
      option_parser = OptionParser.new do |opts|

        opts.banner =
          "Usage: #{File.basename $0} --destination=<path> [ --tag=<sessiontag> ] ( resource-options ( <path-to-resource> | ( volume-options <path-to-volume> ... ) ) ... )"

        opts.separator ""
      opts.separator "resource-options:"
      opts.separator "( --resource-name=<name> | --autoresname ) ( --resroot=<path> | --autoresroot ) [ --rescomment=<description> | --rescomment-file=<path> ]"

      opts.separator ""
      opts.separator "volume-options:"
      opts.separator "( --volume-name=<name> | --autovolname ) ( --volroot=<path> | --autovolroot ) [ --volcomment=<description> | --volcomment-file=<path> ]
"

      opts.separator ""
      opts.separator "Session options:"

      opts.on("-dPATH",
                "--destination=PATH",
                "The directory where to find an existing or create a new tobak backup file structure to which to add the files being backed up.") do |arg|
          @destination = arg
        end

        opts.on("--tag=sessiontag",
                "Use the given string instead of the timestamp to name this tobak session. Shall be a string that is easy to handle as a file name (e.g. no special characters like '/' or ':'). The default used when no tag option is given is the time and date of the tobac program start in the format YYYY-MM-DD_hh-mm.") do |arg|
          @options[:tag] = arg
        end


      opts.separator ""
      opts.separator "Resource Options:"

      opts.on("-rRESNAME",
                "--resourcename=RESNAME",
                "Identifier refering to the resource from which to import the files into the repository.") do |arg|
          raise if @resources.last.name
          @resources.last.name = arg
        end

        opts.on("--autoresname",
                "Let tobak automatically guess a resource name.") do
          raise if @resources.last.name
          @resources.last.name = :auto
        end

      opts.separator ""
      opts.separator "Volume Options:"

        opts.on("-vVOLNAME",
                "--volumename=VOLNAME",
                "Identifier refering to the volume of the resource from which to import the files into the repository.") do |arg|
          raise if @resources.last.volumes.last.name
          @resources.last.volumes.last.name = arg
        end

        opts.on("--autovolname",
                "Let tobak automatically guess a volume name.") do
          raise if @resources.last.volumes.last.name
          @resources.last.volumes.last.name = :auto
        end


      opts.separator ""
      opts.separator "Common options:"

      opts.on_tail("-h", "--help", "Prints this help") do
        puts opts
        exit
      end

      opts.on_tail("--version", "Show version") do
        puts Tobak::VERSION
        exit
      end

      end # OptionParser.new

      option_parser.order(ARGV) do |arg|
        if @resources.last.volumes.last.name
          raise if @resources.last.volumes.last.path
          @resources.last.volumes.last.path = arg
          @resources.last.volumes << Volume.new
        else
          raise unless @resources.last.name
          raise if @resources.last.path
          @resources.last.path = arg
          @resources << Resource.new
        end
      end

    end # def parse
    
  end # class CommandLineParser

end # module Tobak::Ui
