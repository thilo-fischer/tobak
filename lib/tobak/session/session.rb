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

      raise unless @cmdlineparser.destination

      starttime = Time.new
      if @cmdlineparser.options.include?(:timestamp)
        timestamp = @cmdlineparser.options[:timestamp]
      else
        timestamp = starttime.strftime('%F_%R').gsub(':', '-')
      end


      destdir = @cmdlineparser.destination
      raise unless File.exist?(destdir)

      hashdir = File.join(destdir, "hashes")
      Dir.mkdir(hashdir) unless File.exist?(hashdir)

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
                # FIXME strip volpath from file where necessary

                # TODO check if filesize is below threshold
                #       `-> log if file is being skipped

                # TODO check if file already exists in the most recent backup of resource
                #       `-> check if file modification date changed
                #       `-> if not changed: write only file metadata changes (if any) or write no-change note to metadata record
                
                puts "#{file}"
                hash = %x{shasum -b "#{file}"}.split(/\s/)[0]
                puts "#{file} :: #{hash}"

                hashpath = File.join(hashdir, hash) # TODO create subdirectories of hashdir

                unless File.exist?(hashpath)
                  # TODO log "Add new file `file'."
                  system("cp \"#{file}\" \"#{hashpath}\"") # XXX copy using ruby command?
                else
                  # TODO log "Add link for known file `file'."
                  # TODO if command line option "--paranoid" was given, test File.identical?
                end

                File.link(hashpath, File.join(voldir, file))

                File.open("#{hashpath}.meta", 'a') do |f|
                  # TODO use YAML
                  f.puts("#{resname}/#{timestamp}/#{volname} : #{file}")
                  f.puts(" properties #{%x{ls -l #{file}}}")
                  f.puts(File.lstat(file))
                end # hash.meta
                
              end # each file found
              
            end # findstream
            
          end # volume
          
        end # resource with volumes
        
      end # resource

      system("sync")
      # TODO log "Successfully completed at #{Time.new}."

    end # def run
    
  end # class Session
      
end # module Tobak
