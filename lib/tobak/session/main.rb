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

##
# Things related to the currently running program instance.
module Tobak::Session  

  class Main

    include Singleton

    def run
      @starttime = Time.new

      @commandline = $ARGV.dup

      @cmdlineparser = Tobak::Ui::CommandLineParser.new
      @cmdlineparser.parse
      
      #puts @cmdlineparser.inspect

      raise unless @cmdlineparser.destination
      @repo = Tobak::Repo::Repository.new(@cmdlineparser.destination)
      @repo.prepare

      if @cmdlineparser.options.include?(:tag)
        tag = @cmdlineparser.options[:tag]
      else
        tag = nil
      end

      session = Session.new(@repo, @commandline, @starttime, @tag)
      session.setup

      @cmdlineparser.resources.each do |res|

        if res.name == :auto
          resname = "misc" # XXX
        else
          resname = res.name
        end
        
        resdir = File.join(destdir, resname, timestamp)
        raise "Already exists: `#{resdir}'. Aborting." if File.exist?(resdir)
        Dir.mkdir(resdir)
        
        reslog_filename = "#{resdir}.log"
        resmeta_filename = "#{resdir}.meta"

        File.open(resmeta_filename, 'a') do |f|
          # TODO use YAML
          f.puts("$0 session")
          f.puts(" started at #{starttime} (timestamp: #{timestamp})")
          f.puts(" started by #{%x{whoami}}")
          f.puts(" running on #{%x{hostname}} (#{%x{uname -a}})")
          f.puts(" running as process #{$$}")
        end

        if res.path
          raise "not yet implemented"
        else
          res.volumes.each do |v|

            volpath = File.realpath(v.path)
            raise unless File.exist?(volpath)

            if v.name == :auto
              volname = File.basename(volpath) # XXX
            else
              volname = v.name
            end
            
            voldir = File.join(resdir, volname)
            raise "Already exists: `#{voldir}'. Aborting." if File.exist?(voldir)
            Dir.mkdir(voldir)
            
            vollog_filename = "#{voldir}.log"
            volmeta_filename = "#{voldir}.meta"

            File.open(volmeta_filename, 'a') do |f|
              f.puts(" mounted like #{%x{mount -l | grep #{volpath}}}")
              f.puts(" used like #{%x{df #{volpath}}} (#{%x{df -h #{volpath}}}), #{%x{df -i #{volpath}}}")
            end


            # TODO take care of symlinks
            
            open("|find \"#{volpath}\" -print0") do |findstream|
              findstream.each("\0") do |file|

                # TODO check if file already exists in the most recent backup of resource
                #       `-> check if file modification date changed
                #       `-> if not changed: write only file metadata changes (if any) or write no-change note to metadata record
                
                if (file.ignore?)
                  # TODO log I
                else
                  repo.add(file)
                end
                           
              end # each file found
              
            end # findstream
            
          end # volume
          
        end # resource with volumes
        
      end # resource

      system("sync")
      # TODO log "Successfully completed at #{Time.new}."

    end # def run

  end # class Main

end # module Tobak::Session
