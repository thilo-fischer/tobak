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

  class Volume
    attr_accessor :location, :source, :options
    def initialize
      @location = nil
      @source = nil
      @options = {}
    end
  end

  ##
  # Parses the command line arguments passed to the tobak program at invocation
  class CommandLineParser

    
    # XXX query options through explicit getter methods instead of direct hash access
    attr_reader :repo, :volumes, :options, :arguments

    
    def initialize
      @repo = nil
      @options = {}
      @volumes = []
    end

    
    def parse
      
      option_parser = OptionParser.new do |opts|

        opts.banner =
          "Usage: #{File.basename $0} [ --repo=<path> ] ( --init-repo | [ --tag[=<sessiontag>] | --no-tag ] ( --volume=<path-in-repo> --source=<path> [volume-options] | --vol-recurs=<path-in-repo> | --resource=<path-in-repo> ) ... )"

        opts.separator ""
        opts.separator "volume-options:"
        opts.separator "[ --autoname ] [ --comment=<description> | --comment-file=<path> ]"

        opts.separator ""
        opts.separator "Session options:"

        opts.on("--repo=PATH",
                "The directory where to find an existing or create a new tobak repository file structure.") do |arg|
          @repo = arg
        end
        
        opts.on("--init-repo[=PATH]",
                "Set up a tobak repository at the give path or (if no path is given here ) at the pass given with the --repo command line option.") do |arg|
          @options[:init_repo] = arg
        end
        
        opts.on("--tag[=sessiontag]",
                "Use the string given as <sessiontag> instead of the timestamp to name this tobak session. Shall be a string that is easy to handle as a file name (e.g. no special characters like '/' or ':'). The default used when no tag option is given is the time and date of the tobac program start in the format YYYY-MM-DD_hh-mm. String will be interpreted as a strftime format string. If no <sessiontag> argument is given, just overrides a previously given --no-tag option.") do |arg|
          @options[:tag] = arg
        end

        opts.separator ""
        opts.separator "Volume Options:"

        opts.on("-vVOLUME",
                "--volume=VOLUME",
                "Reference to the representation inside the repository of a volume to be backed up.") do |arg|
          @volumes.push_back(Volume.new)
          @volumes.last.location = arg
        end

        opts.on("--source=PATH",
                "Path to the original volume to be backed up.") do |arg|
          raise "wrong command line syntax" if @volumes.empty?
          @volumes.last.source = arg
        end

        opts.on("--autoname",
                "Let tobak automatically guess a volume name.") do
          raise "wrong command line syntax" if @volumes.empty?
          @volumes.last.options[:autoname] = true
        end

        opts.on("--comment=DESCRIPTION",
                "Store this description of the volume in the volume's meta data in the repository.") do
          raise "wrong command line syntax" if @volumes.empty?
          @volumes.last.options[:comment] = arg
        end

        opts.on("--comment-file=PATH",
                "Store the text found in the given file as the volume's description in the volume's meta data in the repository.") do
          raise "wrong command line syntax" if @volumes.empty?
          @volumes.last.options[:comment_file] = arg
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
        raise "wrong command line syntax"
      end

    end # def parse
    
  end # class CommandLineParser

end # module Tobak::Ui
