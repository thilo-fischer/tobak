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

  require 'fileutils'

module Tobak::Repo

    class Repository

    attr_reader :path

    def initialize(path)
      @path = with_final_separator(path)
      @hashes = RepoHashes.new(self)
    end

    def add(file)
      hash = file.checksum
      hash_path = @hashes.hash_to_path(hash)
      if File.exist?(hash_path)
        # TODO log "L #{hash} #{file.path_on_volume}"
        # XXX compare file content itself if --paranoid command line option active
      else
        hash_dir = File.dirname(hash_path)
        FileUtils.mkdir_p(hash_dir)
        FileUtils.copy(file.path, hash_path)
        # TODO log "N #{hash} #{file.path_on_volume}"
      end
      target_path = File.join(file.volume.content_dir, file.path_on_volume)
      File.link(hash_path, target_path)
      meta_path = File.join(file.volume.meta_dir, file.path_on_volume)
      File.open(meta_path, 'a') do |f|
        f.puts(file.meta.to_yaml)
      end
    end

    def meta
      {
        :setup_date => Time.new
        :tobak_version => Tobak.VERSION
      }
    end

    def resources_dir_path
      File.join(@path, "resources")
    end

    def hashes_dir_path
      File.join(@path, "hashes")
    end

    def hash_path(hash)
      elements = [ @repository.path, hash[0..1], hash[2..3], hash ]
      File.join(elements)
    end

    def sessions_dir_path
      File.join(@path, "sessions")
    end

    def session_meta_path(tag)
      File.join(sessions_dir, tag, "meta")
    end
    
    def session_log_path(tag)
      File.join(sessions_dir, tag, "log")
    end
    
    def meta_file_path
      File.join(@path, "meta")
    end

    def prepare
      setup unless is_valid?
      raise unless is_valid?
    end

    private

    ##
    # setup tobak repository at the given directory
    def setup
      raise unless File.directory?(@path)
      FileUtils.mkdir(resources_dir_path)
      FileUtils.mkdir(hashes_dir_path)
      FileUtils.mkdir(sessions_dir_path)
      
      File.open(meta_file_path) do |f|
        f.puts(meta.to_yaml)
      end
    end

    def is_valid?
      File.directory?(@path) and
        File.directory?(resources_dir_path) and
        File.directory?(hashes_dir_path) and
        File.directory?(sessions_dir_path) and
        File.exist?(meta_file_path) and
        YAML.load(File.XXX.read(meta_file_path))[:tobak_version] == Tobak.VERSION
    end

  end # class Repository

end # module Tobak::Repo
