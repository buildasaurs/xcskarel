

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'karel/version'

Gem::Specification.new do |s|

  s.name                  = 'xcskarel'
  s.version               = XCSKarel::VERSION
  s.date                  = '2015-08-26'
  s.summary               = "Manage your Xcode Server & Bots from the command line"
  s.description           = "Tool for managing your Xcode Server & Bot configurations from the command line"
  s.author                = "Honza Dvorsky"
  s.email                 = 'http://honzadvorsky.com'
  s.homepage              = 'http://github.com/czechboy0/xcskarel'
  s.license               = 'MIT'

  s.required_ruby_version = '>= 2.0.0'

  s.files                 = Dir["lib/**/*"]
  s.require_paths         = ["lib"]

  s.executables           = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency 'excon', '0.45.4' # http client
  s.add_dependency 'json', '1.8.3' # json parsing
  s.add_dependency 'logger', '1.2.8' # logging
  s.add_dependency 'colored', '1.2' # colored logging
  s.add_dependency 'commander', '4.3.5' # CLI parser

  s.add_development_dependency 'pry', '0.10.1' # debugging
  s.add_development_dependency 'pry-byebug', '3.2.0' # better debugging
  
end

# reading list
# http://guides.rubygems.org/make-your-own-gem/
# https://github.com/tj/terminal-table
