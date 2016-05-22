# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','tobak','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'tobak'
  s.version = Tobak::VERSION
  s.author = 'Thilo Fischer'
  s.email = 'thilo-fischer@gmx.de'
  s.homepage = 'https://github.com/thilo-fischer'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A backup tool for files distributed (redundantly) over several resources.'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc'] #,'tobak.rdoc']
  s.rdoc_options << '--title' << 'tobak' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'tobak'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('aruba')
#  s.add_runtime_dependency('gli','2.9.0')
end
