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

  module Helper

    ##
    # If +path+ ends with +File::SEPARATOR+, return path;
    # if not, return +path+ with appended +File::SEPARATOR+.
    def with_final_separator(path)
      File.join(path, "")
    end
    
  end # module Helper

  class SourceResource
  end # class Resource

  class SourceVolume
    
    def initialize(resource, path_to_volume)
      @resource = resource
      @path_to_volume = Helper.with_final_separator(path_to_volume)
    end # def initialize

    def device_id
      @device_id ||= File.stat(File.join(@path_to_volume, ".")).dev
    end # def device_id

    def abs_path_to_volume
      @abs_path_to_volume ||= File.abs_path(@path_to_volume)
    end # abs_path_to_volume
    
  end # class SourceVolume

  class SourceFile
    
    attr_reader :path
    
    def initialize(volume, path)
      @volume = volume
      @path = path
    end

    def path_on_volume
      unless @path_on_volume
        abs_path = File.abs_path(path)
        abs_vol_path = volume.abs_path_to_volume
        raise unless abs_path.start_with?(abs_vol_path)
        # note: volume.abs_path_to_volume ends with a File::SEPARATOR
        @path_on_volume = abs_path[abs_vol_path.length .. -1]
      end
      @path_on_volume 
    end # def path_on_volume
    
    def igore?
      # TODO ignore files exceeding size threshold
      # TODO ignore lists (similar to .gitignore)
      
      # Symlinks will not be resolved, but handled directly.
      # => Symlinks shall not be resolved, but handled directly as
      # symlinks. Thus they shall not be ignored even if the files
      # they link to would be ignored. As File.file? resoves symlinks,
      # take file into account if File.file? or File.symlink?
      return true unless File.symlink?(@path) or File.file?(@path)
      
      return true if meta.stat.dev != @volume.device_id
                         
      false
    end # def ignore?
    
    def checksum
      @checksum %x{shasum -b "#{@path}"}.split(/\s/)[0]
    end # def checksum

    def stat
      File.lstat(@path)
    end # def stat
    
    def meta
      {
        :checksum => checksum,
        :stat => stat,
        :path => path_on_volume,
      }
    end # def meta

    def integrate(repo)
      repo.add(self)
    end
    
  end # class SourceFile

  class Repository

    attr_reader :path

    def initialize(path)
      @path = with_final_separator(path)
      @hashes = RepoHashes.new(self)
    end

    def add(file)
      xxxxx

    end
 
  end # class Repository

  class RepoHashes

    def initialize(repository)
      @repository = repository
    end

    def hash_to_path(hash)
      elements = [ @repository.path, hash[0..1], hash[2..3], hash ]
      File.join(elements)
    end

    def exist?(hash)
      File.exist?(hash_to_path(hash))
    end

  end class RepoHashes
  
# XXXXXXXXXXXXXXXXXXXXXXXXXXXX
  
  # FIXME move to appropriate package and file
  class ResourceMeta
    attr_reader :name, :description
    def initialize(name, description = nil)
      @name = name
      @description = description
    end
  end

  # FIXME move to appropriate package and file
  class SessionMeta
    attr_reader :destination, :commandline, :starttime, :comment
    def initialize(destination, starttime = Time.new, tag = nil)
      @destination = destination
      @commandline = $ARGV
      @starttime = starttime
      @tag = tag || starttime_str
    end
    def starttime_str
      @starttime.strftime('%F_%R').gsub(':', '-')
    end
  end

  # FIXME move to appropriate package and file
  class VolumeMeta
    attr_reader :name, :description
    def initialize(name, description = nil)
      @name = name
      @description = description
    end
  end

  # FIXME move to appropriate package and file
  class FileMeta
    attr_reader :hash, :stat
    def initialize(filename, hash = nil)
      @hash = hash || filehash(filename)
      @stat = File.lstat(filename)
    end
  end

  class Session

    include Singleton

    def run
      starttime = Time.new

      @cmdlineparser = Tobak::Ui::CommandLineParser.new
      @cmdlineparser.parse
      
      puts @cmdlineparser.inspect

      raise unless @cmdlineparser.destination

      if @cmdlineparser.options.include?(:timestamp)
        # XXX rename timestamp -> tag ?
        timestamp = @cmdlineparser.options[:timestamp]
      else
        timestamp = starttime.strftime('%F_%R').gsub(':', '-')
      end

      destdir = @cmdlineparser.destination
      raise unless File.exist?(destdir)

      session_meta = SessionMeta.new(destdir, starttime, timestamp)

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
                  #f.puts(" properties #{%x{ls -l #{file}}}")
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
