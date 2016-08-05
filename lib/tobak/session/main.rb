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

      @cmdlineparser.resources.each do |res_param|

        if res_param.name == :auto
          resname = "misc" # XXX
        else
          resname = res_param.name
        end

        res_obj = Tobak::Subjects::Resource.new(resname, res_param.comment)
        res_session = res_obj.prepare(session)

        res.volumes.each do |vol_param|
          
          if vol_param.name == :auto
            volname = Tobak::Subjects::Volume.name_from_path(vol_param.path)
          else
            volname = vol_param.name
          end

          vol_obj = Tobak::Subjects::Volume.new(volname, vol_param.path, vol_param.root, vol_param.comment)
          vol_obj.prepare(res_session)

            volpath = File.realpath(vol_.path)
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
